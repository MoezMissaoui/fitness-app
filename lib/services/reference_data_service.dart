import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/database_constants.dart';
import '../core/errors/app_exceptions.dart';

/// Service for loading small reference data (bodyparts, muscles, equipments)
/// These are kept as JSON since they're small and rarely change
class ReferenceDataService {
  static final ReferenceDataService _instance =
      ReferenceDataService._internal();
  factory ReferenceDataService() => _instance;
  ReferenceDataService._internal();

  List<String>? _bodyParts;
  List<String>? _muscles;
  List<String>? _equipments;

  /// Récupère la liste des parties du corps
  /// Utilise le cache si déjà chargé
  Future<List<String>> getBodyParts() async {
    if (_bodyParts != null) return _bodyParts!;

    try {
      final String jsonString = await rootBundle
          .loadString(DatabaseConstants.assetBodyPartsJson)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw AssetException(
                'Timeout lors du chargement de bodyparts.json',
              );
            },
          );

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _bodyParts =
          jsonList
              .map((item) => (item as Map<String, dynamic>)['name'] as String)
              .where((name) => name.isNotEmpty)
              .toList();

      return _bodyParts!;
    } on FormatException catch (e) {
      throw JsonParseException('Erreur de parsing bodyparts.json: $e');
    } catch (e) {
      throw AssetException('Erreur lors du chargement de bodyparts.json: $e');
    }
  }

  /// Récupère la liste des muscles
  /// Utilise le cache si déjà chargé
  Future<List<String>> getMuscles() async {
    if (_muscles != null) return _muscles!;

    try {
      final String jsonString = await rootBundle
          .loadString(DatabaseConstants.assetMusclesJson)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw AssetException(
                'Timeout lors du chargement de muscles.json',
              );
            },
          );

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _muscles =
          jsonList
              .map((item) => (item as Map<String, dynamic>)['name'] as String)
              .where((name) => name.isNotEmpty)
              .toList();

      return _muscles!;
    } on FormatException catch (e) {
      throw JsonParseException('Erreur de parsing muscles.json: $e');
    } catch (e) {
      throw AssetException('Erreur lors du chargement de muscles.json: $e');
    }
  }

  /// Récupère la liste des équipements
  /// Utilise le cache si déjà chargé
  Future<List<String>> getEquipments() async {
    if (_equipments != null) return _equipments!;

    try {
      final String jsonString = await rootBundle
          .loadString(DatabaseConstants.assetEquipmentsJson)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw AssetException(
                'Timeout lors du chargement de equipments.json',
              );
            },
          );

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _equipments =
          jsonList
              .map((item) => (item as Map<String, dynamic>)['name'] as String)
              .where((name) => name.isNotEmpty)
              .toList();

      return _equipments!;
    } on FormatException catch (e) {
      throw JsonParseException('Erreur de parsing equipments.json: $e');
    } catch (e) {
      throw AssetException('Erreur lors du chargement de equipments.json: $e');
    }
  }

  // Clear cache if needed (e.g., after updating JSON files)
  void clearCache() {
    _bodyParts = null;
    _muscles = null;
    _equipments = null;
  }
}
