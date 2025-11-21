import 'package:flutter/material.dart';

/// Utilitaires pour obtenir les icônes appropriées pour chaque partie du corps
/// Utilise Material Icons avec des sélections optimisées pour le fitness
class BodyPartIcons {
  BodyPartIcons._();

  /// Retourne l'icône appropriée pour une partie du corps
  static IconData getIcon(String bodyPart) {
    final lowerBodyPart = bodyPart.toLowerCase().trim();

    // Mapping spécifique pour chaque partie du corps avec Material Icons optimisées
    switch (lowerBodyPart) {
      case 'neck':
        return Icons.face; // Visage pour représenter le cou
      case 'lower arms':
        return Icons.pan_tool; // Main/poignet pour les avant-bras
      case 'shoulders':
        return Icons.sports_gymnastics; // Épaules/bras levés
      case 'cardio':
        return Icons.favorite; // Cœur pour le cardio
      case 'upper arms':
        return Icons.fitness_center; // Haltères pour les bras supérieurs
      case 'chest':
        return Icons.airline_seat_flat; // Torse/poitrine
      case 'lower legs':
        return Icons.directions_walk; // Marche pour les jambes inférieures
      case 'back':
        return Icons.accessibility_new; // Dos/colonne vertébrale
      case 'upper legs':
        return Icons.directions_run; // Course pour les cuisses
      case 'waist':
        return Icons.self_improvement; // Yoga/core pour la taille
      default:
        // Fallback intelligent pour les variations de noms
        return _getIconByKeyword(lowerBodyPart);
    }
  }

  /// Retourne une icône basée sur des mots-clés
  static IconData _getIconByKeyword(String bodyPart) {
    if (bodyPart.contains('neck')) {
      return Icons.face;
    } else if (bodyPart.contains('arm')) {
      // Distinction entre upper et lower arms
      if (bodyPart.contains('lower') || bodyPart.contains('fore')) {
        return Icons.pan_tool;
      }
      return Icons.fitness_center;
    } else if (bodyPart.contains('leg')) {
      // Distinction entre upper et lower legs
      if (bodyPart.contains('lower') || bodyPart.contains('calf')) {
        return Icons.directions_walk;
      }
      return Icons.directions_run;
    } else if (bodyPart.contains('chest') || bodyPart.contains('pectoral')) {
      return Icons.airline_seat_flat;
    } else if (bodyPart.contains('back') || bodyPart.contains('spine')) {
      return Icons.accessibility_new;
    } else if (bodyPart.contains('shoulder')) {
      return Icons.sports_gymnastics;
    } else if (bodyPart.contains('waist') ||
        bodyPart.contains('abs') ||
        bodyPart.contains('core')) {
      return Icons.self_improvement;
    } else if (bodyPart.contains('cardio') ||
        bodyPart.contains('heart') ||
        bodyPart.contains('cardiovascular')) {
      return Icons.favorite;
    } else {
      return Icons.accessibility;
    }
  }
}
