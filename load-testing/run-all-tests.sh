#!/bin/bash

# Script pour exécuter tous les tests de montée en charge
# Compatible avec Docker et installations locales

set -e  # Arrêt en cas d'erreur

echo "🚀 Démarrage des tests de montée en charge Flutter E-commerce"
echo "=================================================="

# Créer le dossier de rapports
mkdir -p reports
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Fonction pour détecter si Artillery est installé
check_artillery() {
    if command -v artillery &> /dev/null; then
        echo "✅ Artillery détecté (installation locale)"
        return 0
    elif command -v docker &> /dev/null; then
        echo "✅ Docker détecté, utilisation d'Artillery via Docker"
        return 1
    else
        echo "❌ Ni Artillery ni Docker trouvés. Veuillez installer l'un des deux."
        exit 1
    fi
}

# Fonction pour exécuter Artillery
run_artillery() {
    local test_file=$1
    local test_name=$2
    
    echo "🧪 Exécution du test: $test_name"
    
    if check_artillery; then
        # Installation locale
        artillery run "$test_file" --output "reports/${test_name}_${TIMESTAMP}.json"
    else
        # Docker
        docker run --rm \
            -v "$(pwd):/scripts" \
            -v "$(pwd)/reports:/reports" \
            artilleryio/artillery:latest \
            run "/scripts/$test_file" --output "/reports/${test_name}_${TIMESTAMP}.json"
    fi
    
    echo "✅ Test $test_name terminé"
    echo ""
}

# Exécution des tests dans l'ordre
echo "📊 Phase 1: Test de l'application web"
run_artillery "artillery-web-load-test.yml" "web-load"

echo "🔌 Phase 2: Test de l'API externe"
run_artillery "artillery-api-load-test.yml" "api-load"

echo "🔐 Phase 3: Test d'authentification Firebase"
run_artillery "artillery-firebase-load-test.yml" "firebase-auth"

echo "⚡ Phase 4: Test de stress"
run_artillery "artillery-stress-test.yml" "stress-test"

echo "=================================================="
echo "🎉 Tous les tests terminés !"
echo "📁 Rapports disponibles dans le dossier: reports/"
echo ""
echo "Pour générer un rapport HTML:"
echo "artillery report reports/web-load_${TIMESTAMP}.json"
echo ""
echo "Pour analyser les résultats:"
echo "ls -la reports/"
