/// Classe Result pour gérer les succès et erreurs de manière fonctionnelle
/// Pattern inspiré de Rust/Swift pour une meilleure gestion d'erreurs
sealed class Result<T> {
  const Result();
}

/// Succès avec une valeur
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

/// Erreur avec un message
final class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}

/// Extensions pour faciliter l'utilisation de Result
extension ResultExtensions<T> on Result<T> {
  /// Retourne true si c'est un succès
  bool get isSuccess => this is Success<T>;

  /// Retourne true si c'est une erreur
  bool get isFailure => this is Failure<T>;

  /// Récupère la valeur si succès, sinon null
  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Failure() => null,
  };

  /// Récupère la valeur si succès, sinon lance une exception
  T get valueOrThrow => switch (this) {
    Success(value: final v) => v,
    Failure(error: final e, stackTrace: final st) =>
      throw st != null ? Error.throwWithStackTrace(e, st) : e,
  };

  /// Exécute une fonction si succès
  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
    Success(value: final v) => Success(mapper(v)),
    Failure(error: final e, stackTrace: final st) => Failure(e, st),
  };

  /// Exécute une fonction asynchrone si succès
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) mapper) async =>
      switch (this) {
        Success(value: final v) => Success(await mapper(v)),
        Failure(error: final e, stackTrace: final st) => Failure(e, st),
      };
}
