import 'package:flutter/material.dart';
import '../home/pages/home_page.dart';
import '../exercises/pages/exercises_list_page.dart';
import '../profile/pages/profile_page.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/app_header.dart';

/// Page principale avec navigation par bottom bar
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 2; // Home au centre (index 2)

  final List<Widget> _pages = [
    const ProfilePage(),
    ExercisesListPage(),
    const HomePage(), // Home au centre
    _PlaceholderPage(
      title: 'Templates',
      icon: Icons.description,
      showHeader: true,
    ),
    _PlaceholderPage(title: 'Histoire', icon: Icons.history, showHeader: true),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to extend behind bottom navigation bar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Page placeholder pour les pages non encore implémentées
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.icon,
    this.showHeader = false,
  });

  final String title;
  final IconData icon;
  final bool showHeader;

  Future<void> _handleRefresh() async {
    // Attendre un peu pour l'animation de refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showHeader ? AppHeader(title: title, showBackButton: true) : null,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cette page sera bientôt disponible',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
