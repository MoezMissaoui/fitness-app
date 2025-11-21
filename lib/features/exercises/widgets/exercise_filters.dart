import 'package:flutter/material.dart';
import '../../../di/service_locator.dart';

/// Widget pour les filtres de recherche d'exercices
class ExerciseFilters extends StatefulWidget {
  const ExerciseFilters({
    super.key,
    required this.searchQuery,
    required this.selectedBodyPart,
    required this.selectedEquipment,
    required this.selectedMuscle,
    required this.onSearchChanged,
    required this.onBodyPartChanged,
    required this.onEquipmentChanged,
    required this.onMuscleChanged,
  });

  final String searchQuery;
  final String? selectedBodyPart;
  final String? selectedEquipment;
  final String? selectedMuscle;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onBodyPartChanged;
  final ValueChanged<String?> onEquipmentChanged;
  final ValueChanged<String?> onMuscleChanged;

  @override
  State<ExerciseFilters> createState() => _ExerciseFiltersState();
}

class _ExerciseFiltersState extends State<ExerciseFilters> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _bodyParts = [];
  List<String> _equipments = [];
  List<String> _muscles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _loadReferenceData();
  }

  @override
  void didUpdateWidget(ExerciseFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  Future<void> _loadReferenceData() async {
    try {
      final refService = ServiceLocator.instance.referenceDataService;
      final bodyParts = await refService.getBodyParts();
      final equipments = await refService.getEquipments();
      final muscles = await refService.getMuscles();

      setState(() {
        _bodyParts = bodyParts;
        _equipments = equipments;
        _muscles = muscles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des filtres: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildFilterDropdown(
                  'Partie du corps',
                  widget.selectedBodyPart,
                  _bodyParts,
                  widget.onBodyPartChanged,
                  Icons.accessibility_new,
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  'Équipement',
                  widget.selectedEquipment,
                  _equipments,
                  widget.onEquipmentChanged,
                  Icons.fitness_center,
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  'Muscle',
                  widget.selectedMuscle,
                  _muscles,
                  widget.onMuscleChanged,
                  Icons.emoji_people,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedValue != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          width: selectedValue != null ? 2 : 1,
        ),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        hint: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Tous les $label'),
          ),
          ...items.map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          ),
        ],
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        isDense: true,
      ),
    );
  }
}

