import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'notes_view.dart';
import 'notification_view.dart';
import 'scanner_view.dart';
import 'settings_view.dart';

/// Navigation Utama menggunakan BottomNavigationBar dengan Tema SCADA Dark-Mode.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  // Index aktif di IndexedStack (0: Dashboard, 1: Notes, 2: Notification, 3: Settings)
  int _currentIndex = 0;

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaNavBg = Color(0xFF161B22);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  // Daftar Halaman yang Disimpan State-nya Menggunakan IndexedStack
  final List<Widget> _pages = const [
    DashboardView(),        // Index 0 di IndexedStack
    NotesView(),            // Index 1 di IndexedStack
    NotificationView(),     // Index 2 di IndexedStack
    SettingsView(),         // Index 3 di IndexedStack (Halaman Pengaturan)
  ];

  /// Menangani Aksi Tekan pada Item BottomNavigationBar
  Future<void> _onItemTapped(int index) async {
    // Indeks 1 pada BottomNavigationBar adalah QR Scan
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
      return; // Tetap di tab aktif saat ini tanpa mengubah _currentIndex
    }

    // Pemetaan indeks dari BottomBar ke IndexedStack (karena QR Scan di-bypass)
    int targetIndex = index;
    if (index > 1) {
      targetIndex = index - 1;
    }

    setState(() {
      _currentIndex = targetIndex;
    });
  }

  /// Memetakan _currentIndex di IndexedStack kembali ke posisi BottomNavigationBar
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
