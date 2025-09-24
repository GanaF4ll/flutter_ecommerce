# Tests Flutter E-commerce

Ce dossier contient tous les tests unitaires et d'intégration pour l'application Flutter E-commerce.

## 📁 Structure des Tests

```
test/
├── entities/          # Tests des modèles de données
│   ├── product_test.dart
│   ├── rating_test.dart
│   ├── cart_item_test.dart
│   └── favorite_test.dart
├── widgets/           # Tests des composants UI
│   ├── product_card_test.dart
│   └── drawer_test.dart
├── guards/            # Tests des guards d'authentification
│   └── auth_guard_test.dart
├── pages/             # Tests des pages
│   ├── home_page_test.dart
│   ├── catalog_page_test.dart
│   └── favorites_page_test.dart
├── widget_test.dart   # Tests principaux de l'application
├── test_runner.dart   # Exécuteur de tous les tests
└── README.md          # Ce fichier
```

## 🚀 Exécution des Tests

### Tous les tests

```bash
flutter test
```

### Tests spécifiques par catégorie

```bash
# Tests des entités
flutter test test/entities/

# Tests des widgets
flutter test test/widgets/

# Tests des pages
flutter test test/pages/

# Tests des guards
flutter test test/guards/
```

### Test d'un fichier spécifique

```bash
flutter test test/entities/product_test.dart
```

### Tests avec couverture de code

```bash
flutter test --coverage
```

## 📊 Types de Tests

### 🏗️ Tests des Entités

- **Product**: Validation des données produit, sérialisation JSON
- **Rating**: Gestion des notes et évaluations
- **CartItem**: Logique des articles du panier
- **Favorite**: Fonctionnalités des favoris

### 🎨 Tests des Widgets

- **ProductCard**: Affichage des cartes produit, interactions
- **AppDrawer**: Navigation, états d'authentification

### 🛡️ Tests des Guards

- **AuthGuard**: Protection des routes, redirection d'authentification

### 📱 Tests des Pages

- **HomePage**: Page d'accueil, navigation, affichage des sections
- **CatalogPage**: Liste des produits, filtres
- **FavoritesPage**: Gestion des favoris, états vides

### 🚀 Tests de l'Application

- Configuration des routes
- Navigation entre pages
- Gestion du cycle de vie
- Thème et accessibilité

## 🔧 Mocks et Helpers

Les tests utilisent des mocks pour :

- **Firebase Auth** : Simulation de l'authentification
- **Database** : Tests sans base de données réelle
- **Network** : Simulation des appels API

## 📋 Checklist des Tests

- ✅ Tests des entités (Product, Rating, CartItem, Favorite)
- ✅ Tests des widgets (ProductCard, AppDrawer)
- ✅ Tests des guards (AuthGuard)
- ✅ Tests des pages principales (Home, Catalog, Favorites)
- ✅ Tests de l'application principale
- ⚠️ Tests des services (en attente)
- ⚠️ Tests des repositories (en attente)

## 🎯 Bonnes Pratiques

1. **Isolation** : Chaque test est indépendant
2. **Mocks** : Utilisation de mocks pour les dépendances externes
3. **Coverage** : Viser une couverture de code > 80%
4. **Naming** : Noms de tests descriptifs et clairs
5. **Setup/Teardown** : Utilisation de setUp() et tearDown()

## 🐛 Débuggage des Tests

### Tests qui échouent

```bash
flutter test --reporter=verbose
```

### Tests spécifiques avec debug

```bash
flutter test test/widgets/product_card_test.dart --debug
```

### Générer un rapport de couverture HTML

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📈 Métriques de Qualité

- **Couverture de code** : > 80%
- **Tests qui passent** : 100%
- **Temps d'exécution** : < 30 secondes
- **Maintenabilité** : Code DRY et réutilisable

## 🔄 CI/CD

Les tests sont exécutés automatiquement :

- À chaque push sur la branche main
- À chaque pull request
- Avant chaque release

## 📚 Ressources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
