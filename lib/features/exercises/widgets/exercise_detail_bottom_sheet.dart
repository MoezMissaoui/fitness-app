import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/exercise.dart';

/// Bottom sheet plein écran pour afficher les détails d'un exercice
class ExerciseDetailBottomSheet extends StatelessWidget {
  const ExerciseDetailBottomSheet({super.key, required this.exercise});

  final Exercise exercise;

  static void show(BuildContext context, Exercise exercise) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ExerciseDetailBottomSheet(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = Responsive.padding(context);
    final spacing = Responsive.spacing(context, 24);

    return Container(
      height: screenHeight * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with close button
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              padding.top * 0.5,
              padding.right,
              padding.bottom * 0.5,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppTheme.darkGrey,
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: padding.left),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GIF Image with real dimensions
                  if (exercise.gifUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Image.network(
                          exercise.gifUrl,
                          // width: double.infinity,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.fitness_center,
                                color: AppTheme.lightBlue,
                                size: 64,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: spacing * 0.75),
                  ],

                  // Metadata sections with title outside
                  if (_hasMetadata()) ...[
                    _buildSectionTitle(context, 'Details', Icons.info_outline),
                    SizedBox(height: spacing * 0.4),
                    _buildMetadataGrid(context),
                    SizedBox(height: spacing * 0.75),
                  ],

                  // Instructions in single card
                  if (exercise.instructions.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Instructions', Icons.list),
                    SizedBox(height: spacing * 0.4),
                    _buildInstructionsCard(context),
                    SizedBox(height: spacing * 0.75),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
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
        SizedBox(width: Responsive.spacing(context, 8)),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataGrid(BuildContext context) {
    // First line: Body Parts and Equipment
    final firstLineSections = <_MetadataSection>[];
    if (exercise.bodyParts.isNotEmpty) {
      firstLineSections.add(
        _MetadataSection(
          title: 'Body Parts',
          icon: Icons.accessibility_new,
          items: exercise.bodyParts,
          color: AppTheme.lightBlue,
        ),
      );
    }
    if (exercise.equipments.isNotEmpty) {
      firstLineSections.add(
        _MetadataSection(
          title: 'Equipment',
          icon: Icons.fitness_center,
          items: exercise.equipments,
          color: AppTheme.lightPurple,
        ),
      );
    }

    // Second line: Target Muscles and Secondary Muscles
    final secondLineSections = <_MetadataSection>[];
    if (exercise.targetMuscles.isNotEmpty) {
      secondLineSections.add(
        _MetadataSection(
          title: 'Target Muscles',
          icon: Icons.emoji_people,
          items: exercise.targetMuscles,
          color: Colors.orange.shade300,
        ),
      );
    }
    if (exercise.secondaryMuscles.isNotEmpty) {
      secondLineSections.add(
        _MetadataSection(
          title: 'Secondary Muscles',
          icon: Icons.emoji_people_outlined,
          items: exercise.secondaryMuscles,
          color: Colors.orange.shade200,
        ),
      );
    }

    if (firstLineSections.isEmpty && secondLineSections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First line: Body Parts and Equipment
          if (firstLineSections.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildSectionRow(context, firstLineSections),
            ),
          // Second line: Target Muscles and Secondary Muscles
          if (firstLineSections.isNotEmpty && secondLineSections.isNotEmpty)
            SizedBox(height: Responsive.spacing(context, 12)),
          if (secondLineSections.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildSectionRow(context, secondLineSections),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionRow(
    BuildContext context,
    List<_MetadataSection> sections,
  ) {
    return sections.asMap().entries.map((entry) {
      final section = entry.value;
      final isLast = entry.key == sections.length - 1;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: !isLast ? Responsive.spacing(context, 16) : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Section header with icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: section.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(section.icon, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Flexible(
                    child: Text(
                      section.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context, 8)),
              // Items as tags - aligned horizontally with wrap
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    section.items
                        .map(
                          (item) =>
                              _buildCompactTag(context, item, section.color),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  bool _hasMetadata() {
    return exercise.bodyParts.isNotEmpty ||
        exercise.equipments.isNotEmpty ||
        exercise.targetMuscles.isNotEmpty ||
        exercise.secondaryMuscles.isNotEmpty;
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            exercise.instructions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final instruction = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      entry.key < exercise.instructions.length - 1
                          ? Responsive.spacing(context, 12)
                          : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 12)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          instruction,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryBlack,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCompactTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Helper class for metadata sections
class _MetadataSection {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  _MetadataSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });
}
