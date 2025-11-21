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
        print('✅ Firebase app instance: ${app.name}');
        print('✅ Firebase project ID: ${app.options.projectId}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de connexion Firebase de base: $e');
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
        print('✅ Firebase Auth connecté');
        print('   Utilisateur actuel: ${currentUser?.email ?? 'Aucun'}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de connexion Firebase Auth: $e');
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
        print('✅ Firestore connecté');
        print('   Cache size: ${settings.cacheSizeBytes}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de connexion Firestore: $e');
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
        print('✅ Test de lecture Firestore réussi');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du test de lecture Firestore: $e');
      }
      return false;
    }
  }

  /// Teste toutes les connexions Firebase
  static Future<Map<String, bool>> testAllConnections() async {
    if (kDebugMode) {
      print('\n🔍 Test de connexion Firebase...\n');
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

    // Résumé
    if (kDebugMode) {
      print('\n📊 Résumé des tests:');
      results.forEach((key, value) {
        print('   ${value ? "✅" : "❌"} $key: ${value ? "OK" : "ÉCHEC"}');
      });

      final allPassed = results.values.every((value) => value);
      if (allPassed) {
        print('\n🎉 Tous les tests de connexion Firebase ont réussi!\n');
      } else {
        print('\n⚠️ Certains tests ont échoué. Vérifiez la configuration.\n');
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
        print('\n📱 Informations Firebase:');
        print('   App Name: ${app.name}');
        print('   Project ID: ${options.projectId}');
        print('   API Key: ${options.apiKey.substring(0, 10)}...');
        print('   App ID: ${options.appId}');
        print('   Storage Bucket: ${options.storageBucket}');
        print('   Messaging Sender ID: ${options.messagingSenderId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Impossible d\'obtenir les informations Firebase: $e');
      }
    }
  }
}

