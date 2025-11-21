import 'package:flutter/material.dart';

/// Utilitaires pour rendre l'UI responsive
class Responsive {
  Responsive._();

  /// Retourne true si l'écran est petit (mobile)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Retourne true si l'écran est moyen (tablette)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Retourne true si l'écran est large (desktop)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Retourne la largeur de l'écran
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Retourne la hauteur de l'écran
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Retourne un pourcentage de la largeur de l'écran
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Retourne un pourcentage de la hauteur de l'écran
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  /// Retourne un espacement adaptatif basé sur la taille de l'écran
  static double spacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.5;
    } else {
      return baseSpacing * 2;
    }
  }

  /// Retourne une taille de police adaptative
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < 360) {
      return baseSize * 0.9; // Très petit écran
    } else if (width < 600) {
      return baseSize; // Mobile
    } else if (width < 1200) {
      return baseSize * 1.2; // Tablette
    } else {
      return baseSize * 1.5; // Desktop
    }
  }

  /// Retourne le nombre de colonnes selon la taille de l'écran
  static int columns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Retourne le padding adaptatif
  static EdgeInsets padding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) {
      return const EdgeInsets.all(16);
    } else if (width < 1200) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Retourne le padding horizontal adaptatif
  static EdgeInsets horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (width < 1200) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }
}

