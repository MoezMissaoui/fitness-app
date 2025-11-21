import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/exercise.dart';
import '../../../repositories/exercise_repository.dart';
import '../../../di/service_locator.dart';
import '../widgets/exercise_list_item.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/exercise_detail_bottom_sheet.dart';

/// Page principale affichant la liste des exercices
/// Démonstration d'une implémentation professionnelle avec gestion d'état
class ExercisesListPage extends StatefulWidget {
  const ExercisesListPage({
    super.key,
    this.initialBodyPart,
    this.initialEquipment,
    this.initialMuscle,
  });

  final String? initialBodyPart;
  final String? initialEquipment;
  final String? initialMuscle;

  @override
  State<ExercisesListPage> createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends State<ExercisesListPage> {
  final ExerciseRepository _repository =
      ServiceLocator.instance.exerciseRepository;
  final TextEditingController _searchController = TextEditingController();
  final _authService = ServiceLocator.instance.authService;

  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  List<String> _selectedBodyParts = [];
  List<String> _selectedEquipments = [];
  List<String> _selectedMuscles = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Initialiser avec les valeurs passées en paramètre
    if (widget.initialBodyPart != null) {
      _selectedBodyParts = [widget.initialBodyPart!];
    }
    if (widget.initialEquipment != null) {
      _selectedEquipments = [widget.initialEquipment!];
    }
    if (widget.initialMuscle != null) {
      _selectedMuscles = [widget.initialMuscle!];
    }
    _loadExercises();
  }

  void _loadUserData() {
    if (!mounted) return;
    setState(() {
      _currentUser = _authService.currentUser;
    });
  }

  String _getUserName() {
    return _currentUser?.displayName ??
        _currentUser?.email?.split('@')[0] ??
        'Utilisateur';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Gère le refresh (pull-to-refresh)
  Future<void> _handleRefresh() async {
    // Recharger les exercices
    await _loadExercises();
    // Recharger les données utilisateur
    _loadUserData();
  }

  /// Charge les exercices avec les filtres actuels
  Future<void> _loadExercises() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getExercisesWithFilters(
      bodyParts: _selectedBodyParts,
      equipments: _selectedEquipments,
      muscles: _selectedMuscles,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      result.map((exercises) {
        _exercises = exercises;
        _errorMessage = null;
      });
      if (result.isFailure) {
        final failure = result as Failure<List<Exercise>>;
        _errorMessage = failure.error.toString();
        _exercises = [];
      }
    });
  }

  /// Gère la recherche
  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() {
      _searchQuery = query;
    });
    _loadExercises();
  }

  /// Gère le changement de filtres de partie du corps
  void _onBodyPartsChanged(List<String> bodyParts) {
    if (!mounted) return;
    setState(() {
      _selectedBodyParts = bodyParts;
    });
    _loadExercises();
  }

  /// Gère le changement de filtres d'équipement
  void _onEquipmentsChanged(List<String> equipments) {
    if (!mounted) return;
    setState(() {
      _selectedEquipments = equipments;
    });
    _loadExercises();
  }

  /// Gère le changement de filtres de muscle
  void _onMusclesChanged(List<String> muscles) {
    if (!mounted) return;
    setState(() {
      _selectedMuscles = muscles;
    });
    _loadExercises();
  }

  /// Réinitialise tous les filtres
  void _clearFilters() {
    if (!mounted) return;
    setState(() {
      _searchQuery = '';
      _selectedBodyParts = [];
      _selectedEquipments = [];
      _selectedMuscles = [];
    });
    _searchController.clear();
    _loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        userName: _getUserName(),
        showActionButton: true,
        showGreeting: false,
        showCalories: true,
      ),
      body: GestureDetector(
        onTap: () {
          // Hide keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = Responsive.padding(context);
              final spacing = Responsive.spacing(context, 24);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header avec recherche et filtres
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: padding.left,
                        right: padding.right,
                        bottom: padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Barre de recherche
                          _buildSearchBar(context),

                          SizedBox(height: spacing * 0.67),

                          // Filtres
                          _buildFiltersSection(context),

                          SizedBox(height: spacing),

                          // Titre de la section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Exercices',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (_exercises.isNotEmpty && !_isLoading)
                                Text(
                                  '${_exercises.length} exercices',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.darkGrey),
                                ),
                            ],
                          ),

                          SizedBox(height: spacing * 0.67),
                        ],
                      ),
                    ),
                  ),

                  // Liste des exercices avec lazy loading
                  _buildExercisesListSliver(context, padding, spacing),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Rechercher un exercice...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: AppTheme.lightBlue),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _loadExercises();
                      },
                    )
                    : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final hasActiveFilters =
        _selectedBodyParts.isNotEmpty ||
        _selectedEquipments.isNotEmpty ||
        _selectedMuscles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                'Body Parts',
                _selectedBodyParts,
                Icons.accessibility_new,
                AppTheme.lightBlue,
                () => _showFilterDialog(
                  context,
                  'Body Parts',
                  Icons.accessibility_new,
                  _onBodyPartsChanged,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              _buildFilterChip(
                context,
                'Equipment',
                _selectedEquipments,
                Icons.fitness_center,
                AppTheme.lightPurple,
                () => _showFilterDialog(
                  context,
                  'Equipment',
                  Icons.fitness_center,
                  _onEquipmentsChanged,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              _buildFilterChip(
                context,
                'Muscles',
                _selectedMuscles,
                Icons.emoji_people,
                Colors.orange.shade300,
                () => _showFilterDialog(
                  context,
                  'Muscles',
                  Icons.emoji_people,
                  _onMusclesChanged,
                ),
              ),
              if (hasActiveFilters) ...[
                SizedBox(width: Responsive.spacing(context, 8)),
                _buildClearAllButton(context),
              ],
            ],
          ),
        ),
        // Indicateur de filtres actifs
        if (hasActiveFilters) ...[
          SizedBox(height: Responsive.spacing(context, 8)),
          _buildActiveFiltersIndicator(context),
        ],
      ],
    );
  }

  Widget _buildClearAllButton(BuildContext context) {
    return GestureDetector(
      onTap: _clearFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_all, size: 18, color: Colors.red.shade700),
            const SizedBox(width: 6),
            Text(
              'Clear All',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersIndicator(BuildContext context) {
    final activeFilters = <String>[];
    activeFilters.addAll(_selectedBodyParts);
    activeFilters.addAll(_selectedEquipments);
    activeFilters.addAll(_selectedMuscles);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, 12),
        vertical: Responsive.spacing(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16, color: AppTheme.lightBlue),
          SizedBox(width: Responsive.spacing(context, 8)),
          Flexible(
            child: Text(
              '${activeFilters.length} filter${activeFilters.length > 1 ? 's' : ''} active',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Text(
              activeFilters.join(', '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(
    BuildContext context,
    String title,
    IconData icon,
    ValueChanged<List<String>> onChanged,
  ) async {
    try {
      final refService = ServiceLocator.instance.referenceDataService;
      List<String> items = [];

      if (title == 'Body Parts') {
        items = await refService.getBodyParts();
      } else if (title == 'Equipment') {
        items = await refService.getEquipments();
      } else if (title == 'Muscles') {
        items = await refService.getMuscles();
      }

      if (!mounted) return;
      final navigatorContext = context;

      await showModalBottomSheet<void>(
        context: navigatorContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (dialogContext) => FilterBottomSheet(
              title: title,
              icon: icon,
              items: items,
              currentSelections:
                  title == 'Body Parts'
                      ? _selectedBodyParts
                      : title == 'Equipment'
                      ? _selectedEquipments
                      : _selectedMuscles,
              onSelectionChanged: (selections) {
                // Apply changes in real-time
                onChanged(selections);
              },
            ),
      );
    } catch (e) {
      if (!mounted) return;
      final messengerContext = context;
      ScaffoldMessenger.of(
        messengerContext,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du chargement: $e')));
    }
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    List<String> selectedValues,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isSelected = selectedValues.isNotEmpty;
    final displayText =
        selectedValues.isEmpty
            ? label
            : selectedValues.length == 1
            ? selectedValues.first
            : '${selectedValues.length} selected';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.3)
                        : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.darkGrey,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedValues.length > 1) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${selectedValues.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (label == 'Body Parts') {
                    _onBodyPartsChanged([]);
                  } else if (label == 'Equipment') {
                    _onEquipmentsChanged([]);
                  } else if (label == 'Muscles') {
                    _onMusclesChanged([]);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesListSliver(
    BuildContext context,
    EdgeInsets padding,
    double spacing,
  ) {
    if (_isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: Responsive.fontSize(context, 64),
                  color: Colors.red,
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                Text(
                  'Erreur',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: Responsive.spacing(context, 8)),
                Padding(
                  padding: Responsive.horizontalPadding(context),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                ElevatedButton(
                  onPressed: _loadExercises,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_exercises.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: Responsive.fontSize(context, 64),
                  color: Colors.grey,
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                Text(
                  'Aucun exercice trouvé',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: Responsive.spacing(context, 8)),
                Text(
                  'Essayez de modifier vos filtres de recherche',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Liste avec lazy loading pour les performances
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return ExerciseListItem(
          exercise: _exercises[index],
          onTap: () {
            ExerciseDetailBottomSheet.show(context, _exercises[index]);
          },
        );
      }, childCount: _exercises.length),
    );
  }
}
