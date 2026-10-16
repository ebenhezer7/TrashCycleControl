import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Halaman Pemindai Kamera QR Code Alat Daur Ulang.
class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController _controller = MobileScannerController();
  PermissionStatus _cameraPermissionStatus = PermissionStatus.denied;
  bool _isCheckingPermission = true;
  bool _isScanned = false;

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  /// Memeriksa dan meminta izin akses kamera
  Future<void> _checkPermission() async {
    setState(() => _isCheckingPermission = true);
    final status = await Permission.camera.request();
    setState(() {
      _cameraPermissionStatus = status;
      _isCheckingPermission = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'SCANNER QR ALAT',
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
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: scadaNormal,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. State Loading saat Cek Izin Kamera
    if (_isCheckingPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: scadaNormal),
            SizedBox(height: 16),
            Text(
              'Memeriksa izin kamera...',
              style: TextStyle(color: scadaTextPrimary),
            ),
          ],
        ),
      );
    }

    // 2. State Error jika Izin Kamera Ditolak / Denied
    if (!_cameraPermissionStatus.isGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: scadaAlert),
              const SizedBox(height: 16),
              const Text(
                'IZIN KAMERA DITOLAK',
                style: TextStyle(
                  color: scadaTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi membutuhkan akses kamera untuk memindai QR Code pada alat daur ulang.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scadaTextSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scadaNormal,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.security),
                label: const Text('MINTA IZIN KAMERA'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, null), // Pembatalan sepihak
                child: const Text('BATALKAN', style: TextStyle(color: scadaTextSecondary)),
              ),
            ],
          ),
        ),
      );
    }

    // 3. State Berhasil (Render Live Scanner Kamera)
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_isScanned) return;
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                setState(() => _isScanned = true);
                final code = barcode.rawValue!;
                Navigator.pop(context, code); // Kembalikan data QR code hasil scan ke Dashboard
                break;
              }
            }
          },
        ),

        // Custom Scanner Overlay Box
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: scadaNormal, width: 3),
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
            ),
          ),
        ),

        // Petunjuk untuk Petugas
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: scadaAppBarBg.withAlpha(220),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scadaNormal.withAlpha(100)),
            ),
            child: const Text(
              'Arahkan kamera ke QR Code yang tertera pada alat daur ulang',
              textAlign: TextAlign.center,
              style: TextStyle(color: scadaTextPrimary, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
