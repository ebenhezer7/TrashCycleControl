import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/scada_colors.dart';

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

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

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
                onPressed: () => Navigator.pop(context, null),
                child: const Text('BATALKAN', style: TextStyle(color: scadaTextSecondary)),
              ),
            ],
          ),
        ),
      );
    }

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
                Navigator.pop(context, code);
                break;
              }
            }
          },
        ),
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
