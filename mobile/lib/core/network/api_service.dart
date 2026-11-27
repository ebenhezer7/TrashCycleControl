import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/dashboard/data/models/device_model.dart';
import '../constants/api_constants.dart';
import '../services/log_service.dart';

/// Service HTTP Client Terpusat untuk REST API Laravel Backend.
class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String tokenKey = ApiConstants.tokenKey;
  static const Duration timeoutDuration = ApiConstants.timeoutDuration;

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

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
  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse('$baseUrl/auth/login');

    try {
      final Map<String, dynamic> payload = {
        'email': email,
        'password': password,
      };

      Log.info('Mengirim request login ke $url');

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

      final dynamic decodedBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? token;
        if (decodedBody is Map<String, dynamic>) {
          token = decodedBody['token'] as String? ??
              decodedBody['access_token'] as String? ??
              decodedBody['data']?['token'] as String?;
        }

        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey, token);

          Log.info('Login berhasil. Token tersimpan.');
          return {
            'success': true,
            'message': 'Login berhasil',
            'token': token,
          };
        } else {
          Log.warning('Response 200/201 tanpa token.');
          return {
            'success': false,
            'message': 'Login berhasil namun token tidak ditemukan.',
          };
        }
      } else {
        String errorMessage = 'Login gagal. Silakan periksa email dan password.';
        if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('message')) {
          errorMessage = decodedBody['message'].toString();
        }

        Log.warning('Login gagal. Status: ${response.statusCode}, Msg: $errorMessage');
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on SocketException catch (e, stackTrace) {
      Log.error('Koneksi terputus saat login', e, stackTrace);
      throw Exception('Koneksi terputus. Periksa jaringan internet Anda.');
    } on TimeoutException catch (e, stackTrace) {
      Log.error('Timeout saat login', e, stackTrace);
      throw Exception('Koneksi terputus. Periksa jaringan internet Anda.');
    } catch (e, stackTrace) {
      Log.error('Exception tidak terduga saat login', e, stackTrace);
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga saat login: $e',
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    Log.info('User logout. Token dihapus.');
    return await prefs.remove(tokenKey);
  }

  /// 2. Mengambil daftar alat daur ulang beserta status sensor dan alert terbarunya.
  Future<List<DeviceModel>> fetchDevices() async {
    final Uri url = Uri.parse('$baseUrl/devices');

    try {
      Log.info('Fetching devices telemetry from $url');

      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers).timeout(timeoutDuration);

      if (response.statusCode == 401) {
        Log.warning('HTTP 401 Unauthorized pada fetchDevices.');
        await logout();
        throw Exception('Sesi habis. Silakan login kembali.');
      }

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

        final devices = jsonList
            .map((item) => DeviceModel.fromJson(item as Map<String, dynamic>))
            .toList();

        Log.info('Berhasil memuat ${devices.length} devices.');
        return devices;
      } else {
        Log.error('Server error HTTP ${response.statusCode} saat fetchDevices.');
        throw HttpException('Server merespons dengan status code ${response.statusCode}');
      }
    } on SocketException catch (e, stackTrace) {
      Log.error('Koneksi terputus saat fetchDevices (SocketException)', e, stackTrace);
      throw Exception('Koneksi terputus. Periksa jaringan internet Anda.');
    } on TimeoutException catch (e, stackTrace) {
      Log.error('Timeout saat fetchDevices (TimeoutException)', e, stackTrace);
      throw Exception('Koneksi terputus. Periksa jaringan internet Anda.');
    } on FormatException catch (e, stackTrace) {
      Log.error('JSON malformed saat fetchDevices (FormatException)', e, stackTrace);
      throw FormatException('Format data dari server tidak valid: ${e.message}');
    } catch (e, stackTrace) {
      Log.error('Unhandled exception saat fetchDevices', e, stackTrace);
      rethrow;
    }
  }

  /// 3. Mengirimkan log tindakan perbaikan saat petugas lapangan menekan tombol "Tandai Selesai".
  Future<bool> resolveAction(String deviceId, String actionText) async {
    final Uri url = Uri.parse('$baseUrl/actions');

    try {
      final Map<String, dynamic> payload = {
        'device_id': deviceId,
        'action_text': actionText,
        'timestamp': DateTime.now().toIso8601String(),
      };

      Log.info('Sending resolve action to $url for device $deviceId');

      final headers = await _getHeaders();
      final response = await _client
          .post(
            url,
            headers: headers,
            body: json.encode(payload),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 401) {
        Log.warning('HTTP 401 Unauthorized pada resolveAction.');
        await logout();
        throw Exception('Sesi habis. Silakan login kembali.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Log.info('Resolve action berhasil dikirim untuk device $deviceId');
        return true;
      } else {
        Log.warning('Gagal resolve action. Status: ${response.statusCode}');
        return false;
      }
    } on SocketException catch (e, stackTrace) {
      Log.error('Koneksi terputus saat resolveAction', e, stackTrace);
      throw Exception('Koneksi terputus. Periksa jaringan internet Anda.');
    } on TimeoutException catch (e, stackTrace) {
      Log.error('Timeout saat resolveAction', e, stackTrace);
      throw Exception('Koneksi terputus. Periksa jaringan internet Anda.');
    } catch (e, stackTrace) {
      Log.error('Unhandled exception saat resolveAction', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> resolveDeviceIssue(String deviceId, [String? actionText]) async {
    final text = actionText ?? 'Pemulihan status alat ke Normal oleh petugas.';
    return resolveAction(deviceId, text);
  }

  Future<bool> postActionLog(String deviceId, String action) async {
    return resolveAction(deviceId, action);
  }
}
