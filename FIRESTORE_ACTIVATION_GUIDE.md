# Guide d'Activation Firestore - Problème de Collection Non Créée

## 🔴 Problème

La collection `users` n'est **pas créée** dans Firestore malgré les utilisateurs existants dans Firebase Auth.

## 🔍 Causes Possibles

### 1. Firestore n'est pas activé dans Firebase Console

**C'est la cause la plus probable !**

Firestore doit être **activé manuellement** dans Firebase Console avant que l'application puisse y écrire.

### 2. Erreurs silencieuses

Les erreurs Firestore sont capturées dans le code mais peuvent ne pas être visibles. Le code a été amélioré pour afficher des logs détaillés.

## ✅ Solution : Activer Firestore

### Étape 1 : Vérifier dans Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet : **fitness-app-4f62a**
3. Dans le menu de gauche, cherchez **"Firestore Database"**

### Étape 2 : Activer Firestore

**Si vous voyez "Commencer une collection" ou un message similaire :**

1. Cliquez sur **"Create database"** (ou **"Créer une base de données"**)
2. Choisissez le **mode de sécurité** :
   - **Mode test** (recommandé pour le développement) :
     - Permet les lectures/écritures pendant 30 jours
     - Cliquez sur **"Next"**
   - **Mode production** :
     - Nécessite de configurer les règles de sécurité
3. **Sélectionnez l'emplacement** :
   - Choisissez une région proche de vos utilisateurs
   - Exemple : `us-central1`, `europe-west1`, `asia-southeast1`
4. Cliquez sur **"Enable"** (ou **"Activer"**)

### Étape 3 : Vérifier les Règles de Sécurité

Une fois Firestore activé, vérifiez les règles de sécurité :

1. Allez dans **Firestore Database** > **Rules**
2. Pour le développement, vous pouvez utiliser :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Mode test : permet tout aux utilisateurs authentifiés
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Cliquez sur **"Publish"** (Publier)

⚠️ **Important** : Ces règles sont pour le développement uniquement. Pour la production, configurez des règles plus strictes.

## 🔧 Créer les Documents pour les Utilisateurs Existants

Une fois Firestore activé, vous pouvez créer les documents pour les utilisateurs existants :

### Option 1 : Via l'Application (Recommandé)

1. **Déconnectez-vous** de l'application
2. **Reconnectez-vous** avec un compte existant
3. Le document sera créé automatiquement lors de la connexion

### Option 2 : Via le Code (Méthode ajoutée)

Une nouvelle méthode `createOrUpdateUserDocument()` a été ajoutée dans `AuthService`. Vous pouvez l'utiliser pour créer les documents manuellement.

### Option 3 : Via Firebase Console (Manuel)

1. Allez dans **Firestore Database**
2. Cliquez sur **"Commencer une collection"**
3. Collection ID : `users`
4. Document ID : Utilisez l'UID de l'utilisateur (depuis Firebase Auth)
5. Ajoutez les champs :
   - `uid` (string) : L'UID de l'utilisateur
   - `email` (string) : L'email de l'utilisateur
   - `displayName` (string) : Le nom d'affichage
   - `maxTemplates` (number) : `3`
   - `createdAt` (number) : Timestamp en millisecondes
   - `lastLoginAt` (number) : Timestamp en millisecondes

## 📊 Vérification

### Vérifier les Logs de l'Application

Après avoir activé Firestore, les logs devraient afficher :

```
✅ Document utilisateur créé dans Firestore: {uid}
```

Si vous voyez des erreurs, les logs détaillés afficheront :
- Le type d'erreur
- Le message d'erreur
- La stack trace

### Vérifier dans Firebase Console

1. Allez dans **Firestore Database**
2. La collection `users` devrait apparaître
3. Cliquez sur `users` pour voir les documents

## 🐛 Diagnostic

### Si Firestore est activé mais les documents ne sont toujours pas créés :

1. **Vérifiez les règles de sécurité** : Assurez-vous que les utilisateurs authentifiés peuvent écrire
2. **Vérifiez les logs de l'application** : Les erreurs détaillées sont maintenant affichées
3. **Vérifiez la connexion réseau** : Assurez-vous que l'application peut accéder à Firebase

### Erreurs Communes

#### Erreur : "Permission denied"
- **Cause** : Les règles de sécurité Firestore bloquent l'écriture
- **Solution** : Mettez à jour les règles pour permettre l'écriture aux utilisateurs authentifiés

#### Erreur : "NOT_FOUND"
- **Cause** : Firestore n'est pas activé
- **Solution** : Activez Firestore dans Firebase Console

#### Erreur : "Network error"
- **Cause** : Problème de connexion
- **Solution** : Vérifiez votre connexion internet

## 📝 Résumé

1. ✅ **Activez Firestore** dans Firebase Console
2. ✅ **Configurez les règles de sécurité** (mode test pour le développement)
3. ✅ **Reconnectez-vous** dans l'application pour créer les documents
4. ✅ **Vérifiez** que la collection `users` apparaît dans Firestore

Une fois Firestore activé, la collection `users` sera créée automatiquement lors de la prochaine inscription ou connexion ! 🎉

