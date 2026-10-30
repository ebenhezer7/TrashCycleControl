import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repositories/profile_repository.dart';
import '../validators/profile_validator.dart';

/// Halaman UI Profil Petugas Lapangan.
/// Bebas dari aturan validasi langsung dan logika HTTP (SoC).
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileRepository _repository = ProfileRepository();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String _role = 'SUPERADMIN / TEKNISI';
  String _id = 'TC-88492';

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaCardBg = Color(0xFF1A1F29);
  static const Color scadaBorder = Color(0xFF2C3444);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Mengambil data profil awal dari Repository
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final data = await _repository.fetchProfile();
    setState(() {
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _role = data['role'] ?? 'SUPERADMIN / TEKNISI';
      _id = data['id'] ?? 'TC-88492';
      _isLoading = false;
    });
  }

  /// Memproses penyimpanan data profil
  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final success = await _repository.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      final messenger = ScaffoldMessenger.of(context);
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: scadaNormal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil. Silakan coba lagi.'),
            backgroundColor: scadaAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: scadaAlert,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'PROFIL PETUGAS',
          style: TextStyle(
            color: scadaTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: scadaAppBarBg,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: scadaNormal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Header Avatar
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: scadaNormal.withAlpha(30),
                              shape: BoxShape.circle,
                              border: Border.all(color: scadaNormal, width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text[0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: scadaNormal,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: scadaNormal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified, size: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scadaTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: scadaNormal.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scadaNormal.withAlpha(100)),
                      ),
                      child: Text(
                        'ROLE: ${_role.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: scadaNormal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Card Form Input Profil
                    Card(
                      elevation: 4,
                      color: scadaCardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: scadaBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Petugas: $_id',
                              style: const TextStyle(
                                fontSize: 13,
                                color: scadaNormal,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Input Nama
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: scadaTextPrimary),
                              decoration: _buildInputDecoration('Nama Lengkap', Icons.person_outline),
                              validator: ProfileValidator.validateName,
                            ),
                            const SizedBox(height: 16),

                            // Input Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: scadaTextPrimary),
                              decoration: _buildInputDecoration('Email Terdaftar', Icons.email_outlined),
                              validator: ProfileValidator.validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Micro-Feature 3: Input Formatters & Keyboard Type Khusus Angka/Telepon
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                              ],
                              style: const TextStyle(color: scadaTextPrimary),
                              decoration: _buildInputDecoration('Nomor Telepon', Icons.phone_outlined),
                              validator: ProfileValidator.validatePhone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _handleSaveProfile,
                        style: FilledButton.styleFrom(
                          backgroundColor: scadaNormal,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving ? 'MENYIMPAN...' : 'SIMPAN PERUBAHAN',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: scadaTextSecondary),
      prefixIcon: Icon(icon, color: scadaNormal),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: scadaBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: scadaNormal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: scadaAlert),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: scadaAlert, width: 2),
      ),
    );
  }
}
