/// Extensions utilitaires pour les String
extension StringExtensions on String {
  /// Capitalise la première lettre de la chaîne
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalise chaque mot de la chaîne
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Retourne true si la chaîne est vide ou ne contient que des espaces
  bool get isBlank => trim().isEmpty;

  /// Retourne true si la chaîne n'est pas vide
  bool get isNotBlank => !isBlank;
}
