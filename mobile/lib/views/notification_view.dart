import 'package:flutter/material.dart';

/// Halaman Riwayat Notifikasi Telemetry SCADA.
class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaCardBg = Color(0xFF1A1F29);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaWarning = Color(0xFFFFB300);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': '🚨 Peringatan Suhu Composter',
        'message': 'Suhu Smart Composter Bin melewati batas aman (75.0 °C). Segera nyalakan pendingin.',
        'time': '10 Menit yang lalu',
        'type': 'alert',
      },
      {
        'title': '⚠️ Tekanan Pirolisis Tinggi',
        'message': 'Tekanan reaktor pirolisis berada pada angka 0.60 bar (Batas Maksimal 0.50 bar).',
        'time': '25 Menit yang lalu',
        'type': 'warning',
      },
      {
        'title': '✅ Status Incinerator Normal',
        'message': 'Low-Smoke Incinerator beroperasi pada parameter optimal (450 °C).',
        'time': '1 Jam yang lalu',
        'type': 'normal',
      },
      {
        'title': 'ℹ️ Sinkronisasi Telemetry Berhasil',
        'message': 'Log data sensor dari 3 alat daur ulang telah berhasil disinkronkan ke server.',
        'time': '2 Jam yang lalu',
        'type': 'info',
      },
    ];

    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'RIWAYAT NOTIFIKASI',
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
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          final type = item['type'];

          Color statusColor;
          IconData statusIcon;

          if (type == 'alert') {
            statusColor = scadaAlert;
            statusIcon = Icons.error_outline;
          } else if (type == 'warning') {
            statusColor = scadaWarning;
            statusIcon = Icons.warning_amber_rounded;
          } else if (type == 'normal') {
            statusColor = scadaNormal;
            statusIcon = Icons.check_circle_outline;
          } else {
            statusColor = const Color(0xFF29B6F6);
            statusIcon = Icons.info_outline;
          }

          return Card(
            elevation: 4,
            color: scadaCardBg,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: statusColor.withAlpha(100)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: scadaTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['message']!,
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
                              item['time']!,
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
