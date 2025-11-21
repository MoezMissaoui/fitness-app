import '../repositories/exercise_repository.dart';
import '../services/database_service.dart';
import '../services/reference_data_service.dart';

/// Service Locator pour l'injection de dépendances
/// Pattern Singleton pour centraliser l'accès aux services
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  // Services
  DatabaseService? _databaseService;
  ReferenceDataService? _referenceDataService;

  // Repositories
  ExerciseRepository? _exerciseRepository;

  /// Initialise tous les services
  Future<void> init() async {
    // Initialisation des services
    _databaseService = DatabaseService();
    _referenceDataService = ReferenceDataService();

    // Initialisation de la base de données (charge les données si nécessaire)
    await _databaseService!.database;

    // Initialisation des repositories
    _exerciseRepository = ExerciseRepositoryImpl(_databaseService!);
  }

  /// Récupère le service de base de données
  DatabaseService get databaseService {
    if (_databaseService == null) {
      throw StateError('ServiceLocator non initialisé. Appelez init() d\'abord.');
    }
    return _databaseService!;
  }

  /// Récupère le service de données de référence
  ReferenceDataService get referenceDataService {
    if (_referenceDataService == null) {
      throw StateError('ServiceLocator non initialisé. Appelez init() d\'abord.');
    }
    return _referenceDataService!;
  }

  /// Récupère le repository d'exercices
  ExerciseRepository get exerciseRepository {
    if (_exerciseRepository == null) {
      throw StateError('ServiceLocator non initialisé. Appelez init() d\'abord.');
    }
    return _exerciseRepository!;
  }

  /// Réinitialise tous les services (utile pour les tests)
  Future<void> reset() async {
    await _databaseService?.closeDatabase();
    _databaseService = null;
    _referenceDataService = null;
    _exerciseRepository = null;
  }
}

