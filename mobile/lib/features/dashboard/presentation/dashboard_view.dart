import 'package:flutter/material.dart';
import '../../../core/constants/scada_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/presentation/login_view.dart';
import '../data/models/device_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  late Future<List<DeviceModel>> _devicesFuture;

  DateTime _lastUpdated = DateTime.now();
  String _selectedFilter = 'Semua'; // Small Feature: Filter Status Mesin ('Semua', 'Normal', 'Peringatan')

  final Set<String> _notifiedDeviceAlerts = {};
  final Set<String> _resolvingDeviceIds = {};

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _refreshDevices();
  }

  void _refreshDevices() {
    setState(() {
      _lastUpdated = DateTime.now();
      _devicesFuture = _apiService.fetchDevices();
    });
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

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

  // Bug Fix: Double-submit prevention pada aksi Resolve
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

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    Color activeColor = scadaNormal;
    if (label == 'Peringatan') {
      activeColor = scadaAlert;
    }

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: activeColor.withAlpha(45),
      backgroundColor: scadaAppBarBg,
      side: BorderSide(
        color: isSelected ? activeColor : const Color(0xFF2C3444),
        width: isSelected ? 1.5 : 1.0,
      ),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? activeColor : scadaTextPrimary,
      ),
      visualDensity: VisualDensity.compact,
    );
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

            // Small Feature: Logika Filter Mesin (Semua, Normal, Peringatan)
            List<DeviceModel> filteredDevices = devices;
            if (_selectedFilter == 'Normal') {
              filteredDevices = devices.where((d) => !d.hasAlert).toList();
            } else if (_selectedFilter == 'Peringatan') {
              filteredDevices = devices.where((d) => d.hasAlert).toList();
            }

            final normalCount = devices.where((d) => !d.hasAlert).length;
            final alertCount = devices.where((d) => d.hasAlert).length;

            return Column(
              children: [
                // Header Bar Timestamp Update Terakhir
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

                // Small Feature: Baris Filter Status Mesin SCADA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  color: scadaAppBarBg.withAlpha(80),
                  child: Row(
                    children: [
                      const Text(
                        'Filter Status: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B98A9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('Semua', devices.length),
                      const SizedBox(width: 6),
                      _buildFilterChip('Normal', normalCount),
                      const SizedBox(width: 6),
                      _buildFilterChip('Peringatan', alertCount),
                    ],
                  ),
                ),

                Expanded(
                  child: filteredDevices.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada mesin dengan status "$_selectedFilter"',
                            style: const TextStyle(color: Color(0xFF8B98A9), fontSize: 14),
                          ),
                        )
                      : LayoutBuilder(
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
                                itemCount: filteredDevices.length,
                                itemBuilder: (context, index) {
                                  final device = filteredDevices[index];
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
                              itemCount: filteredDevices.length,
                              itemBuilder: (context, index) {
                                final device = filteredDevices[index];
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

  static const Color scadaCardBg = ScadaColors.scadaCardBg;
  static const Color scadaHeaderBg = ScadaColors.scadaHeaderBg;
  static const Color scadaBorder = ScadaColors.scadaBorder;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

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
                        // Bug Fix: Double-submit prevention
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
