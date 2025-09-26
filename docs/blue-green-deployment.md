# 🔄 Blue-Green Deployment Guide

## Vue d'ensemble

Le déploiement Blue-Green permet de déployer de nouvelles versions sans interruption de service en utilisant deux environnements identiques :

- **🔵 BLUE (Production)** : Version actuellement en production
- **🟢 GREEN (Staging)** : Nouvelle version en préparation

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │    │  Firebase   │    │ Utilisateurs│
│   Actions   │───▶│  Hosting    │◀───│             │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                           ▼
                   ┌─────────────┐
                   │    GREEN    │
                   │  (Staging)  │
                   │             │
                   └─────────────┘
                           │
                    Tests Performance
                           │
                           ▼
                   ┌─────────────┐
                   │    BLUE     │
                   │(Production) │
                   │             │
                   └─────────────┘
```

## Processus de déploiement

### 1. 🚀 Automatique (GitHub Actions)

Le déploiement se déclenche automatiquement lors d'un push sur `main` :

```yaml
# Déclenché automatiquement
git push origin main
```

**Étapes automatiques :**

1. **Build & Tests** - Compilation et tests unitaires
2. **Deploy GREEN** - Déploiement sur environnement staging
3. **Performance Tests** - Tests de charge sur GREEN
4. **Switch to BLUE** - Basculement vers production (si tests OK)
5. **Validation** - Tests de validation production
6. **Rollback** - Retour automatique si échec

### 2. 🛠️ Manuel (Script)

```bash
# Déploiement manuel étape par étape
./scripts/deploy-blue-green.sh deploy    # Déployer sur GREEN
./scripts/deploy-blue-green.sh test      # Tester GREEN
./scripts/deploy-blue-green.sh switch    # Basculer vers BLUE
./scripts/deploy-blue-green.sh rollback  # Rollback si nécessaire
```

## Configuration Firebase

### Création des sites

```bash
# Créer le site de staging (si pas encore fait)
firebase hosting:sites:create flutterecommerce-staging --project flutterecommerce-fc124

# Configurer les targets
firebase target:apply hosting production flutterecommerce-fc124
firebase target:apply hosting staging flutterecommerce-staging
```

### Variables d'environnement GitHub

Ajouter dans GitHub Repository Settings > Secrets and variables > Actions :

```
Variables:
- FIREBASE_BLUE_SITE_ID: flutterecommerce-fc124
- FIREBASE_GREEN_SITE_ID: flutterecommerce-staging

Secrets:
- FIREBASE_SERVICE_ACCOUNT_FLUTTERECOMMERCE_FC124: (Clé de service Firebase)
```

## Tests de performance intégrés

### Seuils de qualité

```yaml
Performance Score >= 70/100 pour passer en production

Métriques surveillées:
- Temps de réponse moyen < 3000ms
- Taux d'erreur < 5%
- P95 < 5000ms
- Minimum 10 requêtes réussies
```

### Outils utilisés

- **Artillery** : Tests de charge HTTP
- **Flutter Tests** : Tests natifs de l'application
- **Curl** : Tests de connectivité rapides

## Monitoring et observabilité

### URLs importantes

- **Production** : https://flutterecommerce-fc124.firebaseapp.com
- **Staging** : https://flutterecommerce-staging.firebaseapp.com
- **Backup channels** : https://\{backup-id\}--flutterecommerce-fc124.firebaseapp.com

### Artifacts GitHub Actions

- `deployment-info-{version}` - Informations de déploiement
- `green-performance-reports` - Rapports de performance staging
- `web-build-{version}` - Build de l'application

## Rollback et récupération

### Rollback automatique

Le rollback se déclenche automatiquement si :

- Score de performance < 70/100
- Échec des tests de validation
- Erreur de déploiement

### Rollback manuel

```bash
# Via script
./scripts/deploy-blue-green.sh rollback

# Via Firebase CLI
firebase hosting:channel:deploy backup-{timestamp} --project flutterecommerce-fc124
```

## Commandes utiles

### Status des environnements

```bash
./scripts/deploy-blue-green.sh status
```

### Nettoyage

```bash
# Nettoyer les anciens canaux
./scripts/deploy-blue-green.sh cleanup

# Lister tous les canaux
firebase hosting:channel:list --project flutterecommerce-fc124
```

### Monitoring manuel

```bash
# Tester la production
curl -f https://flutterecommerce-fc124.firebaseapp.com

# Tester le staging
curl -f https://flutterecommerce-staging.firebaseapp.com

# Tests de performance rapides
cd load-testing && ./simple-load-test.sh
```

## Troubleshooting

### Problèmes courants

**1. Échec de déploiement GREEN**

```bash
# Vérifier les logs
firebase hosting:channel:list --project flutterecommerce-fc124

# Re-déployer manuellement
./scripts/deploy-blue-green.sh deploy
```

**2. Tests de performance échouent**

```bash
# Analyser les rapports
ls -la load-testing/reports/

# Tests manuels
flutter test test/load_testing/simple_performance_test.dart
```

**3. Rollback nécessaire**

```bash
# Rollback immédiat
./scripts/deploy-blue-green.sh rollback

# Ou via GitHub Actions
# Issues → New Issue → Template "Rollback Request"
```

### Contacts d'urgence

- **GitHub Actions** : https://github.com/{org}/{repo}/actions
- **Firebase Console** : https://console.firebase.google.com/project/flutterecommerce-fc124
- **Logs** : GitHub Actions → Workflow runs → Download artifacts

## Métriques de succès

### KPIs de déploiement

- **MTTR** (Mean Time To Recovery) : < 5 minutes
- **Deployment Frequency** : Multiple par jour
- **Change Failure Rate** : < 5%
- **Lead Time** : < 15 minutes

### Performance

- **Disponibilité** : > 99.9%
- **Temps de réponse P95** : < 2 secondes
- **Taux d'erreur** : < 1%

## Améliorations futures

- [ ] Tests canary (déploiement graduel)
- [ ] Monitoring métrique en temps réel
- [ ] Alertes automatiques
- [ ] Tests de chaos
- [ ] Déploiement multi-région
