# State Management dans l'Application

## Vue d'ensemble

L'application utilise **le state management natif de Flutter** sans bibliothèques externes comme Provider, Bloc, Riverpod, GetX, etc.

## Patterns utilisés

### 1. **StatefulWidget + setState()** (Principal)

C'est le pattern principal utilisé dans toute l'application pour gérer l'état local des widgets.

**Exemples :**
- `LoginPage` : Gère `_isLoading`, `_obscurePassword`
- `RegisterPage` : Gère `_isLoading`, `_obscurePassword`, `_obscureConfirmPassword`
- `ProfilePage` : Gère `_currentUser`, `_isLoading`, `_isUploadingImage`
- `ExercisesListPage` : Gère `_exercises`, `_isLoading`, `_searchQuery`, `_selectedBodyParts`, etc.
- `HomePage` : Gère `_currentUser`
- `EmailVerificationPage` : Gère `_isLoading`, `_isSendingEmail`, `_currentUser`

**Avantages :**
- ✅ Simple et natif (pas de dépendances externes)
- ✅ Parfait pour l'état local des widgets
- ✅ Facile à comprendre et maintenir
- ✅ Performant pour des cas d'usage simples

**Inconvénients :**
- ❌ Peut devenir verbeux pour des états complexes
- ❌ Pas de partage d'état entre widgets distants sans props drilling

### 2. **StreamBuilder** (Pour l'authentification)

Utilisé pour écouter les changements d'état d'authentification en temps réel.

**Exemple : `AuthWrapper`**
```dart
return StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    // Reconstruit automatiquement quand l'état d'authentification change
    if (user != null) {
      return MainNavigationPage();
    }
    return LoginPage();
  },
);
```

**Autres utilisations :**
- `ProfilePage` écoute `authStateChanges` avec `.listen()` pour mettre à jour `_currentUser`

**Avantages :**
- ✅ Réactif : mise à jour automatique quand l'état change
- ✅ Parfait pour les streams Firebase
- ✅ Pas besoin de `setState()` manuel

### 3. **Service Locator (Dependency Injection)**

Utilisé pour injecter les dépendances (services, repositories) dans toute l'application.

**Fichier : `lib/di/service_locator.dart`**

**Services injectés :**
- `AuthService` : Gestion de l'authentification Firebase
- `StorageService` (MinIOStorageService) : Gestion du stockage d'images
- `ExerciseRepository` : Accès aux exercices
- `DatabaseService` : Accès à la base de données SQLite

**Utilisation :**
```dart
final authService = ServiceLocator.instance.authService;
final result = await authService.signIn(email: email, password: password);
```

**Avantages :**
- ✅ Accès global aux services
- ✅ Facile à tester (peut être mocké)
- ✅ Pas de props drilling

### 4. **StatelessWidget** (Pour les widgets sans état)

Utilisés pour les widgets qui n'ont pas besoin d'état local.

**Exemples :**
- `ExerciseListItem` : Affiche un exercice (reçoit les données en props)
- `ExerciseCard` : Carte d'exercice (reçoit les données en props)
- `TrainingCard` : Carte d'entraînement (reçoit les données en props)
- `ExerciseDetailBottomSheet` : Bottom sheet statique (reçoit l'exercice en paramètre)

## Architecture globale

```
┌─────────────────────────────────────────┐
│         UI Layer (Widgets)              │
│  ┌───────────────────────────────────┐   │
│  │  StatefulWidget + setState()     │   │
│  │  (État local des pages)          │   │
│  └───────────────────────────────────┘   │
│  ┌───────────────────────────────────┐   │
│  │  StreamBuilder                    │   │
│  │  (Authentification réactive)      │   │
│  └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      Service Layer                     │
│  ┌───────────────────────────────────┐ │
│  │  Service Locator                  │ │
│  │  (Injection de dépendances)       │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │  AuthService                      │ │
│  │  StorageService                   │ │
│  │  ExerciseRepository               │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      Data Layer                         │
│  ┌───────────────────────────────────┐ │
│  │  Firebase Auth                    │ │
│  │  Firestore                        │ │
│  │  SQLite (DatabaseService)         │ │
│  │  MinIO Storage                    │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Pourquoi ce choix ?

### ✅ Avantages de cette approche :

1. **Simplicité** : Pas de courbe d'apprentissage pour des bibliothèques externes
2. **Performance** : Pas de overhead de bibliothèques tierces
3. **Maintenabilité** : Code plus simple à comprendre et déboguer
4. **Compatibilité** : Fonctionne avec toutes les versions de Flutter
5. **Taille de l'APK** : Plus petite (pas de dépendances externes)

### ⚠️ Limitations actuelles :

1. **Props drilling** : Pour partager l'état entre widgets distants, il faut passer les props
2. **État global** : Pas de solution centralisée pour l'état global (mais pas nécessaire pour cette app)
3. **Complexité** : Peut devenir verbeux pour des états très complexes

## Quand migrer vers un state management externe ?

Vous pourriez considérer **Provider**, **Riverpod**, ou **Bloc** si :

- ❌ Vous avez besoin de partager l'état entre de nombreux widgets distants
- ❌ L'état devient très complexe et difficile à gérer avec `setState()`
- ❌ Vous avez besoin de middleware (logging, persistance, etc.)
- ❌ Vous voulez une séparation plus stricte entre UI et logique métier

**Pour cette application actuelle**, le state management natif est **parfaitement adapté** car :
- ✅ L'état est principalement local aux pages
- ✅ L'authentification utilise déjà des streams (StreamBuilder)
- ✅ Les services sont injectés via Service Locator
- ✅ Pas de besoin d'état global complexe

## Résumé

| Pattern | Usage | Fichiers |
|---------|-------|----------|
| **StatefulWidget + setState()** | État local des pages | Toutes les pages principales |
| **StreamBuilder** | Authentification réactive | `AuthWrapper` |
| **Service Locator** | Injection de dépendances | `ServiceLocator`, utilisé partout |
| **StatelessWidget** | Widgets sans état | Widgets de présentation |

**Conclusion** : L'application utilise une approche **simple et efficace** avec le state management natif de Flutter, parfaitement adaptée à ses besoins actuels.

