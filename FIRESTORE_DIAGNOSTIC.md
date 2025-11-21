# Diagnostic Firestore - Collection `users` Non Créée

## 🔴 Problème

La collection `users` n'est **pas créée automatiquement** dans Firestore lors de l'inscription, même si l'utilisateur est créé avec succès dans Firebase Authentication.

## 🔍 Diagnostic

### Étape 1 : Vérifier les Logs de l'Application

Lors de l'inscription, vous devriez voir dans la console (logs) :

**Si Firestore est activé :**
```
✅ Document utilisateur créé dans Firestore: {uid}
   Collection: users
   Document ID: {uid}
```

**Si Firestore n'est PAS activé :**
```
❌ ERREUR CRITIQUE: Impossible d'écrire dans Firestore
═══════════════════════════════════════════════════════
Type d'erreur: FirebaseException
Message: [firestore/not-found] The database (default) does not exist
═══════════════════════════════════════════════════════
🔴 PROBLÈME IDENTIFIÉ: Firestore n'est PAS activé !
```

### Étape 2 : Tester la Connexion Firestore

Au démarrage de l'application, les logs devraient afficher :

```
🔍 Test de connexion Firebase...

✅ Firebase app instance: [DEFAULT]
✅ Firebase project ID: fitness-app-4f62a
✅ Firebase Auth connecté
✅ Firestore connecté
✅ Test de lecture Firestore réussi
❌ Test d'écriture Firestore: ÉCHEC  ← Si vous voyez ça, Firestore n'est pas activé
```

## ✅ Solution : Activer Firestore

### Méthode 1 : Via Firebase Console (Recommandé)

1. **Allez sur [Firebase Console](https://console.firebase.google.com/)**
2. **Sélectionnez votre projet** : `fitness-app-4f62a`
3. **Dans le menu de gauche**, cliquez sur **"Firestore Database"**
4. **Si vous voyez "Commencer une collection"** :
   - Cliquez sur **"Create database"** (ou **"Créer une base de données"**)
   - Choisissez **"Start in test mode"** (Mode test)
   - Sélectionnez une **région** (ex: `us-central1`, `europe-west1`)
   - Cliquez sur **"Enable"** (Activer)

### Méthode 2 : Vérifier les Règles de Sécurité

Si Firestore est activé mais les documents ne sont toujours pas créés :

1. Allez dans **Firestore Database** > **Rules**
2. Pour le développement, utilisez ces règles :

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

3. Cliquez sur **"Publish"** (Publier)

## 🧪 Test Manuel

Après avoir activé Firestore, testez manuellement :

1. **Inscrivez-vous** avec un nouveau compte
2. **Vérifiez les logs** - vous devriez voir `✅ Document utilisateur créé dans Firestore`
3. **Allez dans Firebase Console** > **Firestore Database**
4. **La collection `users` devrait apparaître** avec le document de l'utilisateur

## 📊 Vérification dans Firebase Console

### Comment vérifier que Firestore est activé :

1. Allez dans **Firestore Database**
2. Si vous voyez :
   - ✅ **Des collections existantes** ou **"Commencer une collection"** → Firestore est activé
   - ❌ **Un message d'erreur** ou **rien du tout** → Firestore n'est pas activé

### Comment vérifier que la collection `users` existe :

1. Allez dans **Firestore Database**
2. Cherchez la collection **`users`** dans la liste
3. Si elle existe, cliquez dessus pour voir les documents
4. Chaque document devrait avoir l'UID de l'utilisateur comme ID

## 🐛 Erreurs Communes et Solutions

### Erreur : "NOT_FOUND" ou "does not exist"

**Cause** : Firestore n'est pas activé dans Firebase Console

**Solution** :
1. Allez dans Firebase Console > Firestore Database
2. Cliquez sur "Create database"
3. Choisissez "Start in test mode"
4. Sélectionnez une région
5. Cliquez sur "Enable"

### Erreur : "PERMISSION_DENIED"

**Cause** : Les règles de sécurité Firestore bloquent l'écriture

**Solution** :
1. Allez dans Firebase Console > Firestore Database > Rules
2. Utilisez les règles de test mode ou configurez les règles pour permettre l'écriture aux utilisateurs authentifiés
3. Cliquez sur "Publish"

### Erreur : "Network error" ou "UNAVAILABLE"

**Cause** : Problème de connexion réseau

**Solution** :
1. Vérifiez votre connexion internet
2. Vérifiez que l'application peut accéder à Firebase
3. Réessayez après quelques instants

## 📝 Checklist de Vérification

- [ ] Firestore est activé dans Firebase Console
- [ ] Les règles de sécurité Firestore permettent l'écriture
- [ ] L'application peut se connecter à Firebase (vérifier les logs)
- [ ] Le test d'écriture Firestore réussit (voir logs au démarrage)
- [ ] L'inscription crée bien l'utilisateur dans Firebase Auth
- [ ] Les logs montrent une erreur lors de l'écriture dans Firestore

## 🎯 Après Activation

Une fois Firestore activé :

1. **Reconnectez-vous** dans l'application (ou créez un nouveau compte)
2. **Vérifiez les logs** - vous devriez voir `✅ Document utilisateur créé dans Firestore`
3. **Vérifiez dans Firebase Console** - la collection `users` devrait apparaître
4. **Pour les utilisateurs existants** : ils seront créés automatiquement lors de leur prochaine connexion

## 💡 Note Importante

**Firestore doit être activé manuellement dans Firebase Console.** C'est une étape obligatoire qui ne peut pas être automatisée depuis le code de l'application.

Une fois activé, la collection `users` sera créée automatiquement lors de la première inscription ! 🎉

