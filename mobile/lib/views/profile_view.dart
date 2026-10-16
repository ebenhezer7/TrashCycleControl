import 'package:flutter/material.dart';

/// Halaman Profil Petugas Lapangan.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'PROFIL PETUGAS',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: scadaNormal.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: scadaNormal, width: 2.5),
                    ),
                    child: const Center(
                      child: Text(
                        'RH',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: scadaNormal,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: scadaNormal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, size: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rudi Hermawan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scadaTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: scadaNormal.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scadaNormal.withAlpha(100)),
              ),
              child: const Text(
                'ROLE: SUPERADMIN / TEKNISI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: scadaNormal,
                ),
              ),
            ),
            const SizedBox(height: 28),

            _buildInfoCard(
              icon: Icons.badge_outlined,
              label: 'ID Petugas SCADA',
              value: 'TC-88492',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.email_outlined,
              label: 'Email Terdaftar',
              value: 'rudi.hermawan@trashcycle.com',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.business_outlined,
              label: 'Unit Fasilitas',
              value: 'Plant Pengolahan Daur Ulang Sector A',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.sensors_outlined,
              label: 'Status Otentikasi',
              value: 'Terverifikasi & Aktif',
              valueColor: scadaNormal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      elevation: 4,
      color: scadaCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: scadaBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: scadaNormal, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: scadaTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? scadaTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
