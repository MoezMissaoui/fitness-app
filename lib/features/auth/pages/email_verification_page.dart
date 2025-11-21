import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../di/service_locator.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/app_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main_navigation/main_navigation_page.dart';

/// Page de vérification d'email
/// S'affiche lorsque l'utilisateur est connecté mais que son email n'est pas vérifié
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _authService = ServiceLocator.instance.authService;
  bool _isLoading = false;
  bool _isSendingEmail = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Envoyer l'email de vérification automatiquement si pas encore envoyé
    _sendVerificationEmailIfNeeded();
    // Vérifier périodiquement si l'email est vérifié
    _checkEmailVerification();
  }

  Future<void> _sendVerificationEmailIfNeeded() async {
    if (_currentUser?.emailVerified == false) {
      try {
        await _authService.sendEmailVerification();
      } catch (e) {
        // Ignorer l'erreur silencieusement
        // L'utilisateur pourra renvoyer l'email manuellement
      }
    }
  }

  void _loadUserData() {
    setState(() {
      _currentUser = _authService.currentUser;
    });
  }

  Future<void> _checkEmailVerification() async {
    // Vérifier toutes les 3 secondes si l'email est vérifié
    while (mounted && _currentUser?.emailVerified == false) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      final result = await _authService.reloadUser();
      if (result.isSuccess) {
        final user = _authService.currentUser;
        if (user?.emailVerified == true) {
          // L'email est vérifié, naviguer vers la page d'accueil
          if (mounted) {
            setState(() {
              _currentUser = user;
            });
            // Naviguer vers la page d'accueil
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationPage()),
            );
          }
          break;
        }
      }
    }
  }

  Future<void> _handleSendVerificationEmail() async {
    setState(() => _isSendingEmail = true);

    final result = await _authService.sendEmailVerification();

    setState(() => _isSendingEmail = false);

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email de vérification envoyé ! Vérifiez votre boîte de réception et votre dossier spam.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (mounted) {
        final error = switch (result) {
          Failure(error: final e) => e,
          _ => null,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AuthException
                  ? error.message
                  : 'Erreur lors de l\'envoi de l\'email',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final result = await _authService.reloadUser();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _loadUserData();
      if (_currentUser?.emailVerified == true) {
        if (mounted) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email vérifié avec succès ! Redirection...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Attendre un peu pour que l'utilisateur voie le message
          await Future.delayed(const Duration(milliseconds: 500));

          // Naviguer vers la page d'accueil
          // AuthWrapper devrait rediriger automatiquement, mais on force la navigation
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationPage()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'L\'email n\'est pas encore vérifié. Vérifiez votre boîte de réception et votre dossier spam.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        final error = switch (result) {
          Failure(error: final e) => e,
          _ => null,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AuthException
                  ? error.message
                  : 'Erreur lors de la vérification',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppTheme.darkGrey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightPurple,
                  foregroundColor: AppTheme.primaryBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      // AuthWrapper redirigera automatiquement vers LoginPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône de vérification
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread,
                    size: 80,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 32),

                // Titre
                Text(
                  'Vérification d\'email requise',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  'Un email de vérification a été envoyé à :',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.darkGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser?.email ?? 'email@example.com',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppTheme.lightBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructions',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        '1',
                        'Vérifiez votre boîte de réception (et votre dossier spam)',
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                        '2',
                        'Cliquez sur le lien de vérification',
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionStep(
                        '3',
                        'Revenez ici et cliquez sur "Actualiser"',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton envoyer email
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSendingEmail ? null : _handleSendVerificationEmail,
                    icon:
                        _isSendingEmail
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.email_outlined),
                    label: Text(
                      _isSendingEmail
                          ? 'Envoi en cours...'
                          : 'Renvoyer l\'email',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightBlue,
                      foregroundColor: AppTheme.primaryBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton actualiser
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleRefresh,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lightBlue,
                      side: BorderSide(color: AppTheme.lightBlue, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton déconnexion
                TextButton(
                  onPressed: _handleLogout,
                  child: Text(
                    'Se déconnecter',
                    style: TextStyle(
                      color: AppTheme.darkGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
          ),
        ),
      ],
    );
  }
}
