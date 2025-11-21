import 'package:equatable/equatable.dart';
import '../core/constants/database_constants.dart';

/// Modèle représentant un exercice de fitness
/// Implémente Equatable pour la comparaison et dispose de méthodes utilitaires
class Exercise extends Equatable {
  /// Identifiant unique de l'exercice
  final String exerciseId;

  /// Nom de l'exercice
  final String name;

  /// URL du GIF animé de l'exercice
  final String gifUrl;

  /// Liste des muscles ciblés principalement
  final List<String> targetMuscles;

  /// Liste des parties du corps travaillées
  final List<String> bodyParts;

  /// Liste des équipements nécessaires
  final List<String> equipments;

  /// Liste des muscles secondaires travaillés
  final List<String> secondaryMuscles;

  /// Liste des instructions étape par étape
  final List<String> instructions;

  const Exercise({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.targetMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.secondaryMuscles,
    required this.instructions,
  });

  /// Crée un Exercise à partir d'un JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    try {
      return Exercise(
        exerciseId: json['exerciseId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        gifUrl: json['gifUrl'] as String? ?? '',
        targetMuscles: _parseStringList(json['targetMuscles']),
        bodyParts: _parseStringList(json['bodyParts']),
        equipments: _parseStringList(json['equipments']),
        secondaryMuscles: _parseStringList(json['secondaryMuscles']),
        instructions: _parseStringList(json['instructions']),
      );
    } catch (e) {
      throw FormatException('Erreur lors du parsing JSON: $e');
    }
  }

  /// Parse une liste depuis un JSON (peut être List ou null)
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Convertit l'Exercise en JSON
  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'gifUrl': gifUrl,
      'targetMuscles': targetMuscles,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }

  /// Convertit l'Exercise en Map pour la base de données SQLite
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.columnExerciseId: exerciseId,
      DatabaseConstants.columnName: name,
      DatabaseConstants.columnGifUrl: gifUrl,
      DatabaseConstants.columnTargetMuscles:
          targetMuscles.join(DatabaseConstants.listSeparator),
      DatabaseConstants.columnBodyParts:
          bodyParts.join(DatabaseConstants.listSeparator),
      DatabaseConstants.columnEquipments:
          equipments.join(DatabaseConstants.listSeparator),
      DatabaseConstants.columnSecondaryMuscles:
          secondaryMuscles.join(DatabaseConstants.listSeparator),
      DatabaseConstants.columnInstructions:
          instructions.join(DatabaseConstants.instructionsSeparator),
    };
  }

  /// Crée un Exercise à partir d'une Map de la base de données
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      exerciseId: map[DatabaseConstants.columnExerciseId] as String? ?? '',
      name: map[DatabaseConstants.columnName] as String? ?? '',
      gifUrl: map[DatabaseConstants.columnGifUrl] as String? ?? '',
      targetMuscles: _parseStringFromDb(
        map[DatabaseConstants.columnTargetMuscles] as String?,
      ),
      bodyParts: _parseStringFromDb(
        map[DatabaseConstants.columnBodyParts] as String?,
      ),
      equipments: _parseStringFromDb(
        map[DatabaseConstants.columnEquipments] as String?,
      ),
      secondaryMuscles: _parseStringFromDb(
        map[DatabaseConstants.columnSecondaryMuscles] as String?,
      ),
      instructions: _parseInstructionsFromDb(
        map[DatabaseConstants.columnInstructions] as String?,
      ),
    );
  }

  /// Parse une liste depuis une chaîne séparée par des virgules
  static List<String> _parseStringFromDb(String? value) {
    if (value == null || value.isEmpty) return const [];
    return value
        .split(DatabaseConstants.listSeparator)
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Parse les instructions depuis une chaîne séparée par |||
  static List<String> _parseInstructionsFromDb(String? value) {
    if (value == null || value.isEmpty) return const [];
    return value
        .split(DatabaseConstants.instructionsSeparator)
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Crée une copie de l'Exercise avec des valeurs modifiées
  Exercise copyWith({
    String? exerciseId,
    String? name,
    String? gifUrl,
    List<String>? targetMuscles,
    List<String>? bodyParts,
    List<String>? equipments,
    List<String>? secondaryMuscles,
    List<String>? instructions,
  }) {
    return Exercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      gifUrl: gifUrl ?? this.gifUrl,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      bodyParts: bodyParts ?? this.bodyParts,
      equipments: equipments ?? this.equipments,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
    );
  }

  /// Vérifie si l'exercice correspond à un filtre de recherche
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        targetMuscles.any((m) => m.toLowerCase().contains(lowerQuery)) ||
        bodyParts.any((b) => b.toLowerCase().contains(lowerQuery));
  }

  @override
  List<Object?> get props => [
        exerciseId,
        name,
        gifUrl,
        targetMuscles,
        bodyParts,
        equipments,
        secondaryMuscles,
        instructions,
      ];

  @override
  String toString() {
    return 'Exercise(exerciseId: $exerciseId, name: $name)';
  }
}

