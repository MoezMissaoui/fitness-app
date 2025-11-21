import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Barre de navigation en bas de l'application avec design moderne
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFF2C2C2E,
        ).withValues(alpha: 0.95), // Semi-transparent
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withValues(alpha: 0.6),
          selectedFontSize: 0, // Cache les labels
          unselectedFontSize: 0, // Cache les labels
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              isSelected: currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.fitness_center_outlined,
              activeIcon: Icons.fitness_center,
              isSelected: currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              isSelected: currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.description_outlined,
              activeIcon: Icons.description,
              isSelected: currentIndex == 3,
            ),
            _buildNavItem(
              icon: Icons.history_outlined,
              activeIcon: Icons.history,
              isSelected: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryBlack : Colors.white,
          size: 24,
        ),
      ),
      label: '',
    );
  }
}
