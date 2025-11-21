import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../di/service_locator.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/app_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';

/// Page de profil utilisateur
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = ServiceLocator.instance.authService;
  final _storageService = ServiceLocator.instance.storageService;
  final _imagePicker = ImagePicker();
  User? _currentUser;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Écouter les changements d'état d'authentification
    _authService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les données quand la page devient visible
    // (par exemple, après retour de la page de vérification d'email)
    _loadUserData();
  }

  void _loadUserData() {
    if (!mounted) return;
    setState(() {
      _currentUser = _authService.currentUser;
    });
  }

  Future<void> _handleRefresh() async {
    // Recharger les données utilisateur depuis Firebase
    final result = await _authService.reloadUser();
    if (result.isSuccess && mounted) {
      // Après reload(), il faut récupérer à nouveau currentUser
      // car l'objet User est immuable et reload() crée un nouvel objet
      setState(() {
        _currentUser = _authService.currentUser;
      });
    }
    // Attendre un peu pour l'animation de refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }


  Future<void> _handleLogout() async {
    // Afficher une boîte de dialogue de confirmation
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

    if (shouldLogout != true) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.signOut();

    setState(() => _isLoading = false);

    if (result.isFailure) {
      if (mounted) {
        final error = switch (result) {
          Failure(error: final e) => e,
          _ => null,
        };
        final message =
            error is AuthException
                ? error.message
                : 'Erreur lors de la déconnexion';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
    // Si succès, AuthWrapper redirigera automatiquement vers LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        userName:
            _currentUser?.displayName ??
            _currentUser?.email?.split('@')[0] ??
            'Utilisateur',
        showActionButton: true,
        showGreeting: false,
        showCalories: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section profil
                      _buildProfileSection(),
                      const SizedBox(height: 32),
                      // Section informations
                      _buildInfoSection(),
                      const SizedBox(height: 32),
                      // Bouton de déconnexion
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Afficher un bottom sheet pour choisir la source
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galerie'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Caméra'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
      );

      if (source == null) return;

      // Sélectionner l'image
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      // Upload l'image vers Firebase Storage
      final imageFile = File(pickedFile.path);
      final uploadResult = await _storageService.uploadProfileImage(imageFile);

      if (uploadResult.isFailure) {
        if (mounted) {
          final error = switch (uploadResult) {
            Failure(error: final e) => e,
            _ => null,
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is AuthException
                    ? error.message
                    : 'Erreur lors de l\'upload de l\'image',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isUploadingImage = false);
        return;
      }

      // Mettre à jour le profil avec l'URL de l'image
      final photoUrl = switch (uploadResult) {
        Success(value: final url) => url,
        _ => null,
      };

      if (photoUrl == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      final updateResult = await _authService.updateProfile(photoUrl: photoUrl);

      setState(() => _isUploadingImage = false);

      if (updateResult.isSuccess) {
        // Recharger les données utilisateur
        _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo de profil mise à jour avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          final error = switch (updateResult) {
            Failure(error: final e) => e,
            _ => null,
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is AuthException
                    ? error.message
                    : 'Erreur lors de la mise à jour du profil',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Contenu principal centré
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar avec bouton de changement
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.lightBlue,
                      child:
                          _isUploadingImage
                              ? const CircularProgressIndicator(
                                color: AppTheme.primaryBlack,
                              )
                              : _currentUser?.photoURL != null
                              ? ClipOval(
                                child: Image.network(
                                  _currentUser!.photoURL!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppTheme.primaryBlack,
                                    );
                                  },
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.primaryBlack,
                              ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.lightPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nom
                Text(
                  _currentUser?.displayName ?? 'Utilisateur',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  _currentUser?.email ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Icône d'édition en haut à droite (positionnée absolument)
          Positioned(
            top: -8,
            right: -8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    ),
                  ).then((_) {
                    // Recharger les données après retour
                    _loadUserData();
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.lightBlue,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final isEmailVerified = _currentUser?.emailVerified == true;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.verified_user_outlined,
            label: 'Email vérifié',
            value: isEmailVerified ? 'Oui' : 'Non',
            valueColor: isEmailVerified ? Colors.green : AppTheme.darkGrey,
          ),
        ],
      ),
    );
  }



  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.lightBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.darkGrey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, size: 20),
          const SizedBox(width: 8),
          Text(
            'Se déconnecter',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
