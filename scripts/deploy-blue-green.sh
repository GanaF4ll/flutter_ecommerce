#!/bin/bash

# Script de déploiement Blue-Green manuel
# Utilisation: ./deploy-blue-green.sh [deploy|switch|rollback|status]

set -e

FIREBASE_PROJECT="flutterecommerce-fc124"
PRODUCTION_URL="https://flutterecommerce-fc124.firebaseapp.com"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BUILD_VERSION="manual-$TIMESTAMP"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    echo "🚀 Déploiement Blue-Green Firebase"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Déployer sur l'environnement staging (GREEN)"
    echo "  test      Tester l'environnement staging"
    echo "  switch    Basculer staging vers production (BLUE)"
    echo "  rollback  Revenir à la version précédente"
    echo "  status    Afficher le statut des environnements"
    echo "  cleanup   Nettoyer les anciens déploiements"
    echo ""
}

check_dependencies() {
    echo -e "${BLUE}🔍 Vérification des dépendances...${NC}"
    
    if ! command -v firebase &> /dev/null; then
        echo -e "${RED}❌ Firebase CLI non installé${NC}"
        echo "Installer avec: npm install -g firebase-tools"
        exit 1
    fi
    
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter non installé${NC}"
        exit 1
    fi
    
    if ! firebase projects:list | grep -q "$FIREBASE_PROJECT"; then
        echo -e "${RED}❌ Projet Firebase non accessible${NC}"
        echo "Se connecter avec: firebase login"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Toutes les dépendances sont présentes${NC}"
}

build_app() {
    echo -e "${BLUE}🏗️ Build de l'application...${NC}"
    
    flutter pub get
    flutter test test/load_testing/
    flutter build web --release --build-name="$BUILD_VERSION"
    
    echo -e "${GREEN}✅ Build terminé: $BUILD_VERSION${NC}"
}

deploy_staging() {
    echo -e "${BLUE}🟢 Déploiement sur STAGING (GREEN)...${NC}"
    
    build_app
    
    # Déployer sur un canal preview
    CHANNEL_ID="green-$BUILD_VERSION"
    firebase hosting:channel:deploy "$CHANNEL_ID" --project "$FIREBASE_PROJECT" --expires 7d
    
    # Récupérer l'URL du canal
    STAGING_URL=$(firebase hosting:channel:list --project "$FIREBASE_PROJECT" --json | jq -r ".channels[] | select(.name == \"$CHANNEL_ID\") | .url")
    
    echo -e "${GREEN}✅ Staging déployé sur: $STAGING_URL${NC}"
    echo "$STAGING_URL" > .staging-url
    echo "$BUILD_VERSION" > .build-version
    
    echo -e "${YELLOW}🧪 Lancer les tests avec: $0 test${NC}"
}

test_staging() {
    echo -e "${BLUE}🧪 Tests de l'environnement staging...${NC}"
    
    if [ ! -f ".staging-url" ]; then
        echo -e "${RED}❌ Aucun environnement staging trouvé${NC}"
        echo "Déployer d'abord avec: $0 deploy"
        exit 1
    fi
    
    STAGING_URL=$(cat .staging-url)
    echo -e "${BLUE}Testing: $STAGING_URL${NC}"
    
    # Tests de base
    echo "🔍 Test de connectivité..."
    if curl -f --max-time 10 "$STAGING_URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Staging accessible${NC}"
    else
        echo -e "${RED}❌ Staging inaccessible${NC}"
        exit 1
    fi
    
    # Tests de performance
    cd load-testing
    mkdir -p reports
    
    echo "📊 Tests de performance..."
    if command -v artillery &> /dev/null; then
        # Créer un fichier de test temporaire pour staging
        sed "s|https://flutterecommerce-fc124.firebaseapp.com|$STAGING_URL|g" artillery-web-load-test.yml > artillery-staging.yml
        artillery run artillery-staging.yml --output reports/staging-test.json
        
        # Analyser les résultats
        if [ -f "reports/staging-test.json" ]; then
            echo -e "${GREEN}✅ Tests de performance terminés${NC}"
            echo "📊 Rapport: load-testing/reports/staging-test.json"
        fi
    else
        echo -e "${YELLOW}⚠️ Artillery non installé, tests basiques seulement${NC}"
    fi
    
    cd ..
    
    # Tests Flutter
    export TEST_TARGET_URL="$STAGING_URL"
    flutter test test/load_testing/simple_performance_test.dart
    
    echo -e "${GREEN}✅ Tests terminés avec succès${NC}"
    echo -e "${YELLOW}🔄 Basculer vers production avec: $0 switch${NC}"
}

switch_to_production() {
    echo -e "${BLUE}🔄 Basculement vers PRODUCTION (BLUE)...${NC}"
    
    if [ ! -f ".staging-url" ] || [ ! -f ".build-version" ]; then
        echo -e "${RED}❌ Pas d'environnement staging prêt${NC}"
        exit 1
    fi
    
    BUILD_VERSION=$(cat .build-version)
    
    # Sauvegarder la production actuelle
    echo "💾 Sauvegarde de la production actuelle..."
    BACKUP_CHANNEL="backup-$TIMESTAMP"
    firebase hosting:clone --source-channel=live --target-channel="$BACKUP_CHANNEL" --project "$FIREBASE_PROJECT" || true
    
    # Déployer en production
    echo "🚀 Déploiement en production..."
    firebase deploy --only hosting --project "$FIREBASE_PROJECT"
    
    # Vérifier la production
    sleep 10
    if curl -f --max-time 10 "$PRODUCTION_URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Production mise à jour avec succès${NC}"
        echo -e "${GREEN}🌐 URL: $PRODUCTION_URL${NC}"
        
        # Sauvegarder les informations de déploiement
        echo "{
            \"version\": \"$BUILD_VERSION\",
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
            \"backup_channel\": \"$BACKUP_CHANNEL\",
            \"production_url\": \"$PRODUCTION_URL\"
        }" > .production-deployment.json
        
        echo -e "${BLUE}📋 Informations sauvegardées dans .production-deployment.json${NC}"
    else
        echo -e "${RED}❌ Problème de déploiement production${NC}"
        echo "🔙 Rollback recommandé"
        exit 1
    fi
    
    # Nettoyer
    cleanup_staging
}

rollback() {
    echo -e "${YELLOW}🔙 Rollback en cours...${NC}"
    
    if [ ! -f ".production-deployment.json" ]; then
        echo -e "${RED}❌ Aucune information de déploiement trouvée${NC}"
        exit 1
    fi
    
    BACKUP_CHANNEL=$(jq -r '.backup_channel' .production-deployment.json)
    
    if [ "$BACKUP_CHANNEL" != "null" ]; then
        echo "🔄 Restauration depuis: $BACKUP_CHANNEL"
        firebase hosting:clone --source-channel="$BACKUP_CHANNEL" --target-channel=live --project "$FIREBASE_PROJECT"
        
        echo -e "${GREEN}✅ Rollback terminé${NC}"
    else
        echo -e "${RED}❌ Pas de sauvegarde disponible${NC}"
    fi
}

show_status() {
    echo -e "${BLUE}📊 Statut des environnements${NC}"
    echo ""
    
    echo "🌐 PRODUCTION:"
    echo "   URL: $PRODUCTION_URL"
    if curl -f --max-time 5 "$PRODUCTION_URL" > /dev/null 2>&1; then
        echo -e "   Status: ${GREEN}✅ Accessible${NC}"
    else
        echo -e "   Status: ${RED}❌ Inaccessible${NC}"
    fi
    
    echo ""
    echo "🟢 STAGING:"
    if [ -f ".staging-url" ]; then
        STAGING_URL=$(cat .staging-url)
        echo "   URL: $STAGING_URL"
        if curl -f --max-time 5 "$STAGING_URL" > /dev/null 2>&1; then
            echo -e "   Status: ${GREEN}✅ Accessible${NC}"
        else
            echo -e "   Status: ${RED}❌ Inaccessible${NC}"
        fi
    else
        echo "   Status: Aucun staging actif"
    fi
    
    echo ""
    echo "📦 DERNIERS DÉPLOIEMENTS:"
    firebase hosting:channel:list --project "$FIREBASE_PROJECT" | head -10
}

cleanup_staging() {
    echo -e "${BLUE}🧹 Nettoyage des environnements staging...${NC}"
    
    # Supprimer les fichiers locaux
    rm -f .staging-url .build-version
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

cleanup_old_channels() {
    echo -e "${BLUE}🧹 Nettoyage des anciens canaux...${NC}"
    
    # Cette fonction nécessiterait une logique plus complexe pour identifier et supprimer les anciens canaux
    firebase hosting:channel:list --project "$FIREBASE_PROJECT" --json | jq -r '.channels[] | select(.name | startswith("green-")) | .name' | head -5 | while read channel; do
        echo "🗑️ Suppression du canal: $channel"
        firebase hosting:channel:delete "$channel" --project "$FIREBASE_PROJECT" --force || true
    done
}

# Main script
case "$1" in
    "deploy")
        check_dependencies
        deploy_staging
        ;;
    "test")
        test_staging
        ;;
    "switch")
        switch_to_production
        ;;
    "rollback")
        rollback
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup_old_channels
        ;;
    *)
        show_help
        ;;
esac
