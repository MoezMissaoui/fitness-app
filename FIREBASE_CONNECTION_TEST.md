# Guide de Vérification de la Connexion Firebase

Ce guide vous explique comment vérifier que votre application est correctement connectée à Firebase.

## 🔍 Méthodes de Vérification

### 1. Vérification Automatique au Démarrage

L'application teste automatiquement la connexion Firebase au démarrage en mode debug.

**Ce que vous verrez dans la console :**

```
✅ Firebase initialisé avec succès

📱 Informations Firebase:
   App Name: [DEFAULT]
   Project ID: fitness-app-4f62a
   API Key: AIzaSyCuOp...
   App ID: 1:1014304523758:android:...
   Storage Bucket: fitness-app-4f62a.firebasestorage.app
   Messaging Sender ID: 1014304523758

🔍 Test de connexion Firebase...

✅ Firebase app instance: [DEFAULT]
✅ Firebase project ID: fitness-app-4f62a
✅ Firebase Auth connecté
   Utilisateur actuel: Aucun
✅ Firestore connecté
   Cache size: 104857600
✅ Test de lecture Firestore réussi

📊 Résumé des tests:
   ✅ Basic Connection: OK
   ✅ Firebase Auth: OK
   ✅ Firestore: OK
   ✅ Firestore Read: OK

🎉 Tous les tests de connexion Firebase ont réussi!
```

### 2. Vérification Manuelle dans le Code

Vous pouvez tester la connexion Firebase manuellement dans votre code :

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase/firebase_connection_test.dart';

// Test rapide
bool isConnected = FirebaseConnectionTest.isConnected();
print('Firebase connecté: $isConnected');

// Test complet
final results = await FirebaseConnectionTest.testAllConnections();
// results contient: {'Basic Connection': true, 'Firebase Auth': true, ...}

// Afficher les informations Firebase
FirebaseConnectionTest.printFirebaseInfo();
```

### 3. Test de l'Authentification

Testez que l'authentification fonctionne :

```dart
import 'di/service_locator.dart';

// Obtenir le service d'authentification
final authService = ServiceLocator.instance.authService;

// Vérifier l'état de connexion
print('Utilisateur connecté: ${authService.isAuthenticated}');
print('Utilisateur actuel: ${authService.currentUser?.email ?? 'Aucun'}');

// Tester l'inscription (créer un compte de test)
final result = await authService.signUp(
  email: 'test@example.com',
  password: 'test123456',
  displayName: 'Test User',
);

if (result.isSuccess) {
  print('✅ Inscription réussie!');
  print('   Email: ${result.data?.email}');
  print('   UID: ${result.data?.uid}');
} else {
  print('❌ Erreur: ${result.error}');
}
```

### 4. Vérification dans Firebase Console

1. **Allez sur [Firebase Console](https://console.firebase.google.com/)**
2. **Sélectionnez votre projet** : `fitness-app-4f62a`
3. **Vérifiez les sections suivantes** :

   **Authentication → Users** :
   - Si vous avez créé un utilisateur de test, il devrait apparaître ici
   - Vérifiez que l'email et l'UID sont corrects

   **Firestore Database → Data** :
   - Si vous avez créé un utilisateur, vérifiez la collection `users`
   - Vous devriez voir un document avec l'UID de l'utilisateur

   **Project Settings → Your apps** :
   - Vérifiez que l'app Android est bien enregistrée
   - Vérifiez que le package name correspond : `com.example.fitness_app`

## ✅ Checklist de Vérification

### Au Démarrage de l'App

- [ ] Console affiche "✅ Firebase initialisé avec succès"
- [ ] Les informations Firebase sont affichées (Project ID, App ID, etc.)
- [ ] Tous les tests de connexion passent (✅ pour chaque test)
- [ ] Aucune erreur dans la console

### Test d'Authentification

- [ ] `authService.isAuthenticated` retourne `false` (si pas connecté)
- [ ] `authService.currentUser` retourne `null` (si pas connecté)
- [ ] L'inscription d'un utilisateur de test fonctionne
- [ ] L'utilisateur apparaît dans Firebase Console → Authentication → Users
- [ ] Le document utilisateur est créé dans Firestore → users

### Vérification Firebase Console

- [ ] L'app Android est enregistrée dans Project Settings
- [ ] Le package name correspond : `com.example.fitness_app`
- [ ] Authentication est activé (Email/Password)
- [ ] Les utilisateurs créés apparaissent dans Authentication → Users
- [ ] Les documents utilisateurs apparaissent dans Firestore → users

## 🐛 Problèmes Courants

### Erreur: "Firebase app not initialized"

**Solution** :
- Vérifiez que `initializeFirebase()` est appelé dans `main()` AVANT `runApp()`
- Vérifiez que `firebase_options.dart` contient de vraies valeurs (pas des placeholders)

### Erreur: "PlatformException" ou "Unable to establish connection"

**Solution** :
- Vérifiez que `google-services.json` est dans `android/app/`
- Vérifiez que Google Services plugin est configuré dans les fichiers Gradle
- Exécutez `flutter clean` et reconstruisez

### Test Firestore Read échoue

**Solution** :
- Vérifiez votre connexion internet
- Vérifiez que Firestore est activé dans Firebase Console
- Vérifiez les règles de sécurité Firestore (elles peuvent bloquer les lectures)

### Auth Service retourne null

**Solution** :
- Vérifiez que `ServiceLocator.instance.init()` est appelé après `initializeFirebase()`
- Vérifiez que `AuthService` est bien ajouté au `ServiceLocator`

## 📱 Test Complet Recommandé

Créez un utilisateur de test pour vérifier que tout fonctionne :

```dart
// Dans votre code (par exemple dans une page de test)
final authService = ServiceLocator.instance.authService;

// 1. Tester l'inscription
final signUpResult = await authService.signUp(
  email: 'test@example.com',
  password: 'test123456',
  displayName: 'Test User',
);

if (signUpResult.isSuccess) {
  print('✅ Inscription réussie');
  
  // 2. Vérifier dans Firebase Console
  // Allez dans Authentication → Users
  // Vous devriez voir test@example.com
  
  // 3. Vérifier Firestore
  // Allez dans Firestore → Data
  // Vous devriez voir un document dans la collection 'users'
  
  // 4. Tester la déconnexion
  await authService.signOut();
  print('✅ Déconnexion réussie');
}
```

## 🎯 Signes que Firebase est Correctement Connecté

✅ **Console affiche** :
- "✅ Firebase initialisé avec succès"
- Tous les tests passent
- Aucune erreur

✅ **Code fonctionne** :
- `Firebase.app()` ne lance pas d'exception
- `FirebaseAuth.instance` est accessible
- `FirebaseFirestore.instance` est accessible
- `ServiceLocator.instance.authService` fonctionne

✅ **Firebase Console** :
- L'app Android est enregistrée
- Authentication est activé
- Les utilisateurs créés apparaissent
- Les données Firestore sont créées

## 📚 Ressources

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## 💡 Astuce

Pour désactiver les tests automatiques au démarrage (si vous voulez plus de performance), modifiez `main.dart` :

```dart
// Désactiver les tests (plus rapide au démarrage)
await initializeFirebase(testConnection: false);

// Ou activer les tests (recommandé en développement)
await initializeFirebase(testConnection: true);
```

Par défaut, les tests sont activés en mode debug pour vous aider à vérifier la connexion.

