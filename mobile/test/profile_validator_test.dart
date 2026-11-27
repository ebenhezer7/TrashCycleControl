import 'package:flutter_test/flutter_test.dart';
import 'package:trashcycle_control/features/profile/domain/profile_validator.dart';

void main() {
  group('ProfileValidator Unit Tests', () {
    test('Validasi Nama', () {
      expect(ProfileValidator.validateName(''), 'Nama tidak boleh kosong');
      expect(ProfileValidator.validateName('   '), 'Nama tidak boleh kosong');
      expect(ProfileValidator.validateName('Ab'), 'Nama minimal 3 karakter');
      expect(ProfileValidator.validateName('Rudi Hermawan'), isNull);
    });

    test('Validasi Email', () {
      expect(ProfileValidator.validateEmail(''), 'Email tidak boleh kosong');
      expect(ProfileValidator.validateEmail('invalid_email'), 'Format email tidak valid');
      expect(ProfileValidator.validateEmail('rudi@trashcycle'), 'Format email tidak valid');
      expect(ProfileValidator.validateEmail('rudi.hermawan@trashcycle.com'), isNull);
    });

    test('Validasi Nomor Telepon', () {
      expect(ProfileValidator.validatePhone(''), 'Nomor telepon tidak boleh kosong');
      expect(ProfileValidator.validatePhone('12345'), 'Nomor telepon harus berisi 10 - 15 digit angka');
      expect(ProfileValidator.validatePhone('abcdefghij'), 'Nomor telepon harus berisi 10 - 15 digit angka');
      expect(ProfileValidator.validatePhone('081234567890'), isNull);
    });
  });
}
