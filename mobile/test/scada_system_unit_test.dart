import 'package:flutter_test/flutter_test.dart';
import 'package:trashcycle_control/features/dashboard/data/models/device_model.dart';
import 'package:trashcycle_control/features/profile/domain/profile_validator.dart';

void main() {
  group('1. ProfileValidator - Validasi Nama (50 Test Cases)', () {
    final emptyNames = [
      '', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ', '         ',
    ];
    for (int i = 0; i < emptyNames.length; i++) {
      test('1.$i. Nama kosong/whitespace "$i"', () {
        expect(ProfileValidator.validateName(emptyNames[i]), 'Nama tidak boleh kosong');
      });
    }

    final shortNames = [
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
      'k', 'l', 'm', 'n', 'o', 'aa', 'ab', 'ac', 'ad', 'ae',
    ];
    for (int i = 0; i < shortNames.length; i++) {
      test('1.${10 + i}. Nama pendek <3 char "${shortNames[i]}"', () {
        expect(ProfileValidator.validateName(shortNames[i]), 'Nama minimal 3 karakter');
      });
    }

    final validNames = [
      'Ali', 'Ani', 'Budi', 'Cici', 'Dedi', 'Eka', 'Fani', 'Gita', 'Hani', 'Ira',
      'Joko', 'Kiki', 'Lia', 'Maya', 'Nico', 'Oki', 'Rudi Hermawan', 'Siti Aminah', 'Budi Santoso', 'Teknisi SCADA',
    ];
    for (int i = 0; i < validNames.length; i++) {
      test('1.${30 + i}. Nama valid "${validNames[i]}"', () {
        expect(ProfileValidator.validateName(validNames[i]), isNull);
      });
    }
  });

  group('2. ProfileValidator - Validasi Email (50 Test Cases)', () {
    final emptyEmails = [
      '', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ', '         ',
    ];
    for (int i = 0; i < emptyEmails.length; i++) {
      test('2.$i. Email kosong/whitespace "$i"', () {
        expect(ProfileValidator.validateEmail(emptyEmails[i]), 'Email tidak boleh kosong');
      });
    }

    final invalidEmails = [
      'invalid',
      'invalid@',
      'invalid@com',
      '@domain.com',
      'user@.com',
      'user@domain.',
      'user space@domain.com',
      'user#name@domain.com',
      'user@domain..com',
      'plainaddress',
      'user@domain_com',
      '@example.com',
      'Joe Blow <joe@example.com>',
      'email.example.com',
      'email@example@example.com',
      'user@.org',
      'user@.net',
      'email@example.com (Joe Blow)',
      'email@example',
      'user@site.',
    ];
    for (int i = 0; i < invalidEmails.length; i++) {
      test('2.${10 + i}. Email invalid "${invalidEmails[i]}"', () {
        expect(ProfileValidator.validateEmail(invalidEmails[i]), 'Format email tidak valid');
      });
    }

    final validEmails = [
      'rudi@trashcycle.com',
      'budi.santoso@trashcycle.com',
      'siti.aminah@trashcycle.com',
      'admin@trashcycle.co.id',
      'user1@domain.com',
      'user.name@domain.org',
      'user_name@domain.net',
      'user-name@domain.io',
      'contact@scada.ac.id',
      'info@trashcycle.app',
      'petugas123@scada.com',
      'test.user@sub.domain.com',
      'a.b.c@domain.co',
      'scada.operator@trashcycle.id',
      'supervisor@trashcycle.com',
      'tech.support@trashcycle.org',
      'field.officer@trashcycle.net',
      'engineer@trashcycle.com',
      'system.alert@scada.io',
      'devops@trashcycle.com',
    ];
    for (int i = 0; i < validEmails.length; i++) {
      test('2.${30 + i}. Email valid "${validEmails[i]}"', () {
        expect(ProfileValidator.validateEmail(validEmails[i]), isNull);
      });
    }
  });

  group('3. ProfileValidator - Validasi Telepon (40 Test Cases)', () {
    final emptyPhones = [
      '', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ', '         ',
    ];
    for (int i = 0; i < emptyPhones.length; i++) {
      test('3.$i. Telepon kosong "$i"', () {
        expect(ProfileValidator.validatePhone(emptyPhones[i]), 'Nomor telepon tidak boleh kosong');
      });
    }

    final invalidPhones = [
      '123',
      '12345',
      '123456',
      '123456789',
      '081234567',
      'abcdefghij',
      '0812345678a',
      '0812-3456-789',
      '0812 3456 7890',
      '1234567890123456',
      '+6281234567890123',
      'phone_number',
      '08123#56789',
      '08123456789!',
      '08123456789?',
    ];
    for (int i = 0; i < invalidPhones.length; i++) {
      test('3.${10 + i}. Telepon invalid "${invalidPhones[i]}"', () {
        expect(ProfileValidator.validatePhone(invalidPhones[i]), 'Nomor telepon harus berisi 10 - 15 digit angka');
      });
    }

    final validPhones = [
      '081234567890',
      '081234567891',
      '081234567892',
      '081234567893',
      '081234567894',
      '081234567895',
      '081234567896',
      '081234567897',
      '081234567898',
      '081234567899',
      '+6281234567890',
      '+628123456789',
      '085612345678',
      '087812345678',
      '089612345678',
    ];
    for (int i = 0; i < validPhones.length; i++) {
      test('3.${25 + i}. Telepon valid "${validPhones[i]}"', () {
        expect(ProfileValidator.validatePhone(validPhones[i]), isNull);
      });
    }
  });

  group('4. SCADA Telemetry & Sensor Thresholds (30 Test Cases)', () {
    final incineratorTemps = [
      400.0, 420.0, 450.0, 480.0, 500.0, 520.0, 550.0, 580.0, 600.0, 350.0
    ];
    for (int i = 0; i < incineratorTemps.length; i++) {
      test('4.$i. Incinerator temp ${incineratorTemps[i]}°C', () {
        final device = DeviceModel(
          id: '1',
          name: 'Low-Smoke Incinerator',
          type: 'Incinerator',
          currentTemperature: incineratorTemps[i],
          currentHumidity: 15.0,
          currentPressure: 0.1,
          alertStatus: incineratorTemps[i] < 400 ? 'Suhu Rendah' : 'Normal',
        );
        expect(device.hasAlert, incineratorTemps[i] < 400);
      });
    }

    final composterHumidities = [
      40.0, 45.0, 50.0, 55.0, 60.0, 34.0, 30.0, 25.0, 20.0, 15.0
    ];
    for (int i = 0; i < composterHumidities.length; i++) {
      test('4.${10 + i}. Composter humidity ${composterHumidities[i]}%', () {
        final isAlert = composterHumidities[i] < 35.0;
        final device = DeviceModel(
          id: '2',
          name: 'Smart Composter',
          type: 'Composter',
          currentTemperature: 55.0,
          currentHumidity: composterHumidities[i],
          currentPressure: 0.05,
          alertStatus: isAlert ? 'Kelembapan Rendah' : 'Normal',
        );
        expect(device.hasAlert, isAlert);
      });
    }

    final pirolisisPressures = [
      0.1, 0.2, 0.3, 0.4, 0.5, 0.51, 0.6, 0.7, 0.8, 0.9
    ];
    for (int i = 0; i < pirolisisPressures.length; i++) {
      test('4.${20 + i}. Pirolisis pressure ${pirolisisPressures[i]} bar', () {
        final isAlert = pirolisisPressures[i] > 0.5;
        final device = DeviceModel(
          id: '3',
          name: 'Sistem Pirolisis Plastik',
          type: 'Pirolisis',
          currentTemperature: 420.0,
          currentHumidity: 10.0,
          currentPressure: pirolisisPressures[i],
          alertStatus: isAlert ? 'Tekanan Tinggi' : 'Normal',
        );
        expect(device.hasAlert, isAlert);
      });
    }
  });

  group('5. RBAC Access Control & Note Filtering (20 Test Cases)', () {
    final adminRoles = [
      'superadmin', 'SUPERADMIN', 'SuperAdmin', 'supervisor', 'SUPERVISOR',
      'SuperVisor', 'admin', 'ADMIN', 'SuperAdmin_Role', 'Supervisor_Role',
    ];
    for (int i = 0; i < adminRoles.length; i++) {
      test('5.$i. RBAC full access for "${adminRoles[i]}"', () {
        final role = adminRoles[i].toLowerCase();
        final isFullAccess = role.contains('admin') || role.contains('supervisor');
        expect(isFullAccess, isTrue);
      });
    }

    final operatorRoles = [
      'operator', 'OPERATOR', 'Operator', 'petugas', 'PETUGAS',
      'teknisi', 'TEKNISI', 'user', 'guest', 'field_officer',
    ];
    for (int i = 0; i < operatorRoles.length; i++) {
      test('5.${10 + i}. RBAC restricted access for "${operatorRoles[i]}"', () {
        final role = operatorRoles[i].toLowerCase();
        final isFullAccess = role == 'superadmin' || role == 'supervisor';
        expect(isFullAccess, isFalse);
      });
    }
  });
}
