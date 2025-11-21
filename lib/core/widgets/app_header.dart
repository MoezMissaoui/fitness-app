import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

/// Header personnalisé pour les pages avec design moderne
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showActionButton = false,
    this.actionIcon,
    this.onActionPressed,
    this.onBackPressed,
    this.showProfile = true,
    this.greetingText,
    this.userName,
    this.showGreeting = true,
    this.showCalories = true,
  });

  final String? title;
  final bool showBackButton;
  final bool showActionButton;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final VoidCallback? onBackPressed;
  final bool showProfile;
  final String? greetingText;
  final String? userName;
  final bool showGreeting;
  final bool showCalories;

  @override
  Size get preferredSize => const Size.fromHeight(160);

  @override
  Widget build(BuildContext context) {
    if (title != null && showBackButton) {
      // Header avec titre et boutons (style Calendar)
      return _buildNavigationHeader(context);
    } else {
      // Header avec logo, greeting et profil (style Dashboard)
      return _buildDashboardHeader(context);
    }
  }

  /// Header style Dashboard avec profil, calories et éclair
  Widget _buildDashboardHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8), // Fond beige/crème
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: Responsive.padding(context).left,
        right: Responsive.padding(context).right,
        bottom: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne supérieure : Profil, Calories, Éclair
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Photo de profil
              if (showProfile)
                GestureDetector(
                  onTap: () {
                    // TODO: Naviguer vers le profil
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.lightBlue,
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryBlack,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              // Compteur de calories
              if (showCalories)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '124',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_upward,
                      color: AppTheme.lightBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kkal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              if (!showCalories && !showProfile && !showActionButton)
                const SizedBox.shrink(),
              // Bouton éclair
              if (showActionButton)
                GestureDetector(
                  onTap: onActionPressed,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      actionIcon ?? Icons.flash_on,
                      color: AppTheme.lightBlue,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          // Salutation
          if (showGreeting) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                      children: [
                        TextSpan(
                          text: 'Hey, ',
                          style: TextStyle(
                            color: AppTheme.primaryBlack.withOpacity(0.7),
                          ),
                        ),
                        TextSpan(
                          text: userName ?? 'Michelle',
                          style: const TextStyle(color: AppTheme.primaryBlack),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Streak indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '11',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Message de bienvenue
            Text(
              'Welcome, 11-week. Keep keep going!',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.primaryBlack),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Header style Navigation avec boutons retour et action
  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: Responsive.padding(context).left,
        right: Responsive.padding(context).right,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Bouton retour
          if (showBackButton)
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.grey,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryBlack,
                  size: 20,
                ),
              ),
            ),
          if (showBackButton) const SizedBox(width: 16),
          // Titre au centre
          Expanded(
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
          // Bouton action
          if (showActionButton)
            GestureDetector(
              onTap: onActionPressed,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.grey,
                ),
                child: Icon(
                  actionIcon ?? Icons.open_in_full,
                  color: AppTheme.primaryBlack,
                  size: 20,
                ),
              ),
            ),
          if (!showBackButton && !showActionButton)
            const SizedBox(width: 40), // Espace pour centrer le titre
        ],
      ),
    );
  }
}
