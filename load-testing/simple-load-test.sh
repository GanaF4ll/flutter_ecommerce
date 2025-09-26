#!/bin/bash

# Test de montée en charge simple avec curl (aucun outil externe)
echo "🧪 Test de montée en charge simple avec curl"
echo "============================================="

URL="https://flutterecommerce-fc124.firebaseapp.com"
REQUESTS=50
CONCURRENT=5

echo "🎯 URL cible: $URL"
echo "📊 Requêtes: $REQUESTS"
echo "👥 Utilisateurs simultanés: $CONCURRENT"
echo ""

# Créer le dossier de rapports
mkdir -p reports
REPORT_FILE="reports/curl-load-test-$(date +%Y%m%d_%H%M%S).log"

echo "⏱️  Démarrage du test..."
START_TIME=$(date +%s)

# Fonction pour tester une URL
test_url() {
    local url=$1
    local id=$2
    local results_file="reports/user_${id}_results.tmp"
    
    for i in $(seq 1 $((REQUESTS / CONCURRENT))); do
        # Mesurer le temps de réponse
        response_time=$(curl -w "%{time_total},%{http_code},%{size_download}\n" \
                           -o /dev/null \
                           -s \
                           "$url" 2>/dev/null)
        
        echo "$response_time" >> "$results_file"
        
        # Pause aléatoire entre 0.5 et 2 secondes
        sleep $(echo "scale=1; $(shuf -i 5-20 -n 1)/10" | bc)
    done
}

# Lancer les tests en parallèle
echo "🚀 Lancement de $CONCURRENT utilisateurs virtuels..."
for i in $(seq 1 $CONCURRENT); do
    test_url "$URL" "$i" &
done

# Attendre que tous les tests se terminent
wait

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ Tests terminés en ${DURATION}s"

# Analyser les résultats
echo ""
echo "📊 Analyse des résultats..."

# Combiner tous les fichiers de résultats
cat reports/user_*_results.tmp > reports/all_results.tmp 2>/dev/null

if [ -f "reports/all_results.tmp" ]; then
    total_requests=$(wc -l < reports/all_results.tmp)
    successful_requests=$(awk -F',' '$2 == 200' reports/all_results.tmp | wc -l)
    success_rate=$(echo "scale=1; $successful_requests * 100 / $total_requests" | bc)
    
    # Calculer les temps de réponse
    avg_time=$(awk -F',' '{sum+=$1} END {printf "%.3f", sum/NR}' reports/all_results.tmp)
    min_time=$(awk -F',' '{print $1}' reports/all_results.tmp | sort -n | head -1)
    max_time=$(awk -F',' '{print $1}' reports/all_results.tmp | sort -n | tail -1)
    
    # Calculer P95 (approximatif)
    p95_line=$(echo "$total_requests * 0.95" | bc | cut -d. -f1)
    p95_time=$(awk -F',' '{print $1}' reports/all_results.tmp | sort -n | sed -n "${p95_line}p")
    
    # Calculer le débit
    requests_per_sec=$(echo "scale=2; $total_requests / $DURATION" | bc)
    
    # Générer le rapport
    {
        echo "========================================"
        echo "RAPPORT DE TEST DE MONTÉE EN CHARGE"
        echo "========================================"
        echo "Date: $(date)"
        echo "URL: $URL"
        echo "Durée: ${DURATION}s"
        echo ""
        echo "MÉTRIQUES GLOBALES:"
        echo "- Requêtes totales: $total_requests"
        echo "- Requêtes réussies: $successful_requests"
        echo "- Taux de succès: ${success_rate}%"
        echo "- Débit: ${requests_per_sec} req/s"
        echo ""
        echo "TEMPS DE RÉPONSE:"
        echo "- Minimum: ${min_time}s"
        echo "- Moyenne: ${avg_time}s"
        echo "- P95: ${p95_time}s"
        echo "- Maximum: ${max_time}s"
        echo ""
        echo "ÉVALUATION:"
        if (( $(echo "$avg_time < 1.0" | bc -l) )); then
            echo "- Performance: 🚀 Excellente"
        elif (( $(echo "$avg_time < 2.0" | bc -l) )); then
            echo "- Performance: 👍 Bonne"
        else
            echo "- Performance: ⚠️ À améliorer"
        fi
        
        if (( $(echo "$success_rate > 95" | bc -l) )); then
            echo "- Fiabilité: ✅ Excellente"
        elif (( $(echo "$success_rate > 90" | bc -l) )); then
            echo "- Fiabilité: 👍 Correcte"
        else
            echo "- Fiabilité: ❌ Problématique"
        fi
        echo "========================================"
    } | tee "$REPORT_FILE"
    
    echo ""
    echo "📁 Rapport sauvegardé: $REPORT_FILE"
    
    # Nettoyer les fichiers temporaires
    rm -f reports/user_*_results.tmp reports/all_results.tmp
    
else
    echo "❌ Erreur: Aucun résultat collecté"
fi

echo ""
echo "🎉 Test terminé !"
