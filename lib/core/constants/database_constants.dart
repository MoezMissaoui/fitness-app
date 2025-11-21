/// Constantes pour la base de données
/// Centralise toutes les constantes liées à la base de données
class DatabaseConstants {
  DatabaseConstants._();

  // Nom de la base de données
  static const String databaseName = 'fitness_app.db';
  static const int databaseVersion = 1;

  // Nom de la table
  static const String exercisesTableName = 'exercises';

  // Colonnes de la table exercises
  static const String columnExerciseId = 'exerciseId';
  static const String columnName = 'name';
  static const String columnGifUrl = 'gifUrl';
  static const String columnTargetMuscles = 'targetMuscles';
  static const String columnBodyParts = 'bodyParts';
  static const String columnEquipments = 'equipments';
  static const String columnSecondaryMuscles = 'secondaryMuscles';
  static const String columnInstructions = 'instructions';

  // Indexes pour améliorer les performances
  static const String indexBodyParts = 'idx_bodyParts';
  static const String indexEquipments = 'idx_equipments';
  static const String indexTargetMuscles = 'idx_targetMuscles';
  static const String indexName = 'idx_name';

  // Séparateurs pour la sérialisation
  static const String listSeparator = ',';
  static const String instructionsSeparator = '|||';

  // Chemins des assets JSON
  static const String assetExercisesJson = 'assets/data/exercises.json';
  static const String assetBodyPartsJson = 'assets/data/bodyparts.json';
  static const String assetMusclesJson = 'assets/data/muscles.json';
  static const String assetEquipmentsJson = 'assets/data/equipments.json';
}
