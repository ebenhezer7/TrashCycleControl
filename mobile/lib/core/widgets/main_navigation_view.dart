import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_view.dart';
import '../../features/profile/presentation/profile_view.dart';
import '../../features/scanner/presentation/scanner_view.dart';
import '../../features/shift_notes/presentation/notes_view.dart';

/// Navigation Utama Wrapper dengan 4 Tab SCADA Dark-Mode.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaNavBg = Color(0xFF131B23);
  static const Color scadaActive = Color(0xFF00E5FF);
  static const Color scadaInactive = Color(0xFF7A8B99);

  final List<Widget> _pages = const [
    DashboardView(),
    ScannerView(),
    NotesView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: scadaNavBg,
          selectedItemColor: scadaActive,
          unselectedItemColor: scadaInactive,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Scan QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Catatan Shift',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
