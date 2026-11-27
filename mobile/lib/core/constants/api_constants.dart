/// Konfigurasi URL dan Timeout REST API Backend Laravel
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String tokenKey = 'auth_token';
  static const Duration timeoutDuration = Duration(seconds: 10);
}
