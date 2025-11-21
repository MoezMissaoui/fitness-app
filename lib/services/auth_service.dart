import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/utils/result.dart';
import '../core/errors/app_exceptions.dart';

/// Service d'authentification Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream de l'utilisateur actuel
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => _auth.currentUser != null;

  /// Inscription avec email et mot de passe
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return const Failure(
          AuthException('Échec de la création du compte'),
        );
      }

      // Mettre à jour le display name si fourni
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      // Créer le document utilisateur dans Firestore
      // Ne pas bloquer l'inscription si Firestore n'est pas configuré
      final userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: displayName ?? user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        maxTemplates: 3, // Valeur par défaut: 3 templates
      );

      try {
        // Créer automatiquement la collection 'users' et le document utilisateur
        // Firestore crée automatiquement la collection si elle n'existe pas
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap(), SetOptions(merge: false));
        
        if (kDebugMode) {
          debugPrint('✅ Document utilisateur créé dans Firestore: ${user.uid}');
        }
      } catch (e, stackTrace) {
        // Si Firestore n'est pas configuré, continuer quand même
        // L'utilisateur sera créé dans Firebase Auth, c'est l'essentiel
        if (kDebugMode) {
          debugPrint('⚠️ ERREUR: Impossible d\'écrire dans Firestore');
          debugPrint('Type d\'erreur: ${e.runtimeType}');
          debugPrint('Message: $e');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('L\'utilisateur est créé dans Firebase Auth mais pas dans Firestore.');
          debugPrint('Vérifiez que Firestore est activé dans Firebase Console.');
        }
      }

      // L'envoi de l'email de vérification sera fait depuis la page de vérification
      // pour éviter de bloquer l'inscription

      return Success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur inattendue: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Connexion avec email et mot de passe
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return const Failure(
          AuthException('Échec de la connexion'),
        );
      }

      // Mettre à jour la dernière connexion (non bloquant)
      _updateLastLogin(user.uid).catchError((e) {
        if (kDebugMode) {
          debugPrint('Avertissement: Impossible de mettre à jour lastLoginAt: $e');
        }
      });

      // Récupérer les données utilisateur depuis Firestore
      // Si Firestore n'est pas configuré, utiliser Firebase Auth comme fallback
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromMap(userDoc.data()!);
          return Success(userModel);
        } else {
          // Créer le document s'il n'existe pas (migration)
          final userModel = UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName,
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            maxTemplates: 3, // Valeur par défaut: 3 templates
          );
          try {
            // Créer automatiquement le document utilisateur dans Firestore
            // La collection 'users' sera créée automatiquement si elle n'existe pas
            await _firestore
                .collection('users')
                .doc(user.uid)
                .set(userModel.toMap(), SetOptions(merge: false));
            
            if (kDebugMode) {
              debugPrint('✅ Document utilisateur créé dans Firestore (migration): ${user.uid}');
            }
          } catch (e, stackTrace) {
            // Si Firestore n'est pas configuré, continuer quand même
            if (kDebugMode) {
              debugPrint('⚠️ ERREUR lors de la création du document (migration): $e');
              debugPrint('Type: ${e.runtimeType}');
              debugPrint('Stack trace: $stackTrace');
            }
          }
          return Success(userModel);
        }
      } catch (e) {
        // Si Firestore n'est pas configuré, utiliser Firebase Auth comme fallback
        if (kDebugMode) {
          debugPrint('Avertissement: Impossible de lire depuis Firestore: $e');
        }
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        return Success(userModel);
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur inattendue: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Déconnexion
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors de la déconnexion'),
        stackTrace,
      );
    }
  }

  /// Change l'email de l'utilisateur
  /// Nécessite une vérification du nouvel email
  Future<Result<void>> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return const Failure(
          AuthException('Aucun utilisateur connecté'),
        );
      }

      // Vérifier le mot de passe actuel en se reconnectant
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Changer l'email avec vérification
      // verifyBeforeUpdateEmail envoie automatiquement un email de vérification
      // L'email ne sera changé qu'après que l'utilisateur clique sur le lien dans l'email
      await user.verifyBeforeUpdateEmail(newEmail);
      
      // Note: Firestore sera mis à jour automatiquement après la vérification
      // car l'utilisateur sera rechargé et l'email sera mis à jour dans Firebase Auth

      return const Success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors du changement d\'email: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Mise à jour du profil utilisateur
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure(
          AuthException('Aucun utilisateur connecté'),
        );
      }

      // Mettre à jour Firebase Auth
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();

      // Mettre à jour Firestore
      final updateData = <String, dynamic>{};
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        try {
          // Mettre à jour le document utilisateur dans Firestore
          // La collection 'users' sera créée automatiquement si elle n'existe pas
          // Utiliser set() avec merge: true pour créer ou mettre à jour
          await _firestore.collection('users').doc(user.uid).set(
            updateData,
            SetOptions(merge: true),
          );
          
          if (kDebugMode) {
            debugPrint('✅ Document utilisateur mis à jour dans Firestore: ${user.uid}');
          }
        } catch (e) {
          // Si Firestore n'est pas configuré, continuer quand même
          if (kDebugMode) {
            debugPrint('⚠️ Avertissement: Impossible de mettre à jour Firestore: $e');
          }
        }
      }

      // Récupérer les données mises à jour depuis Firestore
      // Si Firestore n'est pas configuré, retourner les données de Firebase Auth
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromMap(userDoc.data()!);
          return Success(userModel);
        }
      } catch (e) {
        // Si Firestore n'est pas configuré, utiliser les données de Firebase Auth
        if (kDebugMode) {
          debugPrint('Avertissement: Impossible de lire depuis Firestore: $e');
        }
      }

      // Fallback: retourner les données de Firebase Auth si Firestore n'est pas disponible
      final userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName ?? displayName,
        photoUrl: user.photoURL ?? photoUrl,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        maxTemplates: 3, // Valeur par défaut: 3 templates
      );
      return Success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors de la mise à jour: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Changement de mot de passe
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return const Failure(
          AuthException('Aucun utilisateur connecté'),
        );
      }

      // Vérifier le mot de passe actuel en se reconnectant
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Changer le mot de passe
      await user.updatePassword(newPassword);

      return const Success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors du changement de mot de passe: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Réinitialisation du mot de passe
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors de la réinitialisation: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Envoie un email de vérification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure(
          AuthException('Aucun utilisateur connecté'),
        );
      }

      if (user.emailVerified) {
        return const Failure(
          AuthException('L\'email est déjà vérifié'),
        );
      }

      await user.sendEmailVerification();
      return const Success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors de l\'envoi de l\'email: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Recharge les données de l'utilisateur actuel
  Future<Result<void>> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure(
          AuthException('Aucun utilisateur connecté'),
        );
      }

      await user.reload();
      return const Success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Failure(_handleAuthException(e), stackTrace);
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur lors du rechargement: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Récupère les données utilisateur depuis Firestore
  Future<Result<UserModel>> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userModel = UserModel.fromMap(userDoc.data()!);
        return Success(userModel);
      }
      
      // Si Firestore n'est pas configuré ou l'utilisateur n'existe pas dans Firestore,
      // retourner les données de Firebase Auth
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          maxTemplates: 3, // Valeur par défaut: 3 templates
        );
        return Success(userModel);
      }
      
      return const Failure(AuthException('Utilisateur non trouvé'));
    } catch (e, stackTrace) {
      // Si Firestore n'est pas configuré, utiliser Firebase Auth comme fallback
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          maxTemplates: 3, // Valeur par défaut: 3 templates
        );
        return Success(userModel);
      }
      
      return Failure(
        AuthException('Erreur lors de la récupération: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Met à jour la dernière connexion
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      // Ignorer les erreurs silencieusement
      if (kDebugMode) {
        debugPrint('⚠️ Erreur lors de la mise à jour de lastLoginAt: $e');
        debugPrint('Type: ${e.runtimeType}');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Crée ou met à jour le document utilisateur dans Firestore
  /// Utile pour créer les documents des utilisateurs existants
  /// Note: Nécessite que l'utilisateur soit connecté
  Future<Result<void>> createOrUpdateUserDocument() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Failure(
          AuthException('Aucun utilisateur connecté'),
        );
      }

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        maxTemplates: 3,
      );

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap(), SetOptions(merge: true));
        
        if (kDebugMode) {
          debugPrint('✅ Document utilisateur créé/mis à jour dans Firestore: ${user.uid}');
        }
        return const Success(null);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ ERREUR lors de la création du document: $e');
          debugPrint('Type: ${e.runtimeType}');
          debugPrint('Stack trace: $stackTrace');
        }
        return Failure(
          AuthException('Erreur Firestore: ${e.toString()}'),
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur inattendue: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Gère les exceptions Firebase Auth
  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return const AuthException('Le mot de passe est trop faible');
      case 'email-already-in-use':
        return const AuthException('Cet email est déjà utilisé');
      case 'user-not-found':
        return const AuthException('Aucun compte trouvé avec cet email');
      case 'wrong-password':
        return const AuthException('Mot de passe incorrect');
      case 'invalid-email':
        return const AuthException('Email invalide');
      case 'user-disabled':
        return const AuthException('Ce compte a été désactivé');
      case 'too-many-requests':
        return const AuthException('Trop de tentatives. Réessayez plus tard');
      case 'operation-not-allowed':
        return const AuthException('Cette opération n\'est pas autorisée');
      case 'requires-recent-login':
        return const AuthException('Veuillez vous reconnecter pour effectuer cette action');
      default:
        return AuthException('Erreur d\'authentification: ${e.message ?? e.code}');
    }
  }
}

