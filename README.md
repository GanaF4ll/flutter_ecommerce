# Flutter E-commerce

Une application e-commerce complète développée avec Flutter, supportant les plateformes mobile et web avec Firebase pour l'authentification.

## Fonctionnalités

- 🛍️ Catalogue de produits avec recherche et filtres
- 🛒 Panier d'achat persistant (SQLite sur mobile, localStorage sur web)
- ❤️ Liste de favoris
- 🔐 Authentification Firebase (inscription/connexion)
- 📱 Support multi-plateforme (iOS, Android, Web)
- 🎨 Interface moderne avec Material Design 3

## Installation

1. Clonez le repository :

```bash
git clone <url-du-repo>
cd flutter_ecommerce
```

2. Installez les dépendances :

```bash
flutter pub get
```

3. Configurez Firebase (optionnel pour les tests locaux) :
   - Ajoutez vos fichiers de configuration Firebase
   - Suivez la documentation officielle Firebase pour Flutter

## Commandes de lancement

### Lancer l'application web

```bash
flutter run -d chrome
# ou pour un build optimisé
flutter build web
flutter run -d web-server --web-port 8080
```

### Lancer sur mobile (Android)

```bash
flutter run -d android
```

### Lancer sur mobile (iOS)

```bash
flutter run -d ios
```

## Tests

### Lancer tous les tests

```bash
flutter test
```

### Lancer les tests avec couverture

```bash
flutter test --coverage
```

### Lancer les tests d'intégration

```bash
flutter test integration_test/
```

### Lancer un test spécifique

```bash
flutter test test/entities/product_test.dart
```

## Structure du projet

```
lib/
├── data/           # Données JSON (produits, catégories)
├── entities/       # Modèles de données
├── guards/         # Guards d'authentification
├── pages/          # Pages de l'application
├── repositories/   # Couche d'accès aux données
├── services/       # Logique métier
└── widgets/        # Composants réutilisables
```

## Technologies utilisées

- **Flutter** - Framework de développement
- **Firebase Auth** - Authentification
- **SQLite** - Base de données locale (mobile)
- **SharedPreferences** - Stockage local (web)
- **Material Design 3** - Interface utilisateur

## Build de production

### Web

```bash
flutter build web --release
```

### Android

```bash
flutter build apk --release
# ou pour un App Bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```
