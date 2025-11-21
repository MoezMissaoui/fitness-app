import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_header.dart';
import '../../../di/service_locator.dart';
import '../../../features/exercises/pages/exercises_list_page.dart';
import '../widgets/body_parts_section.dart';
import '../widgets/training_card.dart';

/// Page d'accueil principale avec entraînements
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authService = ServiceLocator.instance.authService;
    setState(() {
      _currentUser = authService.currentUser;
    });
  }

  String _getUserName() {
    return _currentUser?.displayName ??
        _currentUser?.email?.split('@')[0] ??
        'Utilisateur';
  }

  Future<void> _handleRefresh() async {
    // Recharger les données utilisateur
    _loadUserData();
    // Attendre un peu pour l'animation de refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        userName: _getUserName(),
        showActionButton: true,
        actionIcon: Icons.flash_on,
        onActionPressed: () {
          // TODO: Action rapide
        },
      ),
      drawer: _buildDrawer(context),
      // Pas de bottomNavigationBar ici car géré par MainNavigationPage
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = Responsive.padding(context);
          final spacing = Responsive.spacing(context, 10);

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
                top: 20,
                bottom: padding.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth:
                      Responsive.isDesktop(context) ? 1200 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Body Parts
                    const BodyPartsSection(),
                    SizedBox(height: spacing),

                    // Section Trainings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trainings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Naviguer vers toutes les trainings
                          },
                          child: const Text('See all'),
                        ),
                      ],
                    ),

                    SizedBox(height: spacing),

                    // Cartes d'entraînements - Responsive grid
                    _buildTrainingsSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrainingsSection(BuildContext context) {
    final trainings = [
      TrainingCard(
        title: 'Functional training',
        duration: '40 min',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        backgroundColor: AppTheme.lightBlue,
      ),
      TrainingCard(
        title: 'Yoga for Beginners',
        duration: '25 min',
        imageUrl:
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400',
        backgroundColor: AppTheme.lightPurple,
      ),
    ];

    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          for (var i = 0; i < trainings.length; i++) ...[
            trainings[i],
            if (i < trainings.length - 1)
              SizedBox(height: Responsive.spacing(context, 12)),
          ],
        ],
      );
    } else {
      return Wrap(
        spacing: Responsive.spacing(context, 16),
        runSpacing: Responsive.spacing(context, 16),
        children:
            trainings.map((training) {
              return SizedBox(
                width:
                    Responsive.isDesktop(context)
                        ? (Responsive.screenWidth(context) -
                                Responsive.padding(context).horizontal * 2 -
                                Responsive.spacing(context, 16)) /
                            2
                        : double.infinity,
                child: training,
              );
            }).toList(),
      );
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header du drawer avec profil
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.lightPurple, AppTheme.lightBlue],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Jane Doe',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'jane.doe@example.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Exercises'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExercisesListPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers Analytics
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers Favorites
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers Help
            },
          ),
        ],
      ),
    );
  }
}
