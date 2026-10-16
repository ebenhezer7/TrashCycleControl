import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashcycle_control/models/device_model.dart';
import 'package:trashcycle_control/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiService Unit Tests', () {
    // 1. Test Model Valid
    test('Model Valid', () {
      final json = {
        'id': '1',
        'name': 'Low-Smoke Incinerator',
        'type': 'Incinerator',
        'current_temperature': 450.0,
        'current_humidity': 15.0,
        'current_pressure': 0.1,
        'alert_status': 'Normal',
      };

      final device = DeviceModel.fromJson(json);

      expect(device.id, '1');
      expect(device.name, 'Low-Smoke Incinerator');
      expect(device.type, 'Incinerator');
      expect(device.currentTemperature, 450.0);
      expect(device.currentHumidity, 15.0);
      expect(device.currentPressure, 0.1);
      expect(device.alertStatus, 'Normal');
      expect(device.hasAlert, false);
    });

    // 2. Test Model Invalid
    test('Model Invalid', () {
      final jsonMissingId = {
        'name': 'Smart Composter',
        'type': 'Composter',
      };

      expect(
        () => DeviceModel.fromJson(jsonMissingId),
        throwsA(isA<FormatException>()),
      );
    });

    // 3. Test API Sukses
    test('API Sukses', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {
              'id': '1',
              'name': 'Low-Smoke Incinerator',
              'type': 'Incinerator',
              'current_temperature': 450.0,
              'current_humidity': 15.0,
              'current_pressure': 0.1,
              'alert_status': 'Normal',
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final devices = await apiService.fetchDevices();

      expect(devices, isA<List<DeviceModel>>());
      expect(devices.length, 1);
      expect(devices.first.id, '1');
      expect(devices.first.name, 'Low-Smoke Incinerator');
    });

    // 4. Test Data Kosong
    test('Data Kosong', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiService(client: mockClient);
      final devices = await apiService.fetchDevices();

      expect(devices, isEmpty);
    });

    // 5. Test HTTP Gagal
    test('HTTP Gagal', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: mockClient);

      expect(
        () => apiService.fetchDevices(),
        throwsA(isA<HttpException>()),
      );
    });

    // 6. Test JSON Rusak
    test('JSON Rusak', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{ invalid_json_format ...', 200);
      });

      final apiService = ApiService(client: mockClient);

      expect(
        () => apiService.fetchDevices(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
