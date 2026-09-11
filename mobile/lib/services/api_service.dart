import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/recycling_tool.dart';

class ApiService {
  // Ganti dengan URL backend Laravel Anda (misal: http://10.0.2.2:8000 untuk emulator Android)
  static const String baseUrl = 'http://your-laravel-api.com/api';

  /// 1. Mengambil data real-time status sensor
  Future<List<RecyclingTool>> fetchDevicesStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RecyclingTool.fromJson(json)).toList();
      } else {
        log('Error Fetching Devices: ${response.statusCode}');
        throw Exception('Gagal memuat data perangkat dari server.');
      }
    } catch (e) {
      log('Exception API fetchDevicesStatus: $e');
      rethrow;
    }
  }

  /// 2. Mengirim data log tindakan penyelesaian
  /// [deviceId]: ID alat yang bermasalah
  /// [action]: Deskripsi tindakan yang dilakukan (contoh: "Pompa dinyalakan")
  Future<bool> postActionLog(String deviceId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/actions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': deviceId,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Action log sent successfully');
        return true;
      } else {
        log('Error Sending Action Log: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Exception API postActionLog: $e');
      return false;
    }
  }
}
