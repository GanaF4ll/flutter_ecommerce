#!/bin/bash

# Script pour exécuter uniquement les tests web
set -e

echo "🌐 Tests de montée en charge Web - Flutter E-commerce"
echo "==============================================="

# Créer le dossier de rapports
mkdir -p reports
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Fonction pour détecter l'outil disponible
check_tools() {
    if command -v artillery &> /dev/null; then
        echo "✅ Utilisation d'Artillery (installation locale)"
        return 0
    elif command -v docker &> /dev/null; then
        echo "✅ Utilisation d'Artillery via Docker"
        return 1
    else
        echo "❌ Aucun outil disponible. Installez Artillery ou Docker."
        exit 1
    fi
}

echo "🔍 Vérification des outils..."
if check_tools; then
    # Artillery local
    echo "🧪 Exécution du test web avec Artillery local..."
    artillery run artillery-web-load-test.yml \
        --output "reports/web-test_${TIMESTAMP}.json" \
        --overrides '{"config":{"phases":[{"duration":30,"arrivalRate":5}]}}'
    
    echo ""
    echo "📊 Génération du rapport HTML..."
    artillery report "reports/web-test_${TIMESTAMP}.json" \
        --output "reports/web-test_${TIMESTAMP}.html"
else
    # Docker
    echo "🧪 Exécution du test web avec Docker..."
    docker run --rm \
        -v "$(pwd):/scripts" \
        -v "$(pwd)/reports:/reports" \
        artilleryio/artillery:latest \
        run /scripts/artillery-web-load-test.yml \
        --output "/reports/web-test_${TIMESTAMP}.json"
    
    echo ""
    echo "📊 Génération du rapport HTML..."
    docker run --rm \
        -v "$(pwd)/reports:/reports" \
        artilleryio/artillery:latest \
        report "/reports/web-test_${TIMESTAMP}.json" \
        --output "/reports/web-test_${TIMESTAMP}.html"
fi

echo ""
echo "✅ Test web terminé !"
echo "📁 Fichiers générés:"
echo "   - JSON: reports/web-test_${TIMESTAMP}.json"
echo "   - HTML: reports/web-test_${TIMESTAMP}.html"
echo ""
echo "🌐 Ouvrir le rapport:"
echo "open reports/web-test_${TIMESTAMP}.html"
