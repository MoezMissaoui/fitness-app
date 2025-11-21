import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/exercise.dart';

/// Widget réutilisable pour afficher un exercice dans une carte
/// Suit les principes Material Design
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise, this.onTap});

  final Exercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.spacing(context, 16);
    final spacing = Responsive.spacing(context, 8);
    final imageHeight = isMobile ? 150.0 : 180.0;
    final margin = Responsive.spacing(context, 4);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: margin, vertical: margin),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nom de l'exercice
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 18),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing),

              // Image GIF (si disponible)
              if (exercise.gifUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    exercise.gifUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: Responsive.fontSize(context, 48),
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),

              SizedBox(height: spacing * 1.5),

              // Tags (Body Parts, Equipment, Muscles)
              Wrap(
                spacing: Responsive.spacing(context, 8),
                runSpacing: Responsive.spacing(context, 8),
                children: [
                  ...exercise.bodyParts.map(
                    (bodyPart) => _buildChip(
                      context,
                      bodyPart,
                      Colors.blue,
                      Icons.accessibility_new,
                    ),
                  ),
                  ...exercise.equipments.map(
                    (equipment) => _buildChip(
                      context,
                      equipment,
                      Colors.orange,
                      Icons.fitness_center,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Muscles ciblés
              if (exercise.targetMuscles.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_people,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Muscles: ${exercise.targetMuscles.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    // Crée une couleur plus foncée pour le texte
    final darkerColor = Color.fromRGBO(
      (color.red * 0.7).round().clamp(0, 255),
      (color.green * 0.7).round().clamp(0, 255),
      (color.blue * 0.7).round().clamp(0, 255),
      color.opacity,
    );

    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: color),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: darkerColor, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
