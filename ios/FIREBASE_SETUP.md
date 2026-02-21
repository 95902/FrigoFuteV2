# Firebase Setup per Flavor (iOS)

## ⚠️ Manual Configuration Required (Requires macOS + Xcode)

Cette configuration nécessite Xcode sur macOS pour créer les schemes iOS et configurer les flavors.

## Prérequis

- macOS avec Xcode 15+ installé
- CocoaPods installé (`sudo gem install cocoapods`)
- Comptes Apple Developer configurés
- Projets Firebase créés (frigofute-dev, frigofute-staging, frigofute-prod)

## Étapes de Configuration

### 1. Télécharger les fichiers GoogleService-Info.plist

Pour chaque projet Firebase (dev, staging, prod):

1. Aller dans Firebase Console → Project Settings
2. Ajouter une application iOS si pas déjà fait
3. Utiliser le Bundle ID correspondant:
   - Dev: `com.frigofute.dev`
   - Staging: `com.frigofute.staging`
   - Prod: `com.frigofute`
4. Télécharger le fichier `GoogleService-Info.plist`
5. Renommer et placer dans `ios/Runner/`:
   ```
   GoogleService-Info-dev.plist
   GoogleService-Info-staging.plist
   GoogleService-Info-prod.plist
   ```

### 2. Créer les Schemes Xcode (IMPORTANT)

Ouvrir `ios/Runner.xcworkspace` dans Xcode, puis:

#### Scheme: Dev
1. Product → Scheme → Manage Schemes
2. Dupliquer "Runner" → Nommer "dev"
3. Edit Scheme → Build Configuration: Debug
4. Dans Info.plist, configurer:
   ```xml
   <key>CFBundleIdentifier</key>
   <string>com.frigofute.dev</string>
   <key>CFBundleDisplayName</key>
   <string>FrigoFute DEV</string>
   ```

#### Scheme: Staging
1. Dupliquer "Runner" → Nommer "staging"
2. Edit Scheme → Build Configuration: Release
3. Dans Info.plist, configurer:
   ```xml
   <key>CFBundleIdentifier</key>
   <string>com.frigofute.staging</string>
   <key>CFBundleDisplayName</key>
   <string>FrigoFute STAGING</string>
   ```

#### Scheme: Prod
1. Dupliquer "Runner" → Nommer "prod"
2. Edit Scheme → Build Configuration: Release
3. Bundle ID reste: `com.frigofute`

### 3. Configurer Build Configurations

Dans Xcode Project Navigator:

1. Sélectionner "Runner" (projet)
2. Info tab → Configurations
3. Dupliquer "Debug" → Nommer "Debug-dev"
4. Dupliquer "Release" → Nommer "Release-staging"
5. Dupliquer "Release" → Nommer "Release-prod"

### 4. Configurer User-Defined Settings

Pour chaque configuration, ajouter:

**Debug-dev:**
```
FLAVOR = dev
PRODUCT_BUNDLE_IDENTIFIER = com.frigofute.dev
DISPLAY_NAME = FrigoFute DEV
FIREBASE_PLIST_PATH = GoogleService-Info-dev.plist
```

**Release-staging:**
```
FLAVOR = staging
PRODUCT_BUNDLE_IDENTIFIER = com.frigofute.staging
DISPLAY_NAME = FrigoFute STAGING
FIREBASE_PLIST_PATH = GoogleService-Info-staging.plist
```

**Release-prod:**
```
FLAVOR = prod
PRODUCT_BUNDLE_IDENTIFIER = com.frigofute
DISPLAY_NAME = FrigoFute
FIREBASE_PLIST_PATH = GoogleService-Info-prod.plist
```

### 5. Modifier Info.plist

Remplacer les valeurs hardcodées par les variables:

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

<key>CFBundleDisplayName</key>
<string>$(DISPLAY_NAME)</string>
```

### 6. Créer un Build Phase Script

Dans Xcode:

1. Build Phases → + → New Run Script Phase
2. Nommer "Copy Firebase Config"
3. Script:
```bash
#!/bin/sh

# Copy the appropriate GoogleService-Info.plist based on configuration
FIREBASE_PLIST="${PROJECT_DIR}/Runner/${FIREBASE_PLIST_PATH}"

if [ ! -f "$FIREBASE_PLIST" ]; then
    echo "error: Firebase plist not found: $FIREBASE_PLIST"
    exit 1
fi

# Copy to the build directory
cp "$FIREBASE_PLIST" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

echo "Using Firebase config: ${FIREBASE_PLIST_PATH}"
```

### 7. Mettre à jour Podfile

Ajouter support des configurations custom:

```ruby
# ios/Podfile
project 'Runner', {
  'Debug' => :debug,
  'Debug-dev' => :debug,
  'Release-staging' => :release,
  'Release-prod' => :release,
  'Profile' => :release,
}
```

### 8. Installer les Pods

```bash
cd ios
pod install --repo-update
cd ..
```

### 9. Tester les builds

```bash
# Dev (debug)
flutter build ios --flavor dev --debug --no-codesign

# Staging (release)
flutter build ios --flavor staging --release --no-codesign

# Prod (release)
flutter build ipa --flavor prod --release
```

## Configuration App Store Connect

### 1. Créer les App IDs

Dans Apple Developer Portal:

- `com.frigofute.dev` (Dev)
- `com.frigofute.staging` (Staging)
- `com.frigofute` (Prod - app principale)

### 2. Capabilities

Pour chaque App ID, activer:
- Associated Domains (deep linking)
- Push Notifications
- Sign in with Apple
- Cloud Firestore

### 3. Provisioning Profiles

Créer pour chaque flavor:
- Development provisioning profile (dev)
- Ad Hoc provisioning profile (staging)
- App Store provisioning profile (prod)

### 4. Fastlane Match (Recommandé)

Pour gérer les certificats et profiles:

```bash
cd ios
fastlane match init

# Development certificates
fastlane match development

# App Store certificates
fastlane match appstore
```

## Build Commands

```bash
# Local development (dev)
flutter run --flavor dev --debug

# Beta testing (staging)
flutter build ipa --flavor staging --release --export-options-plist=ios/ExportOptionsStaging.plist

# Production (prod)
flutter build ipa --flavor prod --release --obfuscate --split-debug-info=build/symbols/ios
```

## Troubleshooting

### Build échoue avec "No such module 'Firebase'"

```bash
cd ios
pod deintegrate
pod install --repo-update
```

### Code signing error

Vérifier dans Xcode:
- Signing & Capabilities → Team sélectionné
- Provisioning Profile correct pour le flavor
- Bundle ID correspond

### GoogleService-Info.plist not found

Vérifier:
- Le fichier existe dans `ios/Runner/`
- Le nom correspond à `FIREBASE_PLIST_PATH` dans Build Settings
- Le script "Copy Firebase Config" s'exécute

## État actuel

⚠️ **Configuration iOS incomplète - Nécessite macOS**

✅ **Complété:**
- Documentation créée
- Structure de fichiers préparée
- .gitignore configuré

⏳ **Requis sur macOS:**
- Créer schemes Xcode (dev, staging, prod)
- Configurer Build Configurations
- Télécharger et placer GoogleService-Info.plist
- Créer provisioning profiles
- Tester builds iOS

## Référence

- [iOS Flavors in Flutter](https://docs.flutter.dev/deployment/flavors#ios)
- [Xcode Schemes](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
