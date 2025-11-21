import 'package:flutter/services.dart';
import '../constants/database_constants.dart';

/// Utilitaire pour vérifier que tous les assets sont disponibles
class AssetVerifier {
  AssetVerifier._();

  /// Vérifie que tous les assets JSON sont disponibles
  static Future<bool> verifyAllAssets() async {
    try {
      await rootBundle.loadString(DatabaseConstants.assetExercisesJson);
      await rootBundle.loadString(DatabaseConstants.assetBodyPartsJson);
      await rootBundle.loadString(DatabaseConstants.assetMusclesJson);
      await rootBundle.loadString(DatabaseConstants.assetEquipmentsJson);
      return true;
    } catch (e) {
      print('❌ Erreur lors de la vérification des assets: $e');
      return false;
    }
  }

  /// Affiche les chemins attendus pour le débogage
  static void printAssetPaths() {
    print('📁 Chemins des assets attendus:');
    print('  - ${DatabaseConstants.assetExercisesJson}');
    print('  - ${DatabaseConstants.assetBodyPartsJson}');
    print('  - ${DatabaseConstants.assetMusclesJson}');
    print('  - ${DatabaseConstants.assetEquipmentsJson}');
  }
}

