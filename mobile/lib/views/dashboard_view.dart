import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'login_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  late Future<List<DeviceModel>> _devicesFuture;

  // State untuk menyimpan waktu update terakhir (Micro-Feature 1)
  DateTime _lastUpdated = DateTime.now();

  // Tracker untuk mencegah spam notifikasi berulang untuk anomali alat yang sama
  final Set<String> _notifiedDeviceAlerts = {};

  // Tracker untuk loading state aksi resolve per device
  final Set<String> _resolvingDeviceIds = {};

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _refreshDevices();
  }

  /// Memuat ulang data dari ApiService & memperbarui timestamp _lastUpdated
  void _refreshDevices() {
    setState(() {
      _lastUpdated = DateTime.now();
      _devicesFuture = _apiService.fetchDevices();
    });
  }

  /// Format timestamp sederhana HH:mm:ss
  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Memeriksa telemetry alat dari API secara otomatis dan memicu notifikasi peringatan di system tray
  void _checkAndTriggerDeviceAlertNotifications(List<DeviceModel> devices) {
    for (final device in devices) {
      if (device.hasAlert) {
        final alertKey = '${device.id}_${device.alertStatus}';
        if (!_notifiedDeviceAlerts.contains(alertKey)) {
          _notifiedDeviceAlerts.add(alertKey);

          _notificationService.showWarningNotification(
            '🚨 Peringatan SCADA: ${device.name}',
            'Anomali [${device.alertStatus}] terdeteksi! Suhu: ${device.currentTemperature}°C, Kelembapan: ${device.currentHumidity}%, Tekanan: ${device.currentPressure} bar.',
          );
        }
      } else {
        _notifiedDeviceAlerts.removeWhere((key) => key.startsWith('${device.id}_'));
      }
    }
  }

  /// Feedback Aksi Async dengan Tangkapan UI Exception (Sesi Habis & Koneksi Terputus)
  Future<void> _handleResolve(DeviceModel device) async {
    if (_resolvingDeviceIds.contains(device.id)) return;

    setState(() {
      _resolvingDeviceIds.add(device.id);
    });

    try {
      final success = await _apiService.resolveDeviceIssue(device.id);

      if (!mounted) return;

      setState(() {
        _resolvingDeviceIds.remove(device.id);
      });

      final messenger = ScaffoldMessenger.of(context);
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Perbaikan untuk ${device.name} berhasil ditandai selesai!'),
            backgroundColor: scadaNormal,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refreshDevices();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim tindakan perbaikan ke server. Silakan coba lagi.'),
            backgroundColor: scadaAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _resolvingDeviceIds.remove(device.id);
      });

      final errorStr = e.toString();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      if (errorStr.contains('Sesi habis')) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Sesi habis. Silakan login kembali.'),
            backgroundColor: scadaAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      } else if (errorStr.contains('Koneksi terputus')) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Koneksi terputus. Periksa jaringan internet Anda.'),
            backgroundColor: scadaAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${errorStr.replaceAll("Exception: ", "")}'),
            backgroundColor: scadaAlert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'DASHBOARD MONITORING',
          style: TextStyle(
            color: scadaTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: scadaAppBarBg,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: scadaNormal),
            tooltip: 'Refresh Data Telemetry SCADA',
            onPressed: _refreshDevices,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: scadaNormal,
        backgroundColor: scadaAppBarBg,
        onRefresh: () async => _refreshDevices(),
        child: FutureBuilder<List<DeviceModel>>(
          future: _devicesFuture,
          builder: (context, snapshot) {
            // 1. State Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: scadaNormal),
                    SizedBox(height: 16),
                    Text(
                      'Memuat telemetry sistem SCADA...',
                      style: TextStyle(color: scadaTextPrimary),
                    ),
                  ],
                ),
              );
            }

            // 2. State Error / Gagal Koneksi / Sesi Habis
            if (snapshot.hasError) {
              final errorMessage = snapshot.error.toString().replaceAll('Exception: ', '');

              if (errorMessage.contains('Sesi habis')) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesi habis. Silakan login kembali.'),
                      backgroundColor: scadaAlert,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                });
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: scadaAlert,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage.contains('Koneksi terputus')
                            ? 'KONEKSI TERPUTUS'
                            : 'KONEKSI TELEMETRY GAGAL',
                        style: const TextStyle(
                          color: scadaTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF8B98A9)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshDevices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scadaNormal,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('COBA LAGI'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 3. State Data Kosong
            final devices = snapshot.data ?? [];
            if (devices.isEmpty) {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    const Icon(Icons.devices_other, size: 64, color: Color(0xFF8B98A9)),
                    const SizedBox(height: 16),
                    const Text(
                      'Data kosong',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF8B98A9)),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _refreshDevices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scadaNormal,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('REFRESH'),
                      ),
                    )
                  ],
                ),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndTriggerDeviceAlertNotifications(devices);
            });

            return Column(
              children: [
                // Micro-Feature 1: Header Bar dengan Timestamp Update Terakhir
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: scadaAppBarBg.withAlpha(120),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF8B98A9)),
                          const SizedBox(width: 6),
                          Text(
                            'Update Terakhir: ${_formatTimestamp(_lastUpdated)} WIB',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B98A9),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${devices.length} Alat Terkoneksi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: scadaNormal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.15,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            final device = devices[index];
                            return DeviceCard(
                              device: device,
                              isResolving: _resolvingDeviceIds.contains(device.id),
                              onResolve: () => _handleResolve(device),
                            );
                          },
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return DeviceCard(
                            device: device,
                            isResolving: _resolvingDeviceIds.contains(device.id),
                            onResolve: () => _handleResolve(device),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isResolving;
  final VoidCallback onResolve;

  static const Color scadaCardBg = Color(0xFF1A1F29);
  static const Color scadaHeaderBg = Color(0xFF222836);
  static const Color scadaBorder = Color(0xFF2C3444);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  const DeviceCard({
    super.key,
    required this.device,
    required this.isResolving,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final isAlert = device.hasAlert;

    return Semantics(
      label: 'Perangkat Daur Ulang ${device.name}, Status ${device.alertStatus}. Suhu ${device.currentTemperature.toStringAsFixed(1)} derajat Celsius, Kelembapan ${device.currentHumidity.toStringAsFixed(1)} persen, Tekanan ${device.currentPressure.toStringAsFixed(2)} bar.',
      child: Card(
        elevation: 4,
        color: scadaCardBg,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isAlert ? scadaAlert : scadaBorder,
            width: isAlert ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isAlert ? scadaAlert.withAlpha(38) : scadaHeaderBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getToolIcon(device.type),
                    color: isAlert ? scadaAlert : scadaNormal,
                    size: 26,
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isAlert ? scadaAlert : scadaTextPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tipe: ${device.type}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: scadaTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  if (isAlert)
                    Semantics(
                      label: 'Peringatan ${device.alertStatus}',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scadaAlert,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              device.alertStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Semantics(
                      label: 'Status Normal',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scadaNormal.withAlpha(38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scadaNormal.withAlpha(102)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 14, color: scadaNormal),
                            SizedBox(width: 4),
                            Text(
                              'NORMAL',
                              style: TextStyle(
                                color: scadaNormal,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Parameter Telemetry Data
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSensorRow(
                    label: 'Suhu',
                    value: '${device.currentTemperature.toStringAsFixed(1)} °C',
                    icon: Icons.thermostat,
                    color: device.currentTemperature > 80 ? scadaAlert : scadaNormal,
                  ),
                  const Divider(color: scadaBorder, height: 16),
                  _buildSensorRow(
                    label: 'Kelembapan',
                    value: '${device.currentHumidity.toStringAsFixed(1)} %',
                    icon: Icons.water_drop,
                    color: device.currentHumidity < 35 ? scadaAlert : scadaNormal,
                  ),
                  const Divider(color: scadaBorder, height: 16),
                  _buildSensorRow(
                    label: 'Tekanan',
                    value: '${device.currentPressure.toStringAsFixed(2)} bar',
                    icon: Icons.speed,
                    color: device.currentPressure > 0.5 ? scadaAlert : scadaNormal,
                  ),
                ],
              ),
            ),

            // Banner Alert & Tombol Resolve
            if (isAlert) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scadaAlert.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scadaAlert.withAlpha(102)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: scadaAlert, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Rekomendasi: Periksa parameter alat dan lakukan pemulihan.',
                            style: TextStyle(
                              color: scadaAlert,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: FilledButton.icon(
                        onPressed: isResolving ? null : onResolve,
                        icon: isResolving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: isResolving
                            ? const Text('MEMPROSES RESOLVE...', style: TextStyle(fontSize: 12))
                            : const Text(
                                'TANDAI SELESAI (RESOLVE)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: scadaAlert,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: scadaTextPrimary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  IconData _getToolIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('incinerator')) {
      return Icons.local_fire_department;
    } else if (lowerType.contains('compost')) {
      return Icons.eco;
    } else if (lowerType.contains('pirolisis') || lowerType.contains('pyrolysis')) {
      return Icons.settings_input_component;
    }
    return Icons.sensors;
  }
}
