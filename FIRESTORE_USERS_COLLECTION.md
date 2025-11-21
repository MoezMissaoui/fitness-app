# Gestion automatique de la collection `users` dans Firestore

## Vue d'ensemble

La collection `users` dans Firestore est **créée automatiquement** lors de la première inscription d'un utilisateur. Aucune configuration manuelle n'est nécessaire.

## Comment ça fonctionne ?

### 1. Création automatique lors de l'inscription

Quand un utilisateur s'inscrit via `AuthService.signUp()` :

```dart
// Le code crée automatiquement :
// - La collection 'users' (si elle n'existe pas)
// - Le document utilisateur avec l'UID comme ID du document
await _firestore
    .collection('users')
    .doc(user.uid)
    .set(userModel.toMap());
```

**Firestore crée automatiquement la collection** si elle n'existe pas lors de la première écriture.

### 2. Structure du document utilisateur

Chaque document dans la collection `users` a la structure suivante :

```json
{
  "uid": "5rQFh6vz7VhbPwOurPxlCuH...",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": 1735689600000,
  "lastLoginAt": 1735689600000,
  "maxTemplates": 3
}
```

### 3. ID du document

- **ID du document** = `uid` de l'utilisateur Firebase Auth
- Cela garantit un document unique par utilisateur
- Facilite la récupération : `users/{uid}`

## Opérations automatiques

### ✅ Création lors de l'inscription

```dart
// Dans AuthService.signUp()
await _firestore
    .collection('users')
    .doc(user.uid)
    .set(userModel.toMap());
```

### ✅ Création lors de la connexion (migration)

Si un utilisateur existe dans Firebase Auth mais pas dans Firestore :

```dart
// Dans AuthService.signIn()
if (!userDoc.exists) {
  // Créer automatiquement le document
  await _firestore
      .collection('users')
      .doc(user.uid)
      .set(userModel.toMap());
}
```

### ✅ Mise à jour du profil

```dart
// Dans AuthService.updateProfile()
await _firestore
    .collection('users')
    .doc(user.uid)
    .set(updateData, SetOptions(merge: true));
```

### ✅ Mise à jour de la dernière connexion

```dart
// Dans AuthService._updateLastLogin()
await _firestore
    .collection('users')
    .doc(uid)
    .set({'lastLoginAt': timestamp}, SetOptions(merge: true));
```

## Gestion des erreurs

Le code gère gracieusement les erreurs Firestore :

- ✅ Si Firestore n'est pas configuré, l'application continue de fonctionner
- ✅ L'utilisateur est toujours créé dans Firebase Auth
- ✅ Des logs de debug sont affichés pour aider au diagnostic

## Vérification dans Firebase Console

Pour vérifier que la collection est créée :

1. Allez dans **Firebase Console** > **Firestore Database**
2. La collection `users` devrait apparaître après la première inscription
3. Cliquez sur `users` pour voir tous les documents utilisateur

## Règles de sécurité Firestore (Recommandé)

Pour sécuriser la collection `users`, ajoutez ces règles dans Firebase Console > Firestore > Rules :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection users : les utilisateurs peuvent lire/écrire uniquement leur propre document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Migration des utilisateurs existants

Si vous avez des utilisateurs existants dans Firebase Auth mais pas dans Firestore :

1. **Automatique** : Lors de leur prochaine connexion, le document sera créé automatiquement
2. **Manuel** : Vous pouvez créer les documents manuellement dans Firebase Console

## Résumé

| Action | Collection `users` | Document utilisateur |
|--------|-------------------|---------------------|
| **Inscription** | ✅ Créée automatiquement | ✅ Créé avec `uid` comme ID |
| **Connexion** | ✅ Créée si nécessaire | ✅ Créé si n'existe pas (migration) |
| **Mise à jour profil** | ✅ Existe déjà | ✅ Mis à jour |
| **Dernière connexion** | ✅ Existe déjà | ✅ Mis à jour |

**Conclusion** : La collection `users` est **entièrement gérée automatiquement** par le code. Aucune action manuelle n'est nécessaire !

