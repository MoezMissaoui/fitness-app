import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../di/service_locator.dart';
import '../pages/login_page.dart';
import '../pages/email_verification_page.dart';
import '../../main_navigation/main_navigation_page.dart';

/// Wrapper qui vérifie l'état d'authentification et redirige vers
/// la page appropriée (login, vérification email ou app principale)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = ServiceLocator.instance.authService;

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Afficher un loader pendant la vérification initiale
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        // Si l'utilisateur est connecté
        if (user != null) {
          // Vérifier si l'email est vérifié
          if (!user.emailVerified) {
            // Email non vérifié : afficher la page de vérification
            return const EmailVerificationPage();
          }
          // Email vérifié : afficher l'app principale
          return const MainNavigationPage();
        }

        // Sinon, afficher la page de login
        return const LoginPage();
      },
    );
  }
}

