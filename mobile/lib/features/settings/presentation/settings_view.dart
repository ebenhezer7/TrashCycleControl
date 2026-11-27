import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/scada_colors.dart';
import '../../../core/network/api_service.dart';
import '../../auth/presentation/login_view.dart';
import '../../log_activity/presentation/log_activity_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../../user_management/presentation/user_management_view.dart';

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

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaCardBg = ScadaColors.scadaCardBg;
  static const Color scadaBorder = ScadaColors.scadaBorder;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentRole = prefs.getString('user_role') ?? 'superadmin';
      _selectedLanguage = prefs.getString('app_language') ?? 'Bahasa Indonesia';
      _notificationEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

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

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationEnabled = value;
    });
  }

  Future<void> _changeLanguage(String? lang) async {
    if (lang == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
  }

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
