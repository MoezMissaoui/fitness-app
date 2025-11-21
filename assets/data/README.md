# Assets Data

Ce dossier contient les fichiers de données JSON utilisés par l'application Fitness.

## Structure

- `exercises.json` : Base de données complète des exercices (~25k exercices)
- `bodyparts.json` : Liste des parties du corps
- `muscles.json` : Liste des muscles
- `equipments.json` : Liste des équipements

## Utilisation

Ces fichiers sont chargés automatiquement au premier lancement de l'application et sont stockés dans une base de données SQLite locale pour des performances optimales.

Les fichiers sont référencés dans :
- `lib/core/constants/database_constants.dart`
- `pubspec.yaml` (section assets)

## Note

Les fichiers JSON sont des assets statiques et ne doivent pas être modifiés directement. Pour mettre à jour les données, utilisez le système de migration de la base de données.

