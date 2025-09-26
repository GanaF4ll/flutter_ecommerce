#!/bin/bash

# Script de démarrage rapide pour les tests de montée en charge
echo "🚀 Quick Start - Tests de montée en charge Flutter E-commerce"
echo "============================================================="

# Créer le dossier de rapports
mkdir -p reports

echo ""
echo "Choisissez votre méthode de test :"
echo "1) Docker Artillery (recommandé - aucune installation)"
echo "2) Docker K6 (recommandé - aucune installation)" 
echo "3) Installation locale Artillery"
echo "4) Installation locale K6"
echo ""

read -p "Votre choix (1-4): " choice

case $choice in
  1)
    echo ""
    echo "🐳 Test avec Docker Artillery..."
    if command -v docker &> /dev/null; then
      echo "✅ Docker détecté"
      echo "📊 Lancement du test web (durée ~2 minutes)..."
      docker run --rm -v $(pwd):/scripts -v $(pwd)/reports:/reports \
        artilleryio/artillery:latest run /scripts/artillery-web-load-test.yml \
        --output /reports/quick-test-$(date +%s).json
      echo "✅ Test terminé ! Rapports dans le dossier reports/"
    else
      echo "❌ Docker non installé. Installez Docker ou choisissez une autre option."
    fi
    ;;
    
  2)
    echo ""
    echo "🐳 Test avec Docker K6..."
    if command -v docker &> /dev/null; then
      echo "✅ Docker détecté"
      echo "📊 Lancement du test K6 (durée ~5 minutes)..."
      docker run --rm -v $(pwd):/scripts -v $(pwd)/reports:/reports \
        grafana/k6:latest run /scripts/k6-web-performance.js
      echo "✅ Test terminé ! Rapport HTML généré dans reports/"
    else
      echo "❌ Docker non installé. Installez Docker ou choisissez une autre option."
    fi
    ;;
    
  3)
    echo ""
    echo "⚙️ Installation locale Artillery..."
    if command -v artillery &> /dev/null; then
      echo "✅ Artillery déjà installé"
    else
      echo "📦 Installation d'Artillery..."
      if command -v brew &> /dev/null; then
        brew install artillery
      else
        echo "💡 Installez Artillery avec : curl -sSL https://get.artillery.io | sh"
        echo "Puis relancez ce script"
        exit 1
      fi
    fi
    echo "📊 Lancement du test..."
    artillery run artillery-web-load-test.yml --output reports/local-test-$(date +%s).json
    ;;
    
  4)
    echo ""
    echo "⚙️ Installation locale K6..."
    if command -v k6 &> /dev/null; then
      echo "✅ K6 déjà installé"
    else
      echo "📦 Installation de K6..."
      if command -v brew &> /dev/null; then
        brew install k6
      else
        echo "💡 Installez K6 avec votre gestionnaire de paquets, puis relancez ce script"
        exit 1
      fi
    fi
    echo "📊 Lancement du test K6..."
    k6 run k6-web-performance.js
    ;;
    
  *)
    echo "❌ Choix invalide"
    exit 1
    ;;
esac

echo ""
echo "🎉 Test terminé !"
echo "📁 Consultez les rapports dans le dossier : reports/"
echo "🌐 Pour ouvrir un rapport HTML : open reports/*.html"
