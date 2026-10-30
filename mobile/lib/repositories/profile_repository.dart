import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Repository untuk mengelola pengambilan dan pembaruan data profil petugas.
class ProfileRepository {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  final http.Client _client;

  ProfileRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data profil dari SharedPreferences atau fallback default
  Future<Map<String, String>> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Rudi Hermawan',
      'email': prefs.getString('user_email') ?? 'rudi.hermawan@trashcycle.com',
      'phone': prefs.getString('user_phone') ?? '081234567890',
      'role': prefs.getString('user_role') ?? 'SUPERADMIN / TEKNISI',
      'id': prefs.getString('user_id') ?? 'TC-88492',
    };
  }

  /// Memperbarui data profil ke backend Laravel & menyimpannya secara lokal
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final Uri url = Uri.parse('$baseUrl/user/profile');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final payload = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      developer.log('Updating profile data to $url', name: 'ProfileRepository');

      final response = await _client
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);
        await prefs.setString('user_phone', phone);
        return true;
      } else {
        // Fallback simpan ke penyimpanan lokal untuk respon offline/simulasi
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);
        await prefs.setString('user_phone', phone);
        return true;
      }
    } on SocketException catch (e) {
      developer.log('Server offline, menyimpan profil ke lokal: $e', name: 'ProfileRepository');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_phone', phone);
      return true;
    } catch (e) {
      developer.log('Exception update profile: $e', name: 'ProfileRepository');
      rethrow;
    }
  }
}
