# Guide d'Ajout d'iOS à Firebase

Ce guide vous explique comment ajouter la configuration iOS à votre projet Firebase quand vous serez prêt à développer pour iOS.

## 📋 Prérequis

- Un Mac avec Xcode installé
- Un compte développeur Apple (gratuit pour le développement)
- Un projet iOS configuré dans Flutter
- Firebase project déjà créé avec Android configuré

## 🚀 Étapes pour Ajouter iOS

### Étape 1: Obtenir le Bundle ID iOS

1. Ouvrez votre projet Flutter
2. Naviguez vers `ios/Runner/Info.plist`
3. Cherchez la clé `CFBundleIdentifier` ou vérifiez dans Xcode
4. Le Bundle ID ressemble à : `com.example.fitness_app` ou `com.yourcompany.fitnessapp`

**Alternative - Vérifier dans Xcode :**
```bash
# Ouvrir le projet iOS dans Xcode
open ios/Runner.xcworkspace
```
- Dans Xcode, sélectionnez le projet "Runner" dans le navigateur
- Allez dans l'onglet "General"
- Le "Bundle Identifier" est affiché sous "Identity"

### Étape 2: Ajouter l'App iOS dans Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet : **fitness-app-4f62a**
3. Cliquez sur l'icône **⚙️ (Settings)** → **Project settings**
4. Faites défiler jusqu'à la section **"Your apps"**
5. Cliquez sur l'icône **iOS** (ou le bouton **"Add app"** si c'est la première fois)
6. Remplissez le formulaire :
   - **iOS bundle ID** : Entrez le Bundle ID trouvé à l'étape 1
     - Exemple : `com.example.fitness_app`
   - **App nickname** (optionnel) : "Fitness App iOS"
   - **App Store ID** (optionnel) : Laissez vide pour l'instant
7. Cliquez sur **"Register app"**

### Étape 3: Télécharger GoogleService-Info.plist

1. Après avoir enregistré l'app, Firebase vous proposera de télécharger `GoogleService-Info.plist`
2. **Téléchargez le fichier** (ne le fermez pas, vous en aurez besoin)
3. **Important** : Ne modifiez pas le nom du fichier, il doit rester `GoogleService-Info.plist`

### Étape 4: Ajouter GoogleService-Info.plist au Projet

#### Option A: Via Xcode (Recommandé)

1. **Ouvrir le projet dans Xcode** :
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **Important** : Utilisez `.xcworkspace`, pas `.xcodeproj`

2. Dans Xcode :
   - Faites un clic droit sur le dossier **"Runner"** dans le navigateur de projet (panneau de gauche)
   - Sélectionnez **"Add Files to Runner..."**
   - Naviguez vers le fichier `GoogleService-Info.plist` que vous avez téléchargé
   - **Cochez** :
     - ✅ "Copy items if needed"
     - ✅ "Add to targets: Runner"
   - Cliquez sur **"Add"**

3. **Vérifier** :
   - Le fichier `GoogleService-Info.plist` doit apparaître dans le navigateur Xcode sous "Runner"
   - Il doit être dans le groupe "Runner" (pas dans un sous-dossier)

#### Option B: Via Terminal (Alternative)

1. **Copier le fichier** :
   ```bash
   # Depuis le répertoire racine du projet Flutter
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
   ```
   (Ajustez le chemin selon où vous avez téléchargé le fichier)

2. **Vérifier** :
   ```bash
   ls ios/Runner/GoogleService-Info.plist
   ```
   Le fichier doit exister.

### Étape 5: Configurer Firebase Options pour iOS

Vous avez deux options :

#### Option A: Utiliser FlutterFire CLI (Recommandé - Plus Facile)

1. **Installer FlutterFire CLI** (si pas déjà fait) :
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configurer Firebase** :
   ```bash
   flutterfire configure
   ```

3. **Sélectionner** :
   - Votre projet Firebase : `fitness-app-4f62a`
   - **Plates-formes** : Cochez **Android** ET **iOS**
   - Le CLI va automatiquement :
     - Détecter `google-services.json` (Android)
     - Détecter `GoogleService-Info.plist` (iOS)
     - Mettre à jour `lib/core/firebase/firebase_options.dart` avec les vraies valeurs

4. **Vérifier** :
   - Ouvrez `lib/core/firebase/firebase_options.dart`
   - La section `ios` doit maintenant contenir de vraies valeurs (pas des placeholders)

#### Option B: Configuration Manuelle

Si vous préférez configurer manuellement :

1. **Ouvrir `GoogleService-Info.plist`** (c'est un fichier XML/plist)

2. **Extraire les valeurs** :
   - `API_KEY` → `apiKey` dans firebase_options.dart
   - `GCM_SENDER_ID` → `messagingSenderId`
   - `PROJECT_ID` → `projectId`
   - `STORAGE_BUCKET` → `storageBucket`
   - `GOOGLE_APP_ID` → `appId`
   - `BUNDLE_ID` → `iosBundleId`

3. **Mettre à jour `lib/core/firebase/firebase_options.dart`** :
   ```dart
   static const FirebaseOptions ios = FirebaseOptions(
     apiKey: 'AIzaSy...',  // API_KEY du plist
     appId: '1:1014304523758:ios:...',  // GOOGLE_APP_ID
     messagingSenderId: '1014304523758',  // GCM_SENDER_ID
     projectId: 'fitness-app-4f62a',  // PROJECT_ID
     storageBucket: 'fitness-app-4f62a.firebasestorage.app',  // STORAGE_BUCKET
     iosBundleId: 'com.example.fitness_app',  // BUNDLE_ID
   );
   ```

### Étape 6: Installer les Pods iOS

1. **Naviguer vers le dossier iOS** :
   ```bash
   cd ios
   ```

2. **Installer les pods** :
   ```bash
   pod install
   ```

3. **Revenir au répertoire racine** :
   ```bash
   cd ..
   ```

### Étape 7: Vérifier la Configuration

1. **Vérifier les fichiers** :
   ```bash
   # Vérifier que GoogleService-Info.plist existe
   ls ios/Runner/GoogleService-Info.plist
   
   # Vérifier que firebase_options.dart a des valeurs iOS réelles
   grep -A 5 "static const FirebaseOptions ios" lib/core/firebase/firebase_options.dart
   ```

2. **Nettoyer et reconstruire** :
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```

3. **Tester sur iOS** :
   ```bash
   # Sur un simulateur iOS
   flutter run -d ios
   
   # Ou sur un appareil iOS physique
   flutter run -d <device-id>
   ```

## ✅ Checklist de Vérification

Avant de tester sur iOS, vérifiez :

- [ ] App iOS ajoutée dans Firebase Console
- [ ] `GoogleService-Info.plist` téléchargé
- [ ] `GoogleService-Info.plist` ajouté au projet Xcode (dans le groupe Runner)
- [ ] `firebase_options.dart` mis à jour avec les vraies valeurs iOS (via `flutterfire configure` ou manuellement)
- [ ] `pod install` exécuté dans le dossier `ios/`
- [ ] Bundle ID dans Firebase Console correspond au Bundle ID dans Xcode
- [ ] Authentication activée dans Firebase Console (Email/Password)

## 🐛 Dépannage iOS

### Erreur: "GoogleService-Info.plist not found"

**Solution** :
- Vérifiez que le fichier est dans `ios/Runner/GoogleService-Info.plist`
- Vérifiez qu'il est ajouté au projet Xcode (pas seulement copié dans le dossier)
- Dans Xcode, vérifiez que le fichier est dans le "Target Membership" pour "Runner"

### Erreur: "No such module 'FirebaseCore'"

**Solution** :
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Erreur: "Bundle ID mismatch"

**Solution** :
- Vérifiez que le Bundle ID dans Firebase Console correspond exactement au Bundle ID dans Xcode
- Les Bundle IDs sont sensibles à la casse
- Vérifiez dans Xcode : Project → General → Bundle Identifier

### Erreur: "Firebase initialization failed"

**Solution** :
- Vérifiez que `firebase_options.dart` contient de vraies valeurs iOS (pas des placeholders)
- Vérifiez que `GoogleService-Info.plist` est correctement ajouté au projet
- Vérifiez les logs Xcode pour plus de détails

### Pod Installation Fails

**Solution** :
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..
```

## 📱 Tester l'Authentification sur iOS

Une fois configuré, testez avec :

```dart
// Dans votre code Flutter
final authService = ServiceLocator.instance.authService;

// Test d'inscription
final result = await authService.signUp(
  email: 'test@example.com',
  password: 'password123',
  displayName: 'Test User',
);

if (result.isSuccess) {
  print('✅ Inscription réussie sur iOS!');
} else {
  print('❌ Erreur: ${result.error}');
}
```

## 🔄 Mise à Jour de la Configuration

Si vous devez mettre à jour la configuration iOS plus tard :

1. Re-téléchargez `GoogleService-Info.plist` depuis Firebase Console
2. Remplacez l'ancien fichier dans `ios/Runner/`
3. Exécutez `flutterfire configure` pour mettre à jour `firebase_options.dart`

## 📚 Ressources Utiles

- [Firebase iOS Setup Documentation](https://firebase.google.com/docs/ios/setup)
- [FlutterFire iOS Setup](https://firebase.flutter.dev/docs/overview#ios)
- [Xcode Documentation](https://developer.apple.com/xcode/)

## 💡 Notes Importantes

1. **Xcode requis** : Le développement iOS nécessite un Mac avec Xcode
2. **Bundle ID unique** : Le Bundle ID doit être unique et correspondre exactement entre Firebase et Xcode
3. **GoogleService-Info.plist** : Ne modifiez jamais ce fichier manuellement
4. **Pods** : Exécutez toujours `pod install` après avoir ajouté/modifié des dépendances iOS
5. **Simulateur vs Appareil** : Vous pouvez tester sur le simulateur iOS, mais certaines fonctionnalités nécessitent un appareil physique

## ✅ Résumé Rapide

Quand vous serez prêt pour iOS :

1. Ajouter l'app iOS dans Firebase Console
2. Télécharger `GoogleService-Info.plist`
3. L'ajouter au projet Xcode
4. Exécuter `flutterfire configure` (sélectionner Android + iOS)
5. Exécuter `pod install` dans `ios/`
6. Tester avec `flutter run -d ios`

C'est tout ! Votre app fonctionnera sur Android et iOS avec la même configuration Firebase. 🎉

