/// Konfigurasi URL dan Timeout REST API Backend Laravel
class ApiConstants {
  static const String baseUrl = 'http://192.168.100.79:8000/api';
  static const String tokenKey = 'auth_token';
  static const Duration timeoutDuration = Duration(seconds: 10);
}
