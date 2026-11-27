import 'package:flutter/material.dart';
import '../../../core/constants/scada_colors.dart';

/// Halaman Riwayat Notifikasi Telemetry SCADA.
class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaCardBg = ScadaColors.scadaCardBg;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaWarning = ScadaColors.scadaWarning;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

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
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 72,
                    color: scadaTextSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi saat ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scadaTextSecondary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Peringatan anomali telemetry akan muncul di sini',
                    style: TextStyle(fontSize: 13, color: Color(0xFF627182)),
                  ),
                ],
              ),
            )
          : ListView.builder(
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
