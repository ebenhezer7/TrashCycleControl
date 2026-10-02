import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/api_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _apiService = ApiService();
  late Future<List<DeviceModel>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
  }

  /// Memuat ulang data dari ApiService
  void _refreshDevices() {
    setState(() {
      _devicesFuture = _apiService.fetchDevices();
    });
  }

  /// Mengirimkan log tindakan perbaikan ke backend lalu me-refresh data
  Future<void> _handleResolve(DeviceModel device) async {
    final actionText = 'Tindakan perbaikan otomatis untuk status [${device.alertStatus}] diselesaikan oleh petugas.';

    // 1. Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 2. Panggil API Service resolveAction
    final success = await _apiService.resolveAction(device.id, actionText);

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perbaikan untuk ${device.name} berhasil ditandai selesai!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // 3. Trigger refresh ulang dari backend agar status alert terbarui
      _refreshDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim tindakan perbaikan ke server. Silakan coba lagi.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Monitoring'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _refreshDevices,
          ),
        ],
      ),
      body: RefreshIndicator(
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
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data alat daur ulang...'),
                  ],
                ),
              );
            }

            // 2. State Error / Gagal Koneksi
            if (snapshot.hasError) {
              final errorMessage = snapshot.error.toString().replaceAll('Exception: ', '');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal Mengambil Data',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.outline),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshDevices,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
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
                    const Icon(Icons.devices_other, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada alat terdaftar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _refreshDevices,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    )
                  ],
                ),
              );
            }

            // 4. State Berhasil (Render List Card Alat)
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return DeviceCard(
                  device: device,
                  onResolve: () => _handleResolve(device),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onResolve;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAlert = device.hasAlert;

    return Card(
      elevation: isAlert ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAlert ? colorScheme.error : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAlert
                  ? colorScheme.errorContainer
                  : colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getToolIcon(device.type),
                      color: isAlert ? colorScheme.error : colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isAlert ? colorScheme.onErrorContainer : null,
                          ),
                        ),
                        Text(
                          'Tipe: ${device.type}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAlert
                                ? colorScheme.onErrorContainer.withOpacity(0.8)
                                : colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isAlert)
                  Chip(
                    avatar: Icon(Icons.warning_amber_rounded, size: 16, color: colorScheme.onError),
                    label: Text(
                      device.alertStatus,
                      style: TextStyle(color: colorScheme.onError, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: colorScheme.error,
                  )
                else
                  Chip(
                    avatar: const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    label: const Text(
                      'Normal',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
              ],
            ),
          ),

          // Parameter Sensor List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSensorRow(
                  context,
                  label: 'Suhu',
                  value: '${device.currentTemperature.toStringAsFixed(1)} °C',
                  icon: Icons.thermostat,
                  color: device.currentTemperature > 80 ? colorScheme.error : colorScheme.primary,
                ),
                const Divider(),
                _buildSensorRow(
                  context,
                  label: 'Kelembapan',
                  value: '${device.currentHumidity.toStringAsFixed(1)} %',
                  icon: Icons.water_drop,
                  color: device.currentHumidity < 35 ? colorScheme.error : colorScheme.primary,
                ),
                const Divider(),
                _buildSensorRow(
                  context,
                  label: 'Tekanan',
                  value: '${device.currentPressure.toStringAsFixed(2)} bar',
                  icon: Icons.speed,
                  color: device.currentPressure > 0.5 ? colorScheme.error : colorScheme.primary,
                ),
              ],
            ),
          ),

          // Banner Rekomendasi & Tombol Resolve jika sedang Alert
          if (isAlert) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rekomendasi: Periksa parameter alat dan lalukan pemulihan.',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onResolve,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Tandai Selesai (Resolve)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensorRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 15)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
