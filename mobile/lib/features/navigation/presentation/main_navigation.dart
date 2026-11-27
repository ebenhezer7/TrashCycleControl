import 'package:flutter/material.dart';
import '../../../core/constants/scada_colors.dart';
import '../../dashboard/presentation/dashboard_view.dart';
import '../../notifications/presentation/notification_view.dart';
import '../../scanner/presentation/scanner_view.dart';
import '../../settings/presentation/settings_view.dart';
import '../../shift_notes/presentation/notes_view.dart';

/// Navigation Utama menggunakan BottomNavigationBar dengan Tema SCADA Dark-Mode.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaNavBg = ScadaColors.scadaAppBarBg;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

  final List<Widget> _pages = const [
    DashboardView(),
    NotesView(),
    NotificationView(),
    SettingsView(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (index == 1) {
      final scannedCode = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (context) => const ScannerView()),
      );

      if (!mounted) return;

      if (scannedCode != null && scannedCode.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code Terdeteksi: $scannedCode'),
            backgroundColor: scadaNormal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    int targetIndex = index;
    if (index > 1) {
      targetIndex = index - 1;
    }

    setState(() {
      _currentIndex = targetIndex;
    });
  }

  int _getBottomNavIndex() {
    if (_currentIndex >= 1) {
      return _currentIndex + 1;
    }
    return _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2C3444), width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _getBottomNavIndex(),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: scadaNavBg,
          selectedItemColor: scadaNormal,
          unselectedItemColor: scadaTextSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'QR Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_document),
              label: 'Catatan Shift',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
