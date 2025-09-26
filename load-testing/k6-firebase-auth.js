import http from "k6/http";
import { check, sleep } from "k6";
import { Rate, Counter } from "k6/metrics";

// Métriques personnalisées pour Firebase
export const authErrors = new Rate("auth_errors");
export const authAttempts = new Counter("auth_attempts");

export const options = {
  stages: [
    { duration: "30s", target: 2 }, // Montée douce pour Firebase
    { duration: "1m", target: 5 }, // Charge modérée
    { duration: "1m", target: 8 }, // Charge normale
    { duration: "30s", target: 0 }, // Descente
  ],
  thresholds: {
    http_req_duration: ["p(95)<3000"], // Firebase peut être plus lent
    auth_errors: ["rate<0.2"], // 20% d'erreurs max (comptes de test)
  },
};

const FIREBASE_API_KEY = "AIzaSyAH-3PYZI9QL8TsojvBqg4MACQjE4W1DlQ";
const FIREBASE_AUTH_URL = "https://identitytoolkit.googleapis.com";

// Emails de test (ne pas utiliser de vrais emails)
const testEmails = [
  "loadtest1@example.com",
  "loadtest2@example.com",
  "loadtest3@example.com",
  "loadtest4@example.com",
  "loadtest5@example.com",
];

export default function () {
  const testEmail = testEmails[Math.floor(Math.random() * testEmails.length)];
  const testPassword = "TestPassword123!";

  // Test 1: Tentative de connexion (peut échouer si le compte n'existe pas)
  testSignIn(testEmail, testPassword);
  sleep(1);

  // Test 2: Création de compte avec email aléatoire
  const randomEmail = `loadtest${Date.now()}${Math.random()
    .toString(36)
    .substr(2, 5)}@temp.com`;
  testSignUp(randomEmail, testPassword);
  sleep(2);

  // Test 3: Test de refresh token (simulé)
  testRefreshToken();
  sleep(1);
}

function testSignIn(email, password) {
  authAttempts.add(1);

  const payload = {
    email: email,
    password: password,
    returnSecureToken: true,
  };

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  const response = http.post(
    `${FIREBASE_AUTH_URL}/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`,
    JSON.stringify(payload),
    params
  );

  const success = check(response, {
    "SignIn request completed": (r) => r.status === 200 || r.status === 400,
    "SignIn response time < 3s": (r) => r.timings.duration < 3000,
  });

  if (!success) authErrors.add(1);

  // Log pour debug (seulement en cas d'erreur inattendue)
  if (response.status !== 200 && response.status !== 400) {
    console.log(`SignIn unexpected status: ${response.status}`);
  }
}

function testSignUp(email, password) {
  authAttempts.add(1);

  const payload = {
    email: email,
    password: password,
    returnSecureToken: true,
  };

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  const response = http.post(
    `${FIREBASE_AUTH_URL}/v1/accounts:signUp?key=${FIREBASE_API_KEY}`,
    JSON.stringify(payload),
    params
  );

  const success = check(response, {
    "SignUp request completed": (r) => r.status === 200 || r.status === 400,
    "SignUp response time < 3s": (r) => r.timings.duration < 3000,
  });

  if (!success) authErrors.add(1);

  // Capturer le token si la création réussit
  if (response.status === 200) {
    const body = JSON.parse(response.body);
    if (body.idToken) {
      // Token capturé avec succès
      console.log(`Account created successfully for ${email}`);
    }
  }
}

function testRefreshToken() {
  // Simulation d'un refresh token (avec un faux token pour tester la réactivité de l'API)
  const payload = {
    grant_type: "refresh_token",
    refresh_token: "dummy_refresh_token_for_load_test",
  };

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  const response = http.post(
    `${FIREBASE_AUTH_URL}/v1/token?key=${FIREBASE_API_KEY}`,
    JSON.stringify(payload),
    params
  );

  // On s'attend à un 400 avec un faux token, c'est normal
  check(response, {
    "Refresh token endpoint responsive": (r) =>
      r.status === 400 || r.status === 200,
    "Refresh token response time < 2s": (r) => r.timings.duration < 2000,
  });
}

export function handleSummary(data) {
  return {
    "reports/k6-firebase-summary.html": firebaseHtmlReport(data),
    "reports/k6-firebase-summary.json": JSON.stringify(data, null, 2),
  };
}

function firebaseHtmlReport(data) {
  return `
<!DOCTYPE html>
<html>
<head>
    <title>K6 Firebase Auth Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .metric { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .pass { color: green; }
        .fail { color: red; }
        .warning { color: orange; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>🔐 Test Firebase Authentication - Flutter E-commerce</h1>
    <p>Généré le: ${new Date().toLocaleString()}</p>
    
    <h2>📊 Métriques Firebase Auth</h2>
    <div class="metric">
        <strong>Tentatives d'authentification:</strong> ${
          data.metrics.auth_attempts
            ? data.metrics.auth_attempts.values.count
            : "N/A"
        }
    </div>
    <div class="metric">
        <strong>Taux d'erreur auth:</strong> 
        <span class="${
          data.metrics.auth_errors && data.metrics.auth_errors.values.rate < 0.2
            ? "pass"
            : "warning"
        }">
            ${
              data.metrics.auth_errors
                ? (data.metrics.auth_errors.values.rate * 100).toFixed(2)
                : "0"
            }%
        </span>
    </div>
    <div class="metric">
        <strong>Requêtes HTTP totales:</strong> ${
          data.metrics.http_reqs.values.count
        }
    </div>
    
    <h2>⏱️ Performance Firebase</h2>
    <table>
        <tr><th>Métrique</th><th>Valeur</th><th>Statut</th></tr>
        <tr>
            <td>Temps de réponse moyen</td>
            <td>${Math.round(data.metrics.http_req_duration.values.avg)}ms</td>
            <td class="${
              data.metrics.http_req_duration.values.avg < 2000
                ? "pass"
                : "warning"
            }">
                ${
                  data.metrics.http_req_duration.values.avg < 2000
                    ? "✅ Bon"
                    : "⚠️ Lent"
                }
            </td>
        </tr>
        <tr>
            <td>P95</td>
            <td>${Math.round(data.metrics.http_req_duration.values.p95)}ms</td>
            <td class="${
              data.metrics.http_req_duration.values.p95 < 3000 ? "pass" : "fail"
            }">
                ${
                  data.metrics.http_req_duration.values.p95 < 3000
                    ? "✅ Accepté"
                    : "❌ Trop lent"
                }
            </td>
        </tr>
    </table>
    
    <h2>🎯 Résultats des Tests</h2>
    ${Object.entries(data.thresholds || {})
      .map(
        ([name, threshold]) =>
          `<div class="metric ${threshold.ok ? "pass" : "fail"}">
            ${threshold.ok ? "✅" : "❌"} ${name}
        </div>`
      )
      .join("")}
    
    <h2>📝 Notes Importantes</h2>
    <div class="metric warning">
        ⚠️ Ce test utilise des comptes de test temporaires.<br>
        🔒 Les erreurs 400 sont normales pour les tentatives de connexion avec des comptes inexistants.<br>
        📈 Focus sur les temps de réponse et la disponibilité du service Firebase.
    </div>
    
    <h2>📈 Recommandations</h2>
    <ul>
        <li>Temps de réponse Firebase < 3s: ${
          data.metrics.http_req_duration.values.p95 < 3000
            ? "✅ Respecté"
            : "❌ À surveiller"
        }</li>
        <li>Service disponible: ${
          data.metrics.http_req_failed.values.rate < 0.5
            ? "✅ Stable"
            : "❌ Instable"
        }</li>
        <li>Performance auth: ${
          data.metrics.http_req_duration.values.avg < 2000
            ? "🚀 Rapide"
            : "⚠️ Peut être optimisé côté client"
        }</li>
    </ul>
</body>
</html>`;
}
