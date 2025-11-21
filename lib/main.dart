import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/asset_verifier.dart';
import 'core/firebase/firebase_init.dart';
import 'di/service_locator.dart';
import 'features/auth/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec test de connexion en mode debug
  await initializeFirebase(testConnection: true);

  // Vérification des assets
  AssetVerifier.printAssetPaths();
  final assetsOk = await AssetVerifier.verifyAllAssets();
  if (!assetsOk) {
    print('⚠️ ATTENTION: Certains assets ne sont pas disponibles!');
    print('   Assurez-vous que les fichiers JSON sont dans assets/data/');
    print('   et que pubspec.yaml contient les bons chemins.');
  } else {
    print('✅ Tous les assets sont disponibles');
  }

  // Initialisation des services
  await ServiceLocator.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: const Color(
            0xFFF5F1E8,
          ), // Fond beige/crème comme le header
          statusBarIconBrightness: Brightness.dark,
        ),
        child: const AuthWrapper(),
      ),
    );
  }
}
