// Example usage of the data services
// This file demonstrates how to use the database and reference data services

import 'database_service.dart';
import 'reference_data_service.dart';
import '../models/exercise.dart';

class DataServiceExample {
  final DatabaseService _dbService = DatabaseService();
  final ReferenceDataService _refService = ReferenceDataService();

  /// Initialize database (call this once at app startup)
  Future<void> initializeDatabase() async {
    // Database will auto-initialize and load from JSON on first run
    await _dbService.database;
    print('Database initialized');
  }

  /// Get all exercises (use sparingly - returns all ~25k exercises)
  Future<List<Exercise>> getAllExercises() async {
    return await _dbService.getAllExercises();
  }

  /// Get exercises filtered by body part (FAST - uses indexed query)
  Future<List<Exercise>> getChestExercises() async {
    return await _dbService.getExercisesByBodyPart('chest');
  }

  /// Get exercises filtered by equipment (FAST - uses indexed query)
  Future<List<Exercise>> getDumbbellExercises() async {
    return await _dbService.getExercisesByEquipment('dumbbell');
  }

  /// Get exercises filtered by muscle (FAST - uses indexed query)
  Future<List<Exercise>> getBicepExercises() async {
    return await _dbService.getExercisesByMuscle('biceps');
  }

  /// Search exercises by name (FAST - uses indexed query)
  Future<List<Exercise>> searchExercises(String query) async {
    return await _dbService.searchExercises(query);
  }

  /// Get exercises with multiple filters (FAST - uses indexed queries)
  Future<List<Exercise>> getFilteredExercises({
    List<String>? bodyParts,
    List<String>? equipments,
    List<String>? muscles,
    String? searchQuery,
  }) async {
    return await _dbService.getExercisesWithFilters(
      bodyParts: bodyParts,
      equipments: equipments,
      muscles: muscles,
      searchQuery: searchQuery,
    );
  }

  /// Get reference data (bodyparts, muscles, equipments)
  Future<void> loadReferenceData() async {
    final bodyParts = await _refService.getBodyParts();
    final muscles = await _refService.getMuscles();
    final equipments = await _refService.getEquipments();

    print('Body Parts: ${bodyParts.length}');
    print('Muscles: ${muscles.length}');
    print('Equipments: ${equipments.length}');
  }

  /// Example: Get chest exercises that use dumbbells
  Future<List<Exercise>> getChestDumbbellExercises() async {
    return await _dbService.getExercisesWithFilters(
      bodyParts: ['chest'],
      equipments: ['dumbbell'],
    );
  }
}

