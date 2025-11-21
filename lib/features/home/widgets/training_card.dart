import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

/// Carte d'entraînement avec image et informations
class TrainingCard extends StatelessWidget {
  const TrainingCard({
    super.key,
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.backgroundColor,
  });

  final String title;
  final String duration;
  final String imageUrl;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final cardHeight = isMobile ? 120.0 : 140.0;
    final imageWidth = isMobile ? 100.0 : 140.0;
    final horizontalPadding = Responsive.spacing(context, 16);
    final verticalPadding = Responsive.spacing(context, 12);
    
    return Card(
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Contenu texte à gauche
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: AppTheme.primaryBlack,
                          size: Responsive.fontSize(context, 18),
                        ),
                        SizedBox(width: Responsive.spacing(context, 6)),
                        Text(
                          duration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Image à droite
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: imageWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageWidth,
                    height: cardHeight,
                    color: backgroundColor.withOpacity(0.5),
                    child: Icon(
                      Icons.image_not_supported,
                      size: Responsive.fontSize(context, 48),
                      color: AppTheme.primaryBlack,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: imageWidth,
                    height: cardHeight,
                    color: backgroundColor.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

