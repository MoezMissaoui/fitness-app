# Guide de Configuration Firestore

## ⚠️ Important : Firestore ne nécessite PAS d'URL de connexion

**Firestore (Firebase) est différent de MongoDB** :
- ✅ **Firestore** : Pas besoin d'URL, se configure dans Firebase Console
- ❌ **MongoDB** : Nécessite une URL de connexion (comme celle que vous avez fournie)

Si vous avez une URL MongoDB, c'est pour MongoDB Atlas, pas pour Firestore.

## ⚠️ Warning Actuel

Vous voyez ces warnings :
```
W/Firestore(20381): (25.1.4) [WriteStream]: Stream closed with status: Status{code=NOT_FOUND, description=The database (default) does not exist for project fitness-app-4f62a
```

Cela signifie que **Firestore n'est pas activé** dans votre projet Firebase. L'application fonctionnera quand même (avec Firebase Auth), mais certaines fonctionnalités nécessitant Firestore ne seront pas disponibles.

**Solution** : Activez simplement Firestore dans Firebase Console (voir ci-dessous). Aucune URL à configurer !

## 📋 Étapes pour Activer Firestore

### Étape 1: Activer Firestore dans Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet : **fitness-app-4f62a**
3. Dans le menu de gauche, cliquez sur **Firestore Database**
4. Cliquez sur **Create database** (ou **Créer une base de données**)

### Étape 2: Choisir le Mode de Sécurité

1. **Mode test** (recommandé pour le développement) :
   - Permet les lectures/écritures pour tous les utilisateurs authentifiés
   - Cliquez sur **Next**
   - **⚠️ Ne pas utiliser en production**

2. **Mode production** (pour la production) :
   - Nécessite de configurer les règles de sécurité
   - Plus sécurisé mais nécessite une configuration

### Étape 3: Sélectionner l'Emplacement

1. Choisissez l'emplacement de votre base de données
   - Recommandé : même région que votre Storage (si configuré)
   - Exemple : `us-central1`, `europe-west1`, etc.
2. Cliquez sur **Enable** (ou **Activer**)

### Étape 4: Configurer les Règles de Sécurité (Mode Test)

Les règles par défaut en mode test sont :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Ces règles permettent à tous les utilisateurs authentifiés de lire et écrire.

### Étape 5: Règles de Sécurité Recommandées (Mode Production)

Pour la production, utilisez des règles plus restrictives :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Collection users : chaque utilisateur peut lire/écrire ses propres données
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Autres collections (ajoutez selon vos besoins)
    match /{document=**} {
      allow read, write: if false; // Par défaut, refuser tout
    }
  }
}
```

**Pour modifier les règles** :
1. Allez dans Firebase Console → **Firestore Database** → **Rules**
2. Modifiez les règles
3. Cliquez sur **Publish**

## ✅ Vérification

Après avoir activé Firestore :

1. **Vérifiez dans Firebase Console** :
   - Allez dans **Firestore Database** → **Data**
   - Vous devriez voir une base de données vide (ou avec des documents si vous avez déjà créé des utilisateurs)

2. **Testez l'inscription** :
   - Créez un nouveau compte
   - Vérifiez que l'utilisateur apparaît dans Firestore → **Data** → **users**

## 🔧 Fonctionnalités Utilisant Firestore

Actuellement, l'application utilise Firestore pour :
- ✅ Stocker les données utilisateur (nom, email, photo, dates)
- ✅ Mettre à jour le profil utilisateur
- ✅ Récupérer les données utilisateur

**Note** : L'application fonctionnera même sans Firestore grâce aux fallbacks vers Firebase Auth, mais certaines fonctionnalités seront limitées.

## 🐛 Dépannage

### Warning: "The database (default) does not exist"

**Solution** :
- ✅ Activez Firestore dans Firebase Console (étapes 1-3 ci-dessus)
- ✅ Attendez quelques minutes après l'activation
- ✅ Redémarrez l'application

### Warning: "Ignoring header X-Firebase-Locale"

**Solution** :
- ⚠️ Ce warning est inoffensif
- Il indique simplement que la locale n'est pas définie
- Vous pouvez l'ignorer ou configurer la locale dans Firebase

### L'inscription fonctionne mais les données ne sont pas dans Firestore

**Solution** :
- ✅ Vérifiez que Firestore est activé
- ✅ Vérifiez les règles de sécurité (doivent permettre `request.auth != null`)
- ✅ Vérifiez que l'utilisateur est bien authentifié
- ✅ Consultez les logs dans Firebase Console → Firestore → Usage

## 📚 Ressources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire Firestore](https://firebase.flutter.dev/docs/firestore/overview)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

## ✅ Checklist

Avant d'utiliser les fonctionnalités Firestore :

- [ ] Firestore activé dans Firebase Console
- [ ] Base de données créée (mode test ou production)
- [ ] Règles de sécurité configurées
- [ ] Emplacement sélectionné
- [ ] Test d'inscription réussi
- [ ] Vérification que les données apparaissent dans Firestore

Une fois Firestore activé, les warnings disparaîtront et toutes les fonctionnalités seront disponibles ! 🎉

