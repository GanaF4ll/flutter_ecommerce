import http from "k6/http";
import { check, sleep } from "k6";
import { Rate, Trend } from "k6/metrics";

// Métriques personnalisées
export const errorRate = new Rate("errors");
export const pageLoadTime = new Trend("page_load_time");

// Configuration du test
export const options = {
  stages: [
    { duration: "30s", target: 5 }, // Montée progressive à 5 utilisateurs
    { duration: "1m", target: 10 }, // Maintien à 10 utilisateurs
    { duration: "2m", target: 20 }, // Montée à 20 utilisateurs
    { duration: "1m", target: 30 }, // Pic à 30 utilisateurs
    { duration: "30s", target: 0 }, // Descente
  ],
  thresholds: {
    http_req_duration: ["p(95)<2000"], // 95% des requêtes < 2s
    http_req_failed: ["rate<0.1"], // Taux d'erreur < 10%
    errors: ["rate<0.1"], // Notre métrique d'erreur < 10%
  },
};

const BASE_URL = "https://flutterecommerce-fc124.firebaseapp.com";

// Données de test
const searchTerms = ["smartphone", "ordinateur", "casque", "montre"];
const categories = ["electronique", "vetements", "maison", "sport"];

export default function () {
  // Test 1: Page d'accueil
  let response = http.get(`${BASE_URL}/`);
  check(response, {
    "Homepage status is 200": (r) => r.status === 200,
    "Homepage loads in <2s": (r) => r.timings.duration < 2000,
  }) || errorRate.add(1);

  pageLoadTime.add(response.timings.duration);
  sleep(1);

  // Test 2: Page catalogue
  response = http.get(`${BASE_URL}/#/catalog`);
  check(response, {
    "Catalog status is 200": (r) => r.status === 200,
    "Catalog loads in <3s": (r) => r.timings.duration < 3000,
  }) || errorRate.add(1);

  sleep(1);

  // Test 3: Recherche de produits
  const searchTerm =
    searchTerms[Math.floor(Math.random() * searchTerms.length)];
  response = http.get(`${BASE_URL}/#/catalog?search=${searchTerm}`);
  check(response, {
    "Search status is 200": (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(1);

  // Test 4: Page produit aléatoire
  const productId = Math.floor(Math.random() * 20) + 1;
  response = http.get(`${BASE_URL}/#/product/${productId}`);
  check(response, {
    "Product page status is 200": (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(1);

  // Test 5: Navigation par catégorie
  const category = categories[Math.floor(Math.random() * categories.length)];
  response = http.get(`${BASE_URL}/#/catalog?category=${category}`);
  check(response, {
    "Category page status is 200": (r) => r.status === 200,
  }) || errorRate.add(1);

  sleep(2); // Pause réaliste entre les actions utilisateur
}

// Fonction de résumé des résultats
export function handleSummary(data) {
  return {
    "reports/k6-web-summary.html": htmlReport(data),
    "reports/k6-web-summary.json": JSON.stringify(data, null, 2),
  };
}

// Template HTML pour le rapport
function htmlReport(data) {
  return `
<!DOCTYPE html>
<html>
<head>
    <title>K6 Web Performance Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .metric { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .pass { color: green; }
        .fail { color: red; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>🚀 Test de Performance Web - Flutter E-commerce</h1>
    <p>Généré le: ${new Date().toLocaleString()}</p>
    
    <h2>📊 Métriques Principales</h2>
    <div class="metric">
        <strong>Durée totale:</strong> ${Math.round(
          data.state.testRunDurationMs / 1000
        )}s
    </div>
    <div class="metric">
        <strong>VUs maximum:</strong> ${data.metrics.vus_max.values.max}
    </div>
    <div class="metric">
        <strong>Requêtes totales:</strong> ${
          data.metrics.http_reqs.values.count
        }
    </div>
    <div class="metric">
        <strong>Taux d'erreur:</strong> 
        <span class="${
          data.metrics.http_req_failed.values.rate < 0.1 ? "pass" : "fail"
        }">
            ${(data.metrics.http_req_failed.values.rate * 100).toFixed(2)}%
        </span>
    </div>
    
    <h2>⏱️ Temps de Réponse</h2>
    <table>
        <tr><th>Métrique</th><th>Valeur</th></tr>
        <tr><td>Moyenne</td><td>${Math.round(
          data.metrics.http_req_duration.values.avg
        )}ms</td></tr>
        <tr><td>P50 (médiane)</td><td>${Math.round(
          data.metrics.http_req_duration.values.p50
        )}ms</td></tr>
        <tr><td>P95</td><td>${Math.round(
          data.metrics.http_req_duration.values.p95
        )}ms</td></tr>
        <tr><td>P99</td><td>${Math.round(
          data.metrics.http_req_duration.values.p99
        )}ms</td></tr>
        <tr><td>Maximum</td><td>${Math.round(
          data.metrics.http_req_duration.values.max
        )}ms</td></tr>
    </table>
    
    <h2>🎯 Validation des Seuils</h2>
    ${Object.entries(data.thresholds || {})
      .map(
        ([name, threshold]) =>
          `<div class="metric ${threshold.ok ? "pass" : "fail"}">
            ${threshold.ok ? "✅" : "❌"} ${name}
        </div>`
      )
      .join("")}
    
    <h2>📈 Recommandations</h2>
    <ul>
        <li>Temps de réponse P95 < 2s: ${
          data.metrics.http_req_duration.values.p95 < 2000
            ? "✅ Respecté"
            : "❌ À améliorer"
        }</li>
        <li>Taux d'erreur < 10%: ${
          data.metrics.http_req_failed.values.rate < 0.1
            ? "✅ Respecté"
            : "❌ À améliorer"
        }</li>
        <li>Performance globale: ${
          data.metrics.http_req_duration.values.avg < 1000
            ? "🚀 Excellente"
            : data.metrics.http_req_duration.values.avg < 2000
            ? "👍 Bonne"
            : "⚠️ À optimiser"
        }</li>
    </ul>
</body>
</html>`;
}
