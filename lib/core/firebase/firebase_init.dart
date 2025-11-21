import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'firebase_connection_test.dart';

/// Initialise Firebase pour l'application
///
/// Cette fonction doit être appelée avant toute utilisation de Firebase
/// Elle configure Firebase avec les options spécifiques à la plateforme
Future<void> initializeFirebase({bool testConnection = false}) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kDebugMode) {
      debugPrint('✅ Firebase initialisé avec succès');

      // Afficher les informations Firebase
      FirebaseConnectionTest.printFirebaseInfo();

      // Tester la connexion si demandé
      if (testConnection) {
        final results = await FirebaseConnectionTest.testAllConnections();
        
        // Afficher un avertissement si Firestore Write échoue
        if (results['Firestore Write'] == false) {
          if (kDebugMode) {
            debugPrint('');
            debugPrint('⚠️ ATTENTION: Firestore ne peut pas écrire !');
            debugPrint('   La collection "users" ne sera pas créée automatiquement.');
            debugPrint('   Activez Firestore dans Firebase Console pour résoudre ce problème.');
            debugPrint('');
          }
        }
      }
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ Erreur lors de l\'initialisation de Firebase: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    rethrow;
  }
}
