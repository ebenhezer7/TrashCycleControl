import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/scada_colors.dart';
import '../data/profile_repository.dart';
import '../domain/profile_validator.dart';

/// Form UI Profil Petugas Lapangan.
/// Bebas dari aturan validasi mentah dan logika HTTP API (SoC).
class ProfileForm extends StatefulWidget {
  final Map<String, String> initialData;
  final VoidCallback? onSuccess;

  const ProfileForm({
    super.key,
    required this.initialData,
    this.onSuccess,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final ProfileRepository _repository = ProfileRepository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSaving = false;

  static const Color scadaBorder = ScadaColors.scadaBorder;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
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
        widget.onSuccess?.call();
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: scadaTextPrimary),
            decoration: _buildInputDecoration('Nama Lengkap', Icons.person_outline),
            validator: ProfileValidator.validateName,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: scadaTextPrimary),
            decoration: _buildInputDecoration('Email Terdaftar', Icons.email_outlined),
            validator: ProfileValidator.validateEmail,
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSubmit,
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
