# Firebase Setup per Flavor (Android)

## ⚠️ Manual Configuration Required

Cette configuration nécessite la création de 3 projets Firebase distincts et le téléchargement de leurs fichiers `google-services.json`.

## Étapes de Configuration

### 1. Créer les projets Firebase

Créer 3 projets dans [Firebase Console](https://console.firebase.google.com/):

| Flavor | Project Name | Package Name |
|--------|--------------|--------------|
| dev | frigofute-dev | com.frigofute.frigofute_v2.dev |
| staging | frigofute-staging | com.frigofute.frigofute_v2.staging |
| prod | frigofute-prod | com.frigofute.frigofute_v2 |

### 2. Configurer chaque projet Firebase

Pour **chaque** projet:
1. Ajouter une application Android
2. Utiliser le package name correspondant (voir tableau ci-dessus)
3. Télécharger le fichier `google-services.json`
4. Activer les services:
   - ✅ Authentication (Email/Password, Google Sign-In)
   - ✅ Firestore Database
   - ✅ Cloud Storage
   - ✅ Crashlytics
   - ✅ Performance Monitoring
   - ✅ Remote Config (pour feature flags)
   - ✅ App Distribution (pour staging seulement)

### 3. Placer les fichiers google-services.json

Copier les fichiers téléchargés dans les répertoires appropriés:

```bash
# Dev flavor
cp ~/Downloads/google-services-dev.json android/app/src/dev/google-services.json

# Staging flavor
cp ~/Downloads/google-services-staging.json android/app/src/staging/google-services.json

# Prod flavor
cp ~/Downloads/google-services-prod.json android/app/src/prod/google-services.json
```

### 4. Vérifier la structure

```
android/app/src/
├── dev/
│   └── google-services.json          # Package: com.frigofute.frigofute_v2.dev
├── staging/
│   └── google-services.json          # Package: com.frigofute.frigofute_v2.staging
├── prod/
│   └── google-services.json          # Package: com.frigofute.frigofute_v2
└── main/
    ├── AndroidManifest.xml
    └── ...
```

### 5. Générer Firebase options Dart (FlutterFire CLI)

Pour chaque flavor, générer les fichiers de configuration:

```bash
# Dev flavor
flutterfire configure \
  --project=frigofute-dev \
  --out=lib/firebase_options_dev.dart \
  --platforms=android,ios

# Staging flavor
flutterfire configure \
  --project=frigofute-staging \
  --out=lib/firebase_options_staging.dart \
  --platforms=android,ios

# Prod flavor
flutterfire configure \
  --project=frigofute-prod \
  --out=lib/firebase_options_prod.dart \
  --platforms=android,ios
```

### 6. Mettre à jour main.dart

Charger les options Firebase appropriées selon le flavor:

```dart
// lib/main.dart
import 'firebase_options_dev.dart' as firebase_dev;
import 'firebase_options_staging.dart' as firebase_staging;
import 'firebase_options_prod.dart' as firebase_prod;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Détecter le flavor via environment
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  final firebaseOptions = switch (flavor) {
    'staging' => firebase_staging.DefaultFirebaseOptions.currentPlatform,
    'prod' => firebase_prod.DefaultFirebaseOptions.currentPlatform,
    _ => firebase_dev.DefaultFirebaseOptions.currentPlatform,
  };

  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MyApp());
}
```

### 7. Tester les builds

```bash
# Dev
flutter build apk --flavor dev --debug

# Staging
flutter build apk --flavor staging --release

# Prod
flutter build appbundle --flavor prod --release --obfuscate
```

## ⚠️ Important - .gitignore

Les fichiers `google-services.json` ne doivent **JAMAIS** être commis:

```gitignore
# Android flavor-specific Firebase configs
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/prod/google-services.json

# iOS flavor-specific Firebase configs
ios/Runner/GoogleService-Info-dev.plist
ios/Runner/GoogleService-Info-staging.plist
ios/Runner/GoogleService-Info-prod.plist

# Dart Firebase options (generated)
lib/firebase_options_dev.dart
lib/firebase_options_staging.dart
lib/firebase_options_prod.dart
```

## État actuel

✅ **Complété:**
- Structure de répertoires créée
- Build flavors configurés dans build.gradle.kts
- Documentation créée

⏳ **Requis manuellement:**
- Créer 3 projets Firebase (dev, staging, prod)
- Télécharger et placer les google-services.json
- Générer firebase_options_*.dart avec FlutterFire CLI
- Configurer GitHub Secrets avec les clés Firebase

## Référence

- [FlutterFire Setup](https://firebase.flutter.dev/docs/overview)
- [Android Build Flavors](https://docs.flutter.dev/deployment/flavors)
