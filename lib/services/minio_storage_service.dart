import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/result.dart';
import '../core/errors/app_exceptions.dart';

/// Service pour gérer l'upload de fichiers vers MinIO (S3-compatible)
class MinIOStorageService {
  // Configuration MinIO
  static const String endPoint = 's3.minio.51.75.73.102.nip.io';
  static const int port = 443;
  static const bool useSSL = true;
  static const String accessKey = 'moez@ght';
  static const String secretKey = '12547?ghT';
  static const String bucketName = 'fitnessapp';
  static const String region = 'us-east-1';

  late final Dio _dio;
  String get _baseUrl => '${useSSL ? 'https' : 'http'}://$endPoint:$port';

  MinIOStorageService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// Upload une image de profil pour l'utilisateur actuel
  Future<Result<String>> uploadProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Failure(AuthException('Aucun utilisateur connecté'));
      }

      // Vérifier que le fichier existe
      if (!await imageFile.exists()) {
        return const Failure(AuthException('Le fichier image n\'existe pas'));
      }

      // Chemin du fichier dans MinIO
      final objectKey = 'profile_images/${user.uid}.jpg';

      // Lire le fichier
      final fileBytes = await imageFile.readAsBytes();
      final contentType = 'image/jpeg';

      // Créer la requête PUT signée
      final url = '/$bucketName/$objectKey';
      final date = DateTime.now().toUtc();
      final dateString = _getDateString(date);
      final dateTimeString = _getDateTimeString(date);

      // Headers nécessaires pour la signature
      final headers = <String, String>{
        'Host': '$endPoint:$port',
        'Date': dateTimeString,
        'Content-Type': contentType,
        'Content-Length': fileBytes.length.toString(),
      };

      // Créer la signature AWS S3
      final signature = _generateSignature(
        method: 'PUT',
        url: url,
        headers: headers,
        dateString: dateString,
        dateTimeString: dateTimeString,
      );

      // Headers avec signature
      final authHeader = 'AWS $accessKey:$signature';
      headers['Authorization'] = authHeader;

      // Upload le fichier
      try {
        final response = await _dio.put(
          url,
          data: fileBytes,
          options: Options(headers: headers, contentType: contentType),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Construire l'URL de téléchargement
          final downloadUrl = '$_baseUrl/$bucketName/$objectKey';
          return Success(downloadUrl);
        } else {
          return Failure(
            AuthException('Erreur lors de l\'upload: ${response.statusCode}'),
            StackTrace.current,
          );
        }
      } on DioException catch (e) {
        String errorMessage;
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final statusMessage = e.response!.statusMessage;
          final message = e.message;
          
          // Messages d'erreur spécifiques selon le code HTTP
          switch (statusCode) {
            case 502:
              errorMessage = 'Erreur 502: Bad Gateway. Le serveur MinIO est inaccessible ou le proxy ne répond pas. Vérifiez que le serveur est en ligne.';
              break;
            case 503:
              errorMessage = 'Erreur 503: Service Unavailable. Le serveur MinIO est temporairement indisponible.';
              break;
            case 504:
              errorMessage = 'Erreur 504: Gateway Timeout. Le serveur MinIO met trop de temps à répondre.';
              break;
            case 403:
              errorMessage = 'Erreur 403: Forbidden. Vérifiez vos credentials (accessKey/secretKey) et les permissions du bucket.';
              break;
            case 404:
              errorMessage = 'Erreur 404: Not Found. Le bucket "$bucketName" n\'existe pas. Créez-le dans MinIO.';
              break;
            case 401:
              errorMessage = 'Erreur 401: Unauthorized. La signature AWS S3 est invalide. Vérifiez vos credentials.';
              break;
            default:
              errorMessage = 'Erreur $statusCode: ${statusMessage ?? message ?? 'Erreur inconnue'}';
          }
        } else {
          // Erreur de connexion réseau
          if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Timeout de connexion. Le serveur MinIO ne répond pas. Vérifiez l\'endpoint: $endPoint:$port';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Timeout de réception. Le serveur MinIO met trop de temps à répondre.';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = 'Erreur de connexion. Impossible de joindre le serveur MinIO à $endPoint:$port. Vérifiez votre connexion réseau.';
          } else {
            errorMessage = 'Erreur de connexion: ${e.message ?? 'Erreur inconnue'}';
          }
        }
        final stackTrace = e.stackTrace;
        return Failure(
          AuthException('Erreur lors de l\'upload: $errorMessage'),
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      return Failure(
        AuthException('Erreur inattendue lors de l\'upload: ${e.toString()}'),
        stackTrace,
      );
    }
  }

  /// Supprime l'image de profil de l'utilisateur actuel
  Future<Result<void>> deleteProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Failure(AuthException('Aucun utilisateur connecté'));
      }

      final objectKey = 'profile_images/${user.uid}.jpg';
      final url = '/$bucketName/$objectKey';

      final date = DateTime.now().toUtc();
      final dateString = _getDateString(date);
      final dateTimeString = _getDateTimeString(date);

      final headers = <String, String>{
        'Host': '$endPoint:$port',
        'Date': dateTimeString,
      };

      final signature = _generateSignature(
        method: 'DELETE',
        url: url,
        headers: headers,
        dateString: dateString,
        dateTimeString: dateTimeString,
      );

      headers['Authorization'] = 'AWS $accessKey:$signature';

      try {
        await _dio.delete(url, options: Options(headers: headers));
        return const Success(null);
      } on DioException catch (e) {
        // Si le fichier n'existe pas, ce n'est pas une erreur critique
        if (e.response != null && e.response!.statusCode == 404) {
          return const Success(null);
        }
        final errorMsg = e.message ?? 'Erreur inconnue';
        final stackTrace = e.stackTrace;
        return Failure(
          AuthException('Erreur lors de la suppression: $errorMsg'),
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      return Failure(
        AuthException(
          'Erreur inattendue lors de la suppression: ${e.toString()}',
        ),
        stackTrace,
      );
    }
  }

  /// Génère la signature AWS S3 pour l'authentification (Signature Version 2)
  String _generateSignature({
    required String method,
    required String url,
    required Map<String, String> headers,
    required String dateString,
    required String dateTimeString,
  }) {
    // Pour AWS Signature Version 2, on utilise le format simplifié
    // MinIO supporte aussi Signature Version 2

    // Extraire le chemin de l'URL (sans le query string)
    final uri = Uri.parse(url);
    final path = uri.path;

    // Construire le StringToSign pour Signature Version 2
    final contentMd5 = headers['Content-MD5'] ?? '';
    final contentType = headers['Content-Type'] ?? '';

    final stringToSign = [
      method,
      contentMd5,
      contentType,
      dateTimeString,
      path,
    ].join('\n');

    // Calculer la signature HMAC-SHA1
    final key = utf8.encode(secretKey);
    final message = utf8.encode(stringToSign);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(message);
    final signature = base64Encode(digest.bytes);

    return signature;
  }

  String _getDateString(DateTime date) {
    // Format: YYYYMMDD
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  String _getDateTimeString(DateTime date) {
    // Format: Mon, DD MMM YYYY HH:MM:SS GMT
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return '$weekday, $day $month $year $hour:$minute:$second GMT';
  }
}
