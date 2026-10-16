import 'package:flutter/material.dart';

/// Halaman Kelola Pengguna / Petugas Lapangan.
class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaCardBg = Color(0xFF1A1F29);
  static const Color scadaBorder = Color(0xFF2C3444);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  final List<Map<String, String>> _users = [
    {
      'name': 'Budi Santoso',
      'email': 'budi.santoso@trashcycle.com',
      'role': 'Petugas Lapangan',
      'status': 'Aktif',
    },
    {
      'name': 'Siti Aminah',
      'email': 'siti.aminah@trashcycle.com',
      'role': 'Supervisor SCADA',
      'status': 'Aktif',
    },
    {
      'name': 'Rudi Hermawan',
      'email': 'rudi.hermawan@trashcycle.com',
      'role': 'Teknisi Mesin',
      'status': 'Aktif',
    },
  ];

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'Petugas Lapangan');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: scadaCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: scadaBorder),
        ),
        title: const Text(
          'TAMBAH USER BARU',
          style: TextStyle(
            color: scadaTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: scadaTextPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: const TextStyle(color: scadaTextSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: scadaBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: scadaNormal, width: 2),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: scadaTextPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: scadaTextSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: scadaBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: scadaNormal, width: 2),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: roleController,
                  style: const TextStyle(color: scadaTextPrimary),
                  decoration: InputDecoration(
                    labelText: 'Peran / Jabatan',
                    labelStyle: const TextStyle(color: scadaTextSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: scadaBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: scadaNormal, width: 2),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Peran wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: scadaTextSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scadaNormal,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              setState(() {
                _users.add({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': roleController.text.trim(),
                  'status': 'Aktif',
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User baru berhasil ditambahkan!'),
                  backgroundColor: scadaNormal,
                ),
              );
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'KELOLA USER',
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
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
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
                children: [
                  CircleAvatar(
                    backgroundColor: scadaNormal.withAlpha(30),
                    child: Text(
                      user['name']![0].toUpperCase(),
                      style: const TextStyle(
                        color: scadaNormal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: scadaTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user['email']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: scadaTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scadaNormal.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: scadaNormal.withAlpha(80)),
                          ),
                          child: Text(
                            user['role']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: scadaNormal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: scadaAlert),
                    onPressed: () {
                      setState(() {
                        _users.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User berhasil dihapus.'),
                          backgroundColor: scadaAlert,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: scadaNormal,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text(
          'TAMBAH USER BARU',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
