import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../core/constants/database_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/exercise.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DatabaseConstants.databaseName);

      return await openDatabase(
        path,
        version: DatabaseConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de l\'initialisation de la base de données: $e',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Création de la table
      await db.execute('''
        CREATE TABLE ${DatabaseConstants.exercisesTableName} (
          ${DatabaseConstants.columnExerciseId} TEXT PRIMARY KEY,
          ${DatabaseConstants.columnName} TEXT NOT NULL,
          ${DatabaseConstants.columnGifUrl} TEXT,
          ${DatabaseConstants.columnTargetMuscles} TEXT,
          ${DatabaseConstants.columnBodyParts} TEXT,
          ${DatabaseConstants.columnEquipments} TEXT,
          ${DatabaseConstants.columnSecondaryMuscles} TEXT,
          ${DatabaseConstants.columnInstructions} TEXT
        )
      ''');

      // Création des index pour améliorer les performances
      await db.execute(
        'CREATE INDEX ${DatabaseConstants.indexBodyParts} '
        'ON ${DatabaseConstants.exercisesTableName}'
        '(${DatabaseConstants.columnBodyParts})',
      );
      await db.execute(
        'CREATE INDEX ${DatabaseConstants.indexEquipments} '
        'ON ${DatabaseConstants.exercisesTableName}'
        '(${DatabaseConstants.columnEquipments})',
      );
      await db.execute(
        'CREATE INDEX ${DatabaseConstants.indexTargetMuscles} '
        'ON ${DatabaseConstants.exercisesTableName}'
        '(${DatabaseConstants.columnTargetMuscles})',
      );
      await db.execute(
        'CREATE INDEX ${DatabaseConstants.indexName} '
        'ON ${DatabaseConstants.exercisesTableName}'
        '(${DatabaseConstants.columnName})',
      );

      // Chargement des exercices depuis JSON au premier lancement
      await _loadExercisesFromJson(db);
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la création de la base de données: $e',
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here if needed
  }

  Future<void> _loadExercisesFromJson(Database db) async {
    try {
      // Vérifie si les données existent déjà
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseConstants.exercisesTableName}',
        ),
      );

      if (count != null && count > 0) {
        // Les données sont déjà chargées
        return;
      }

      // Charge le JSON depuis les assets
      final String jsonString = await rootBundle
          .loadString(DatabaseConstants.assetExercisesJson)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw AssetException(
                'Timeout lors du chargement du fichier JSON',
              );
            },
          );

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      if (jsonList.isEmpty) {
        throw DataLoadException('Le fichier JSON est vide');
      }

      // Insertion par batch pour de meilleures performances
      const batchSize = 500;
      for (var i = 0; i < jsonList.length; i += batchSize) {
        final batch = db.batch();
        final end =
            (i + batchSize < jsonList.length) ? i + batchSize : jsonList.length;

        for (var j = i; j < end; j++) {
          try {
            final exercise = Exercise.fromJson(
              jsonList[j] as Map<String, dynamic>,
            );
            batch.insert(
              DatabaseConstants.exercisesTableName,
              exercise.toMap(),
            );
          } catch (e) {
            // Log l'erreur mais continue avec les autres exercices
            print('⚠️ Erreur lors du parsing de l\'exercice $j: $e');
          }
        }
        await batch.commit(noResult: true);
      }

      print('✅ ${jsonList.length} exercices chargés dans la base de données');
    } on AssetException {
      rethrow;
    } on FormatException catch (e) {
      throw JsonParseException('Erreur de parsing JSON: $e');
    } catch (e) {
      throw DataLoadException('Erreur lors du chargement des exercices: $e');
    }
  }

  /// Récupère tous les exercices
  /// ⚠️ Attention: peut retourner une grande liste (~25k exercices)
  Future<List<Exercise>> getAllExercises() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        orderBy: '${DatabaseConstants.columnName} ASC',
      );
      return maps.map((map) => Exercise.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération des exercices: $e',
      );
    }
  }

  /// Récupère les exercices par partie du corps
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        where: '${DatabaseConstants.columnBodyParts} LIKE ?',
        whereArgs: ['%$bodyPart%'],
        orderBy: '${DatabaseConstants.columnName} ASC',
      );
      return maps.map((map) => Exercise.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération par partie du corps: $e',
      );
    }
  }

  /// Récupère les exercices par équipement
  Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        where: '${DatabaseConstants.columnEquipments} LIKE ?',
        whereArgs: ['%$equipment%'],
        orderBy: '${DatabaseConstants.columnName} ASC',
      );
      return maps.map((map) => Exercise.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération par équipement: $e',
      );
    }
  }

  /// Récupère les exercices par muscle (cible ou secondaire)
  Future<List<Exercise>> getExercisesByMuscle(String muscle) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        where:
            '${DatabaseConstants.columnTargetMuscles} LIKE ? OR '
            '${DatabaseConstants.columnSecondaryMuscles} LIKE ?',
        whereArgs: ['%$muscle%', '%$muscle%'],
        orderBy: '${DatabaseConstants.columnName} ASC',
      );
      return maps.map((map) => Exercise.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération par muscle: $e',
      );
    }
  }

  /// Recherche des exercices par nom
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final db = await database;
      final searchTerm = '%$query%';
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        where: '${DatabaseConstants.columnName} LIKE ?',
        whereArgs: [searchTerm],
        orderBy: '${DatabaseConstants.columnName} ASC',
      );
      return maps.map((map) => Exercise.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la recherche: $e');
    }
  }

  /// Récupère un exercice par son ID
  Future<Exercise?> getExerciseById(String exerciseId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        where: '${DatabaseConstants.columnExerciseId} = ?',
        whereArgs: [exerciseId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Exercise.fromMap(maps.first);
    } catch (e) {
      throw AppDatabaseException('Erreur lors de la récupération par ID: $e');
    }
  }

  /// Récupère les exercices avec plusieurs filtres combinés
  Future<List<Exercise>> getExercisesWithFilters({
    List<String>? bodyParts,
    List<String>? equipments,
    List<String>? muscles,
    String? searchQuery,
  }) async {
    try {
      final db = await database;
      final List<String> whereClauses = [];
      final List<dynamic> whereArgs = [];

      // Body Parts: OR logic for multiple selections
      if (bodyParts != null && bodyParts.isNotEmpty) {
        final bodyPartConditions = bodyParts
            .map((_) => '${DatabaseConstants.columnBodyParts} LIKE ?')
            .join(' OR ');
        whereClauses.add('($bodyPartConditions)');
        for (final bodyPart in bodyParts) {
          whereArgs.add('%$bodyPart%');
        }
      }

      // Equipments: OR logic for multiple selections
      if (equipments != null && equipments.isNotEmpty) {
        final equipmentConditions = equipments
            .map((_) => '${DatabaseConstants.columnEquipments} LIKE ?')
            .join(' OR ');
        whereClauses.add('($equipmentConditions)');
        for (final equipment in equipments) {
          whereArgs.add('%$equipment%');
        }
      }

      // Muscles: OR logic for multiple selections (target or secondary)
      if (muscles != null && muscles.isNotEmpty) {
        final muscleConditions = muscles
            .map((_) =>
                '(${DatabaseConstants.columnTargetMuscles} LIKE ? OR '
                '${DatabaseConstants.columnSecondaryMuscles} LIKE ?)')
            .join(' OR ');
        whereClauses.add('($muscleConditions)');
        for (final muscle in muscles) {
          whereArgs.add('%$muscle%');
          whereArgs.add('%$muscle%');
        }
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClauses.add('${DatabaseConstants.columnName} LIKE ?');
        whereArgs.add('%$searchQuery%');
      }

      final where = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.exercisesTableName,
        where: where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: '${DatabaseConstants.columnName} ASC',
      );

      return maps.map((map) => Exercise.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(
        'Erreur lors de la récupération avec filtres: $e',
      );
    }
  }

  /// Récupère le nombre total d'exercices
  Future<int> getExerciseCount() async {
    try {
      final db = await database;
      return Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseConstants.exercisesTableName}',
            ),
          ) ??
          0;
    } catch (e) {
      throw AppDatabaseException('Erreur lors du comptage: $e');
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
