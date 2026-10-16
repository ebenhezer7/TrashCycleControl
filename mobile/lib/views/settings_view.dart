import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'log_activity_view.dart';
import 'login_view.dart';
import 'profile_view.dart';
import 'user_management_view.dart';

/// Halaman Pengaturan Sistem SCADA & Konfigurasi RBAC.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ApiService _apiService = ApiService();

  String _currentRole = 'superadmin';
  String _selectedLanguage = 'Bahasa Indonesia';
  bool _notificationEnabled = true;

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
    _loadSettings();
  }

  /// Memuat pengaturan dan role user tersimpan dari SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentRole = prefs.getString('user_role') ?? 'superadmin';
      _selectedLanguage = prefs.getString('app_language') ?? 'Bahasa Indonesia';
      _notificationEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  /// Mengubah role pengguna (Simulasi RBAC Real-time)
  Future<void> _changeRole(String newRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', newRole);
    setState(() {
      _currentRole = newRole;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulasi Role Diubah ke: ${newRole.toUpperCase()}'),
        backgroundColor: scadaNormal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mengubah status notifikasi
  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationEnabled = value;
    });
  }

  /// Mengubah bahasa aplikasi
  Future<void> _changeLanguage(String? lang) async {
    if (lang == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
  }

  /// Menangani proses logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: scadaCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: scadaBorder),
        ),
        title: const Text('LOGOUT AKUN', style: TextStyle(color: scadaTextPrimary)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi TrashCycleControl?',
          style: TextStyle(color: scadaTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL', style: TextStyle(color: scadaTextSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scadaAlert),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuperadmin = _currentRole.toLowerCase() == 'superadmin';

    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'PENGATURAN SISTEM',
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // CARD SIMULASI RBAC ROLE SELECTOR
          Card(
            elevation: 4,
            color: scadaCardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: scadaNormal, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined, color: scadaNormal, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Simulasi Role Akses (RBAC)',
                        style: TextStyle(
                          color: scadaNormal,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih role di bawah ini untuk menguji visibilitas menu "Kelola User" dan logika filter "Catatan Shift":',
                    style: TextStyle(fontSize: 12, color: scadaTextSecondary),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _currentRole,
                    dropdownColor: scadaCardBg,
                    style: const TextStyle(color: scadaTextPrimary, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaNormal, width: 2),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'superadmin',
                        child: Text('Superadmin (Akses Penuh + Kelola User)'),
                      ),
                      DropdownMenuItem(
                        value: 'supervisor',
                        child: Text('Supervisor (Lihat Semua Catatan)'),
                      ),
                      DropdownMenuItem(
                        value: 'operator',
                        child: Text('Operator (Hanya Catatan Pribadi)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _changeRole(val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // a. Profil
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profil Petugas',
            subtitle: 'Lihat data identitas & status akun',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
          ),

          // b. Bahasa
          Card(
            elevation: 4,
            color: scadaCardBg,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: scadaBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.language_outlined, color: scadaNormal),
              title: const Text(
                'Bahasa Aplikasi',
                style: TextStyle(color: scadaTextPrimary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                _selectedLanguage,
                style: const TextStyle(color: scadaTextSecondary, fontSize: 13),
              ),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: scadaCardBg,
                underline: const SizedBox(),
                style: const TextStyle(color: scadaNormal, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(value: 'Bahasa Indonesia', child: Text('Indonesia')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                ],
                onChanged: _changeLanguage,
              ),
            ),
          ),

          // c. Log Aktivitas
          _buildSettingsTile(
            icon: Icons.history,
            title: 'Log Aktivitas Audit',
            subtitle: 'Riwayat aksi & penggunaan sistem',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogActivityView()),
              );
            },
          ),

          // d. Notifikasi Toggle
          Card(
            elevation: 4,
            color: scadaCardBg,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: scadaBorder),
            ),
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: scadaNormal),
              title: const Text(
                'Notifikasi Peringatan',
                style: TextStyle(color: scadaTextPrimary, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text(
                'Terima notifikasi lokal saat sensor melebihi batas',
                style: TextStyle(color: scadaTextSecondary, fontSize: 13),
              ),
              activeThumbColor: scadaNormal,
              value: _notificationEnabled,
              onChanged: _toggleNotification,
            ),
          ),

          // e. Kelola User (RBAC CONDITION: HANYA TAMPIL JIKA SUPERADMIN)
          if (isSuperadmin)
            _buildSettingsTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Kelola User (Superadmin)',
              subtitle: 'Tambah, ubah & hapus akses akun petugas',
              titleColor: scadaNormal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementView()),
                );
              },
            ),

          const SizedBox(height: 12),

          // f. Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: scadaAlert,
                side: const BorderSide(color: scadaAlert, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'KELUAR AKUN (LOGOUT)',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Card(
      elevation: 4,
      color: scadaCardBg,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: scadaBorder),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: scadaNormal),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? scadaTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: scadaTextSecondary, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: scadaTextSecondary),
      ),
    );
  }
}
