import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';

/// Service untuk menangani komunikasi REST API dengan server backend Laravel.
class ApiService {
  // Base URL endpoint API Laravel.
  // Gunakan '10.0.2.2' jika menggunakan Emulator Android bawaan Android Studio.
  // Gunakan IP lokal PC (contoh: 'http://192.168.1.10:8000/api/v1') jika menggunakan Device Fisik.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Batas waktu tunggu HTTP Request
  static const Duration timeoutDuration = Duration(seconds: 10);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// 1. Mengambil daftar alat daur ulang beserta status sensor dan alert terbarunya.
  /// HTTP GET -> `/api/v1/devices`
  ///
  /// Mengembalikan `List<DeviceModel>`.
  Future<List<DeviceModel>> fetchDevices() async {
    final Uri url = Uri.parse('$baseUrl/devices');

    try {
      developer.log('Fetching devices from: $url', name: 'ApiService');

      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

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

  /// 2. Mengirimkan log tindakan perbaikan saat petugas lapangan menekan tombol "Tandai Selesai".
  /// HTTP POST -> `/api/v1/actions`
  ///
  /// [deviceId]: ID alat yang ditangani
  /// [actionText]: Deskripsi atau catatan tindakan perbaikan
  ///
  /// Mengembalikan `true` jika berhasil (status 200/201), atau `false` jika gagal/terjadi error.
  Future<bool> resolveAction(String deviceId, String actionText) async {
    final Uri url = Uri.parse('$baseUrl/actions');

    try {
      final Map<String, dynamic> payload = {
        'device_id': deviceId,
        'action_text': actionText,
        'timestamp': DateTime.now().toIso8601String(),
      };

      developer.log('Mengirim log tindakan ke $url: $payload', name: 'ApiService');

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
