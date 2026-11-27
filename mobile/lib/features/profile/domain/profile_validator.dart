/// Pure Dart Validator class untuk menangani aturan validasi data Profil Petugas.
class ProfileValidator {
  /// Validasi Nama Lengkap: Tidak boleh kosong dan minimal 3 karakter
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  /// Validasi Email: Tidak boleh kosong dan harus berformat email yang valid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi Nomor Telepon: Tidak boleh kosong dan minimal 10-15 digit angka
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final phoneRegex = RegExp(r'^[0-9+]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Nomor telepon harus berisi 10 - 15 digit angka';
    }
    return null;
  }
}
