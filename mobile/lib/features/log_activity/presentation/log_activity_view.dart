import 'package:flutter/material.dart';
import '../../../core/constants/scada_colors.dart';

/// Halaman Log Aktivitas Audit Penggunaan Aplikasi.
class LogActivityView extends StatelessWidget {
  const LogActivityView({super.key});

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaCardBg = ScadaColors.scadaCardBg;
  static const Color scadaBorder = ScadaColors.scadaBorder;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

  @override
  Widget build(BuildContext context) {
    final logs = [
      {
        'action': 'LOGIN PETUGAS',
        'details': 'Petugas Rudi Hermawan berhasil login ke portal SCADA',
        'timestamp': 'Hari Ini, 08:30:15',
        'icon': Icons.login,
      },
      {
        'action': 'RESOLVE ALERT',
        'details': 'Tindakan pemulihan status Incinerator berhasil dikirim',
        'timestamp': 'Hari Ini, 09:14:02',
        'icon': Icons.build_circle_outlined,
      },
      {
        'action': 'CATAT SHIFT',
        'details': 'Pemeriksaan rutin reaktor pirolisis berhasil dicatat',
        'timestamp': 'Hari Ini, 10:05:40',
        'icon': Icons.note_add_outlined,
      },
      {
        'action': 'SCAN QR ALAT',
        'details': 'Pemindaian QR code Smart Composter Bin TC-COM-01',
        'timestamp': 'Kemarin, 16:45:10',
        'icon': Icons.qr_code_scanner,
      },
    ];

    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'LOG AKTIVITAS AUDIT',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Card(
            elevation: 4,
            color: scadaCardBg,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: scadaBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scadaNormal.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(log['icon'] as IconData, color: scadaNormal, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['action'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: scadaNormal,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['details'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: scadaTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          log['timestamp'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: scadaTextSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
