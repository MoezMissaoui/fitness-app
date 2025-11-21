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
      print('✅ Firebase initialisé avec succès');

      // Afficher les informations Firebase
      FirebaseConnectionTest.printFirebaseInfo();

      // Tester la connexion si demandé
      if (testConnection) {
        await FirebaseConnectionTest.testAllConnections();
      }
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Erreur lors de l\'initialisation de Firebase: $e');
      print('Stack trace: $stackTrace');
    }
    rethrow;
  }
}
