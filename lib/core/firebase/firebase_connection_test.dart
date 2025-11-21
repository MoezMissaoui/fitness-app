import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Utilitaire pour tester la connexion Firebase
class FirebaseConnectionTest {
  /// Teste la connexion Firebase de base
  static Future<bool> testBasicConnection() async {
    try {
      final app = Firebase.app();
      if (kDebugMode) {
        debugPrint('✅ Firebase app instance: ${app.name}');
        debugPrint('✅ Firebase project ID: ${app.options.projectId}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur de connexion Firebase de base: $e');
      }
      return false;
    }
  }

  /// Teste la connexion Firebase Auth
  static Future<bool> testAuthConnection() async {
    try {
      final auth = FirebaseAuth.instance;
      // Essayer d'accéder à l'instance (cela teste la connexion)
      final currentUser = auth.currentUser;
      if (kDebugMode) {
        debugPrint('✅ Firebase Auth connecté');
        debugPrint('   Utilisateur actuel: ${currentUser?.email ?? 'Aucun'}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur de connexion Firebase Auth: $e');
      }
      return false;
    }
  }

  /// Teste la connexion Firestore
  static Future<bool> testFirestoreConnection() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Essayer d'accéder à l'instance (cela teste la connexion)
      final settings = firestore.settings;
      if (kDebugMode) {
        debugPrint('✅ Firestore connecté');
        debugPrint('   Cache size: ${settings.cacheSizeBytes}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur de connexion Firestore: $e');
      }
      return false;
    }
  }

  /// Teste une opération Firestore réelle (lecture)
  static Future<bool> testFirestoreRead() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Essayer de lire une collection (même si elle n'existe pas)
      // On utilise une limite pour éviter de charger trop de données
      await firestore.collection('_test_connection').limit(1).get();
      if (kDebugMode) {
        debugPrint('✅ Test de lecture Firestore réussi');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur lors du test de lecture Firestore: $e');
        debugPrint('   Type: ${e.runtimeType}');
        if (e is Exception) {
          debugPrint('   Message: ${e.toString()}');
        }
      }
      return false;
    }
  }

  /// Teste une opération Firestore réelle (écriture)
  /// C'est le test le plus important pour vérifier si Firestore est activé
  static Future<bool> testFirestoreWrite() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Essayer d'écrire dans une collection de test
      final testDoc = firestore.collection('_test_connection').doc('_test_write');
      await testDoc.set({
        'test': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Nettoyer : supprimer le document de test
      await testDoc.delete();
      
      if (kDebugMode) {
        debugPrint('✅ Test d\'écriture Firestore réussi');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ERREUR lors du test d\'écriture Firestore:');
        debugPrint('   Type: ${e.runtimeType}');
        debugPrint('   Message: $e');
        if (e.toString().contains('NOT_FOUND')) {
          debugPrint('   ⚠️ Firestore n\'est PAS activé dans Firebase Console !');
          debugPrint('   📋 Solution: Allez dans Firebase Console > Firestore Database > Create database');
        } else if (e.toString().contains('PERMISSION_DENIED')) {
          debugPrint('   ⚠️ Les règles de sécurité Firestore bloquent l\'écriture !');
          debugPrint('   📋 Solution: Vérifiez les règles Firestore dans Firebase Console');
        }
      }
      return false;
    }
  }

  /// Teste toutes les connexions Firebase
  static Future<Map<String, bool>> testAllConnections() async {
    if (kDebugMode) {
      debugPrint('\n🔍 Test de connexion Firebase...\n');
    }

    final results = <String, bool>{};

    // Test 1: Connexion de base
    results['Basic Connection'] = await testBasicConnection();

    // Test 2: Firebase Auth
    results['Firebase Auth'] = await testAuthConnection();

    // Test 3: Firestore
    results['Firestore'] = await testFirestoreConnection();

    // Test 4: Lecture Firestore
    results['Firestore Read'] = await testFirestoreRead();
    
    // Test 5: Écriture Firestore (le plus important)
    results['Firestore Write'] = await testFirestoreWrite();

    // Résumé
    if (kDebugMode) {
      debugPrint('\n📊 Résumé des tests:');
      results.forEach((key, value) {
        debugPrint('   ${value ? "✅" : "❌"} $key: ${value ? "OK" : "ÉCHEC"}');
      });

      final allPassed = results.values.every((value) => value);
      if (allPassed) {
        debugPrint('\n🎉 Tous les tests de connexion Firebase ont réussi!\n');
      } else {
        debugPrint('\n⚠️ Certains tests ont échoué. Vérifiez la configuration.\n');
      }
    }

    return results;
  }

  /// Vérifie rapidement si Firebase est connecté
  static bool isConnected() {
    try {
      final app = Firebase.app();
      return app.name.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Affiche les informations de configuration Firebase
  static void printFirebaseInfo() {
    try {
      final app = Firebase.app();
      final options = app.options;
      
      if (kDebugMode) {
        debugPrint('\n📱 Informations Firebase:');
        debugPrint('   App Name: ${app.name}');
        debugPrint('   Project ID: ${options.projectId}');
        debugPrint('   API Key: ${options.apiKey.substring(0, 10)}...');
        debugPrint('   App ID: ${options.appId}');
        debugPrint('   Storage Bucket: ${options.storageBucket}');
        debugPrint('   Messaging Sender ID: ${options.messagingSenderId}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Impossible d\'obtenir les informations Firebase: $e');
      }
    }
  }
}

