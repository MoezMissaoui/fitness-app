# Guide de Configuration Firebase Storage

Ce guide vous explique comment activer et configurer Firebase Storage pour l'upload d'images de profil.

## ⚠️ Erreur: "No object exists at the desired reference"

Cette erreur signifie que **Firebase Storage n'est pas activé** dans votre projet Firebase. Suivez les étapes ci-dessous pour l'activer.

## 📋 Étapes pour Activer Firebase Storage

### Étape 1: Activer Storage dans Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet : **fitness-app-4f62a**
3. Dans le menu de gauche, cliquez sur **Storage**
4. Cliquez sur **Get started** (ou **Commencer**)

### Étape 2: Configurer Storage

1. **Choisir le mode de sécurité** :
   - **Mode test** (recommandé pour le développement) :
     - Permet les lectures/écritures pour tous les utilisateurs authentifiés
     - Cliquez sur **Next**
   
   - **Mode production** (pour la production) :
     - Nécessite de configurer les règles de sécurité
     - Plus sécurisé mais nécessite une configuration

2. **Sélectionner l'emplacement du bucket** :
   - Choisissez la même région que votre Firestore (pour de meilleures performances)
   - Exemple : `us-central1`, `europe-west1`, etc.
   - Cliquez sur **Done**

### Étape 3: Configurer les Règles de Sécurité (Mode Test)

Si vous avez choisi le mode test, les règles par défaut sont :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Ces règles permettent à tous les utilisateurs authentifiés de lire et écrire.

### Étape 4: Règles de Sécurité Recommandées (Mode Production)

Pour la production, utilisez des règles plus restrictives :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Images de profil : uniquement l'utilisateur peut uploader/supprimer sa propre image
    match /profile_images/{userId}.jpg {
      allow read: if true; // Tous peuvent lire
      allow write: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Autres fichiers (si nécessaire)
    match /{allPaths=**} {
      allow read, write: if false; // Par défaut, refuser tout
    }
  }
}
```

**Pour modifier les règles** :
1. Allez dans Firebase Console → **Storage** → **Rules**
2. Modifiez les règles
3. Cliquez sur **Publish**

## ✅ Vérification

Après avoir activé Storage :

1. **Vérifiez dans Firebase Console** :
   - Allez dans **Storage** → **Files**
   - Vous devriez voir un dossier vide (ou avec des fichiers si vous avez déjà uploadé)

2. **Testez l'upload** :
   - Allez dans votre app
   - Essayez d'uploader une image de profil
   - L'image devrait apparaître dans Firebase Console → Storage → Files → `profile_images/`

## 🐛 Dépannage

### Erreur: "No object exists at the desired reference"

**Solution** :
- ✅ Vérifiez que Storage est activé dans Firebase Console
- ✅ Vérifiez que vous avez cliqué sur "Get started" dans Storage
- ✅ Vérifiez que le bucket existe (il devrait être créé automatiquement)

### Erreur: "Permission denied" ou "Unauthorized"

**Solution** :
- ✅ Vérifiez les règles de sécurité dans Storage → Rules
- ✅ Assurez-vous que l'utilisateur est authentifié
- ✅ Pour le mode test, les règles doivent permettre `request.auth != null`

### Erreur: "Bucket not found"

**Solution** :
- ✅ Vérifiez que Storage est activé
- ✅ Vérifiez que le `storageBucket` dans `firebase_options.dart` correspond au bucket dans Firebase Console
- ✅ Le bucket devrait être : `fitness-app-4f62a.firebasestorage.app`

### L'upload fonctionne mais l'image ne s'affiche pas

**Solution** :
- ✅ Vérifiez que l'URL de téléchargement est correcte
- ✅ Vérifiez que l'image est bien uploadée dans Storage → Files
- ✅ Vérifiez que le profil utilisateur est mis à jour avec la nouvelle URL
- ✅ Rafraîchissez l'app ou reconnectez-vous

## 📱 Test de l'Upload

1. **Activez Storage** dans Firebase Console (étapes 1-2 ci-dessus)
2. **Lancez l'app** :
   ```bash
   flutter run
   ```
3. **Allez sur la page Profile**
4. **Cliquez sur l'icône caméra** sur l'avatar
5. **Choisissez une image** (Galerie ou Caméra)
6. **L'image devrait s'uploader** et apparaître dans Firebase Console

## 🔒 Sécurité

### Mode Test (Développement)
- ✅ Facile à configurer
- ✅ Permet tous les uploads pour utilisateurs authentifiés
- ⚠️ **Ne pas utiliser en production**

### Mode Production
- ✅ Plus sécurisé
- ✅ Règles personnalisables
- ✅ Recommandé pour les apps en production

## 📚 Ressources

- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [FlutterFire Storage](https://firebase.flutter.dev/docs/storage/overview)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)

## ✅ Checklist

Avant d'utiliser l'upload d'image :

- [ ] Storage activé dans Firebase Console
- [ ] Bucket créé (automatique lors de l'activation)
- [ ] Règles de sécurité configurées (mode test ou production)
- [ ] `firebase_storage` ajouté à `pubspec.yaml` ✅ (déjà fait)
- [ ] `StorageService` créé ✅ (déjà fait)
- [ ] Permissions Android ajoutées ✅ (déjà fait)
- [ ] Test d'upload réussi

Une fois Storage activé, l'upload d'image devrait fonctionner ! 🎉

