/// Exceptions personnalisées pour l'application
/// Permet une gestion d'erreurs claire et typée

/// Exception de base pour toutes les erreurs de l'application
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);
  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Exception pour les erreurs de base de données
class AppDatabaseException extends AppException {
  const AppDatabaseException(super.message, [super.code]);
}

/// Exception pour les erreurs de chargement de données
class DataLoadException extends AppException {
  const DataLoadException(super.message, [super.code]);
}

/// Exception pour les erreurs de parsing JSON
class JsonParseException extends AppException {
  const JsonParseException(super.message, [super.code]);
}

/// Exception pour les erreurs de fichier/asset
class AssetException extends AppException {
  const AssetException(super.message, [super.code]);
}
