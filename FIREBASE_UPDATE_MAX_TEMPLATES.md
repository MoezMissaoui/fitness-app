# Comment modifier `maxTemplates` depuis Firebase

## ⚠️ Important : La collection `users` n'existe pas encore ?

**C'est normal !** La collection `users` sera créée **automatiquement** lors de la première inscription d'un utilisateur dans l'application.

### Option A : Créer un compte de test (Recommandé)
1. Lancez l'application
2. Inscrivez-vous avec un compte de test
3. La collection `users` sera créée automatiquement avec le document de l'utilisateur
4. Vous pourrez ensuite modifier `maxTemplates` dans Firestore

### Option B : Créer manuellement la collection (Pour tester)
1. Dans Firebase Console > Firestore Database
2. Cliquez sur **"Commencer une collection"** (Start collection)
3. Collection ID : `users`
4. Document ID : Laissez Firebase générer un ID ou utilisez un ID personnalisé
5. Ajoutez les champs :
   - `uid` (string) : `test-user-123`
   - `email` (string) : `test@example.com`
   - `displayName` (string) : `Test User`
   - `maxTemplates` (number) : `3`
   - `createdAt` (number) : `1735689600000` (timestamp actuel en millisecondes)
   - `lastLoginAt` (number) : `1735689600000`
6. Cliquez sur **"Enregistrer"** (Save)

## Méthode 1 : Via la Console Firebase (Recommandé)

### Étapes :

1. **Accéder à Firebase Console**
   - Allez sur [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Sélectionnez votre projet `fitness-app-4f62a`

2. **Ouvrir Firestore Database**
   - Dans le menu de gauche, cliquez sur **"Firestore Database"**
   - Si ce n'est pas encore activé, activez-le en mode test

3. **Trouver la collection `users`**
   - Si la collection existe déjà, cliquez sur **`users`** dans la liste des collections
   - Vous verrez tous les documents utilisateur (identifiés par leur `uid`)
   - Si la collection n'existe pas, suivez l'**Option A** ou **Option B** ci-dessus

4. **Sélectionner un utilisateur**
   - Cliquez sur le document de l'utilisateur que vous voulez modifier
   - Le document s'ouvrira avec tous ses champs

5. **Modifier le champ `maxTemplates`**
   - Si le champ `maxTemplates` existe déjà :
     - Cliquez sur la valeur actuelle
     - Modifiez-la (par exemple, changez `3` en `5`)
     - Appuyez sur **Entrée** ou cliquez ailleurs
   - Si le champ n'existe pas :
     - Cliquez sur **"Add field"** (Ajouter un champ)
     - Nom du champ : `maxTemplates`
     - Type : `number` (nombre)
     - Valeur : `3` (ou la valeur souhaitée)
     - Cliquez sur **"Done"**

6. **Sauvegarder**
   - Les modifications sont automatiquement sauvegardées dans Firestore

## Méthode 2 : Via le code (Optionnel)

Si vous voulez créer une méthode dans l'application pour mettre à jour cette valeur, vous pouvez ajouter cette méthode dans `AuthService` :

```dart
/// Met à jour le nombre maximum de templates pour l'utilisateur actuel
Future<Result<void>> updateMaxTemplates(int maxTemplates) async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      return const Failure(
        AuthException('Aucun utilisateur connecté'),
      );
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'maxTemplates': maxTemplates,
      });
      return const Success(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Avertissement: Impossible de mettre à jour maxTemplates: $e');
      }
      return Failure(
        AuthException('Erreur lors de la mise à jour: ${e.toString()}'),
      );
    }
  } catch (e, stackTrace) {
    return Failure(
      AuthException('Erreur inattendue: ${e.toString()}'),
      stackTrace,
    );
  }
}
```

## Structure du document Firestore

Un document utilisateur dans Firestore devrait ressembler à ceci :

```json
{
  "uid": "abc123...",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": 1234567890,
  "lastLoginAt": 1234567890,
  "maxTemplates": 3
}
```

## Notes importantes

- Le champ `maxTemplates` est de type **number** (entier) dans Firestore
- La valeur par défaut est **3** pour tous les nouveaux utilisateurs
- Les utilisateurs existants qui n'ont pas ce champ auront automatiquement la valeur `3` lors de la lecture (grâce au fallback dans le code)
- Vous pouvez modifier cette valeur pour n'importe quel utilisateur à tout moment depuis la console Firebase

## Exemple de valeurs courantes

- **3** : Limite par défaut (gratuit)
- **5** : Plan basique
- **10** : Plan premium
- **-1** : Illimité (si vous voulez permettre un nombre illimité de templates)

