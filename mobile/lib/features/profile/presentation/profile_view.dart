import 'package:flutter/material.dart';
import '../../../core/constants/scada_colors.dart';
import '../data/profile_repository.dart';
import 'profile_form.dart';

/// Halaman UI Profil Petugas Lapangan.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileRepository _repository = ProfileRepository();
  bool _isLoading = true;
  Map<String, String> _profileData = {};

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaCardBg = ScadaColors.scadaCardBg;
  static const Color scadaBorder = ScadaColors.scadaBorder;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final data = await _repository.fetchProfile();
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      resizeToAvoidBottomInset: true,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: scadaNormal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: scadaNormal.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(color: scadaNormal, width: 2.5),
                          ),
                          child: Center(
                            child: Text(
                              _profileData['name'] != null && _profileData['name']!.isNotEmpty
                                  ? _profileData['name']![0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
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
                          child: const Icon(Icons.verified, size: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profileData['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
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
                    child: Text(
                      'ROLE: ${(_profileData['role'] ?? 'SUPERADMIN').toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: scadaNormal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Card(
                    elevation: 4,
                    color: scadaCardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: scadaBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID Petugas: ${_profileData['id'] ?? 'TC-88492'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: scadaNormal,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 16),

                          ProfileForm(
                            initialData: _profileData,
                            onSuccess: _loadProfileData,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
