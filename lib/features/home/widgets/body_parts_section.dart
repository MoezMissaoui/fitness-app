import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/body_part_icons.dart';
import '../../../di/service_locator.dart';
import '../../../features/exercises/pages/exercises_list_page.dart';

/// Section des parties du corps (Body Parts)
class BodyPartsSection extends StatefulWidget {
  const BodyPartsSection({super.key});

  @override
  State<BodyPartsSection> createState() => _BodyPartsSectionState();
}

class _BodyPartsSectionState extends State<BodyPartsSection> {
  List<String> _bodyParts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBodyParts();
  }

  Future<void> _loadBodyParts() async {
    try {
      final refService = ServiceLocator.instance.referenceDataService;
      final bodyParts = await refService.getBodyParts();
      setState(() {
        _bodyParts = bodyParts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des parties du corps: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Responsive.spacing(context, 16);
    final itemHeight = Responsive.isMobile(context) ? 88.0 : 100.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Parts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: spacing * 0.5),
        SizedBox(
          height: itemHeight,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _bodyParts.length,
                  itemBuilder: (context, index) {
                    final bodyPart = _bodyParts[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _bodyParts.length - 1 ? spacing : 0,
                      ),
                      child: BodyPartItem(
                        icon: _getIconForBodyPart(bodyPart),
                        label: bodyPart,
                        color: _getColorForIndex(index),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisesListPage(
                                initialBodyPart: bodyPart,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getIconForBodyPart(String bodyPart) {
    // Utilise la classe utilitaire pour obtenir l'icône appropriée
    return BodyPartIcons.getIcon(bodyPart);
  }

  Color _getColorForIndex(int index) {
    return index % 2 == 0 ? AppTheme.lightPurple : AppTheme.lightBlue;
  }
}

/// Item de partie du corps individuel
class BodyPartItem extends StatelessWidget {
  const BodyPartItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 64.0 : 72.0;
    final iconInnerSize = isMobile ? 32.0 : 36.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlack,
              size: iconInnerSize,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 6)),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

