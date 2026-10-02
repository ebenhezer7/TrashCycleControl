import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

/// Service untuk menangani komunikasi REST API dengan server backend Laravel.
class ApiService {
  // Base URL endpoint API Laravel.
  // Gunakan '10.0.2.2' jika menggunakan Emulator Android bawaan Android Studio.
  // Gunakan IP lokal PC (contoh: 'http://192.168.1.10:8000/api/v1') jika menggunakan Device Fisik.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Key untuk menyimpan token autentikasi di SharedPreferences
  static const String tokenKey = 'auth_token';

  // Batas waktu tunggu HTTP Request
  static const Duration timeoutDuration = Duration(seconds: 10);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Helper internal untuk mengambil HTTP Headers beserta Authorization Bearer Token jika tersedia.
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// 1. Autentikasi (Login) Petugas Lapangan.
  /// HTTP POST -> `/api/v1/auth/login`
  ///
  /// Menyimpan token ke SharedPreferences jika login berhasil.
  /// Mengembalikan Map berisi `{'success': bool, 'message': String}`.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse('$baseUrl/auth/login');

    try {
      final Map<String, dynamic> payload = {
        'email': email,
        'password': password,
      };

      developer.log('Mengirim request login ke $url', name: 'ApiService');

      final response = await _client
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(timeoutDuration);

      developer.log('Login status code: ${response.statusCode}', name: 'ApiService');

      final dynamic decodedBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? token;
        if (decodedBody is Map<String, dynamic>) {
          token = decodedBody['token'] as String? ??
              decodedBody['access_token'] as String? ??
              decodedBody['data']?['token'] as String?;
        }

        if (token != null && token.isNotEmpty) {
          // Simpan token ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey, token);

          return {
            'success': true,
            'message': 'Login berhasil',
            'token': token,
          };
        } else {
          return {
            'success': false,
            'message': 'Login berhasil namun token tidak ditemukan dalam respons server.',
          };
        }
      } else {
        String errorMessage = 'Login gagal. Silakan periksa email dan password.';
        if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('message')) {
          errorMessage = decodedBody['message'].toString();
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on SocketException catch (e) {
      developer.log('Koneksi gagal saat login (SocketException): $e', name: 'ApiService', level: 1000);
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Pastikan server Laravel sudah berjalan dan internet aktif.',
      };
    } on TimeoutException catch (e) {
      developer.log('Timeout saat login: $e', name: 'ApiService', level: 1000);
      return {
        'success': false,
        'message': 'Koneksi ke server timeout. Silakan coba beberapa saat lagi.',
      };
    } catch (e) {
      developer.log('Exception saat login: $e', name: 'ApiService', level: 1000);
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga saat login: $e',
      };
    }
  }

  /// Memeriksa apakah pengguna sudah terautentikasi (memiliki token di SharedPreferences).
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Mengambil token tersimpan dari SharedPreferences.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Menghapus token dari SharedPreferences (Logout).
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(tokenKey);
  }

  /// 2. Mengambil daftar alat daur ulang beserta status sensor dan alert terbarunya.
  /// HTTP GET -> `/api/v1/devices`
  Future<List<DeviceModel>> fetchDevices() async {
    final Uri url = Uri.parse('$baseUrl/devices');

    try {
      developer.log('Fetching devices from: $url', name: 'ApiService');

      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers).timeout(timeoutDuration);

      developer.log('fetchDevices status code: ${response.statusCode}', name: 'ApiService');

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> jsonList;
        if (decodedData is List) {
          jsonList = decodedData;
        } else if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
          jsonList = decodedData['data'] as List<dynamic>;
        } else {
          jsonList = [];
        }

        return jsonList
            .map((item) => DeviceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        developer.log(
          'Server error saat fetchDevices. Status: ${response.statusCode}, Body: ${response.body}',
          name: 'ApiService',
          level: 900,
        );
        throw HttpException('Server merespons dengan status code ${response.statusCode}');
      }
    } on SocketException catch (e) {
      developer.log(
        'Koneksi gagal / Server belum berjalan (SocketException): $e',
        name: 'ApiService',
        level: 1000,
      );
      throw Exception('Tidak dapat terhubung ke server. Pastikan server Laravel sudah berjalan dan koneksi internet aktif.');
    } on TimeoutException catch (e) {
      developer.log('Request timeout: $e', name: 'ApiService', level: 1000);
      throw Exception('Koneksi ke server timeout. Silakan coba beberapa saat lagi.');
    } on FormatException catch (e) {
      developer.log('Format JSON tidak sesuai: $e', name: 'ApiService', level: 1000);
      throw Exception('Format data dari server tidak valid.');
    } catch (e) {
      developer.log('Kesalahan tidak terduga saat fetchDevices: $e', name: 'ApiService', level: 1000);
      rethrow;
    }
  }

  /// 3. Mengirimkan log tindakan perbaikan saat petugas lapangan menekan tombol "Tandai Selesai".
  /// HTTP POST -> `/api/v1/actions`
  Future<bool> resolveAction(String deviceId, String actionText) async {
    final Uri url = Uri.parse('$baseUrl/actions');

    try {
      final Map<String, dynamic> payload = {
        'device_id': deviceId,
        'action_text': actionText,
        'timestamp': DateTime.now().toIso8601String(),
      };

      developer.log('Mengirim log tindakan ke $url: $payload', name: 'ApiService');

      final headers = await _getHeaders();
      final response = await _client
          .post(
            url,
            headers: headers,
            body: json.encode(payload),
          )
          .timeout(timeoutDuration);

      developer.log('resolveAction status code: ${response.statusCode}', name: 'ApiService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('Log tindakan berhasil dikirim.', name: 'ApiService');
        return true;
      } else {
        developer.log(
          'Gagal mengirim log tindakan. Status: ${response.statusCode}, Body: ${response.body}',
          name: 'ApiService',
          level: 900,
        );
        return false;
      }
    } on SocketException catch (e) {
      developer.log('Koneksi gagal saat resolveAction (SocketException): $e', name: 'ApiService', level: 1000);
      return false;
    } on TimeoutException catch (e) {
      developer.log('Timeout saat resolveAction: $e', name: 'ApiService', level: 1000);
      return false;
    } catch (e) {
      developer.log('Exception saat resolveAction: $e', name: 'ApiService', level: 1000);
      return false;
    }
  }

  /// Method kompatibilitas jika dipanggil dengan nama fungsi lama
  Future<bool> postActionLog(String deviceId, String action) async {
    return resolveAction(deviceId, action);
  }
}
