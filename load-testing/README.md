# Tests de Montée en Charge - Flutter E-commerce

## Installation des outils (sans npm)

### Option 1: Installation directe d'Artillery

```bash
# Sur macOS avec Homebrew
brew install artillery

# Sur Linux/macOS avec curl
curl -sSL https://get.artillery.io | sh

# Vérification
artillery --version
```

### Option 2: Installation de K6

```bash
# Sur macOS avec Homebrew
brew install k6

# Sur Linux
sudo apt-get install k6

# Vérification
k6 version
```

### Option 3: Utilisation de Docker (recommandé)

```bash
# Pas besoin d'installer quoi que ce soit, juste Docker
docker --version
```

## Exécution des tests

### Avec Artillery (installation locale)

```bash
# Test de l'application web
artillery run artillery-web-load-test.yml

# Test de l'API externe
artillery run artillery-api-load-test.yml

# Test d'authentification Firebase
artillery run artillery-firebase-load-test.yml

# Test de stress
artillery run artillery-stress-test.yml
```

### Avec Docker (recommandé)

```bash
# Test de l'application web
docker run --rm -v $(pwd):/scripts artilleryio/artillery:latest run /scripts/artillery-web-load-test.yml

# Test de l'API
docker run --rm -v $(pwd):/scripts artilleryio/artillery:latest run /scripts/artillery-api-load-test.yml

# Test Firebase
docker run --rm -v $(pwd):/scripts artilleryio/artillery:latest run /scripts/artillery-firebase-load-test.yml

# Test de stress
docker run --rm -v $(pwd):/scripts artilleryio/artillery:latest run /scripts/artillery-stress-test.yml
```

### Avec K6 (installation locale)

```bash
# Test de performance web
k6 run k6-web-performance.js

# Test d'authentification Firebase
k6 run k6-firebase-auth.js
```

### Avec K6 et Docker

```bash
# Test de performance web
docker run --rm -v $(pwd):/scripts grafana/k6:latest run /scripts/k6-web-performance.js

# Test d'authentification Firebase
docker run --rm -v $(pwd):/scripts grafana/k6:latest run /scripts/k6-firebase-auth.js
```

## Scripts d'automatisation

Utilisez les scripts shell fournis pour simplifier l'exécution :

```bash
# Rendre les scripts exécutables
chmod +x *.sh

# Exécuter tous les tests
./run-all-tests.sh

# Exécuter seulement les tests web
./run-web-tests.sh

# Exécuter seulement les tests de stress
./run-stress-tests.sh
```

## Métriques surveillées

- **Temps de réponse** : P50, P95, P99
- **Débit** : Requêtes par seconde
- **Taux d'erreur** : Pourcentage d'erreurs HTTP
- **Utilisation des ressources** : CPU, mémoire, bande passante
- **Latence réseau** : Temps de connexion et de transfert

## Interprétation des résultats

### Seuils de performance acceptables

- Temps de réponse P95 < 2 secondes
- Taux d'erreur < 1%
- Débit > 100 req/sec pour usage normal
- CPU < 80% sous charge normale

### Alertes à surveiller

- Temps de réponse > 5 secondes
- Taux d'erreur > 5%
- Timeouts fréquents
- Erreurs 50x du serveur
