# Configuration Firestore Enterprise

## 🔍 Compréhension

Même avec **Firestore Enterprise**, le package Flutter `cloud_firestore` fonctionne de la même manière que Firestore standard :
- ✅ Utilise les credentials Firebase du projet (`firebase_options.dart`)
- ✅ Pas besoin d'URL de connexion dans le code Flutter
- ✅ Se connecte automatiquement via l'API Firebase

## ⚠️ Problème Actuel

Les warnings indiquent que Firestore n'est **pas activé** dans Firebase Console pour votre projet `fitness-app-4f62a` :

```
W/Firestore: Stream closed with status: Status{code=NOT_FOUND, description=The database (default) does not exist
```

## ✅ Solution : Activer Firestore dans Firebase Console

Même pour Firestore Enterprise, vous devez d'abord activer Firestore dans Firebase Console :

### Étapes :

1. **Allez sur [Firebase Console](https://console.firebase.google.com/)**
2. **Sélectionnez votre projet** : `fitness-app-4f62a`
3. **Cliquez sur "Firestore Database"** dans le menu de gauche
4. **Cliquez sur "Create database"** (ou "Créer une base de données")

### Si vous avez Firestore Enterprise :

- Firestore Enterprise peut nécessiter une configuration spéciale côté serveur
- Mais côté client Flutter, la configuration reste la même
- Le package `cloud_firestore` utilisera automatiquement la bonne instance

### Configuration dans Firebase Console :

1. **Choisissez le mode** :
   - Mode test (développement)
   - Mode production (production)

2. **Sélectionnez l'emplacement** :
   - Si vous avez Firestore Enterprise, choisissez l'emplacement correspondant
   - L'URL MongoDB que vous avez fournie semble pointer vers `nam5` (North America 5)

3. **Activez la base de données**

## 🔧 Configuration Flutter

**Aucune modification de code nécessaire** si vous utilisez Firestore Enterprise. Le package `cloud_firestore` utilisera automatiquement :
- Les credentials de `firebase_options.dart`
- Le `projectId: 'fitness-app-4f62a'`
- L'API Firebase standard

## 📝 Note sur l'URL MongoDB

L'URL que vous avez fournie :
```
mongodb://...@652ed8df-cee3-4d05-b4be-d3f6ce16e808.nam5.firestore.goog:443/...
```

Cette URL est probablement pour :
- Accès direct MongoDB à Firestore Enterprise (pour outils externes)
- **PAS** pour le package Flutter `cloud_firestore`

Le package Flutter utilise l'API REST/gRPC de Firebase, pas le protocole MongoDB.

## ✅ Vérification

Après avoir activé Firestore dans Firebase Console :

1. **Les warnings disparaîtront**
2. **L'inscription fonctionnera sans blocage**
3. **Les données seront stockées dans Firestore**

## 🚀 Action Immédiate

**Activez simplement Firestore dans Firebase Console** :
1. Firebase Console → Projet `fitness-app-4f62a`
2. Firestore Database → Create database
3. Mode test → Choisir emplacement → Enable

Le package Flutter se connectera automatiquement à la bonne instance Firestore Enterprise une fois activée dans Firebase Console.

