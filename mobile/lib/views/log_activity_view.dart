import 'package:flutter/material.dart';

/// Halaman Log Aktivitas Pengguna / System Audit Trail.
class LogActivityView extends StatelessWidget {
  const LogActivityView({super.key});

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaCardBg = Color(0xFF1A1F29);
  static const Color scadaBorder = Color(0xFF2C3444);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'action': 'Mengubah status Low-Smoke Incinerator menjadi Normal',
        'details': 'Tindakan perbaikan manual setelah alarm suhu aktif.',
        'timestamp': 'Hari Ini, 10:15 WIB',
        'icon': Icons.check_circle_outline,
      },
      {
        'action': 'Melakukan pemindaian QR Code Alat SCADA-02',
        'details': 'Scanner kamera terhubung ke Smart Composter Bin.',
        'timestamp': 'Hari Ini, 09:40 WIB',
        'icon': Icons.qr_code_scanner,
      },
      {
        'action': 'Menambahkan Catatan Shift Baru',
        'details': 'Menyimpan log: "Inspeksi mingguan katup tekanan pirolisis".',
        'timestamp': 'Hari Ini, 08:00 WIB',
        'icon': Icons.edit_document,
      },
      {
        'action': 'Login ke Sistem SCADA TrashCycleControl',
        'details': 'Otentikasi berhasil via token lokal.',
        'timestamp': 'Kemarin, 19:30 WIB',
        'icon': Icons.login,
      },
    ];

    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'LOG AKTIVITAS',
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
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final item = activities[index];
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scadaNormal.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: scadaNormal, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['action'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: scadaTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['details'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: scadaTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: scadaTextSecondary),
                            const SizedBox(width: 4),
                            Text(
                              item['timestamp'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: scadaTextSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
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
