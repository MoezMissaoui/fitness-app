import '../core/errors/app_exceptions.dart';
import '../core/utils/result.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

/// Repository pour gérer les exercices
/// Pattern Repository : sépare la logique métier de l'accès aux données
abstract class ExerciseRepository {
  /// Récupère tous les exercices
  Future<Result<List<Exercise>>> getAllExercises();

  /// Récupère un exercice par son ID
  Future<Result<Exercise?>> getExerciseById(String exerciseId);

  /// Recherche des exercices par nom
  Future<Result<List<Exercise>>> searchExercises(String query);

  /// Récupère les exercices par partie du corps
  Future<Result<List<Exercise>>> getExercisesByBodyPart(String bodyPart);

  /// Récupère les exercices par équipement
  Future<Result<List<Exercise>>> getExercisesByEquipment(String equipment);

  /// Récupère les exercices par muscle
  Future<Result<List<Exercise>>> getExercisesByMuscle(String muscle);

  /// Récupère les exercices avec plusieurs filtres
  Future<Result<List<Exercise>>> getExercisesWithFilters({
    List<String>? bodyParts,
    List<String>? equipments,
    List<String>? muscles,
    String? searchQuery,
  });

  /// Récupère le nombre total d'exercices
  Future<Result<int>> getExerciseCount();
}

/// Implémentation du repository avec SQLite
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<Result<List<Exercise>>> getAllExercises() async {
    try {
      final exercises = await _databaseService.getAllExercises();
      return Success(exercises);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la récupération des exercices: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<Exercise?>> getExerciseById(String exerciseId) async {
    try {
      if (exerciseId.isEmpty) {
        return Failure(
          const AppDatabaseException('L\'ID de l\'exercice ne peut pas être vide'),
        );
      }
      final exercise = await _databaseService.getExerciseById(exerciseId);
      return Success(exercise);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la récupération de l\'exercice: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<List<Exercise>>> searchExercises(String query) async {
    try {
      if (query.isEmpty) {
        return Success([]);
      }
      final exercises = await _databaseService.searchExercises(query);
      return Success(exercises);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la recherche: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByBodyPart(
    String bodyPart,
  ) async {
    try {
      if (bodyPart.isEmpty) {
        return Success([]);
      }
      final exercises = await _databaseService.getExercisesByBodyPart(bodyPart);
      return Success(exercises);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la récupération par partie du corps: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByEquipment(
    String equipment,
  ) async {
    try {
      if (equipment.isEmpty) {
        return Success([]);
      }
      final exercises = await _databaseService.getExercisesByEquipment(equipment);
      return Success(exercises);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la récupération par équipement: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<List<Exercise>>> getExercisesByMuscle(String muscle) async {
    try {
      if (muscle.isEmpty) {
        return Success([]);
      }
      final exercises = await _databaseService.getExercisesByMuscle(muscle);
      return Success(exercises);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la récupération par muscle: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<List<Exercise>>> getExercisesWithFilters({
    List<String>? bodyParts,
    List<String>? equipments,
    List<String>? muscles,
    String? searchQuery,
  }) async {
    try {
      final exercises = await _databaseService.getExercisesWithFilters(
        bodyParts: bodyParts,
        equipments: equipments,
        muscles: muscles,
        searchQuery: searchQuery,
      );
      return Success(exercises);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors de la récupération avec filtres: $e'),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<int>> getExerciseCount() async {
    try {
      final count = await _databaseService.getExerciseCount();
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(
        AppDatabaseException('Erreur lors du comptage des exercices: $e'),
        stackTrace,
      );
    }
  }
}

