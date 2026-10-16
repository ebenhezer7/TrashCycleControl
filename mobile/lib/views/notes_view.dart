import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/local_db_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final LocalDbService _dbService = LocalDbService();
  List<NoteModel> _notes = [];
  bool _isLoading = true;

  // Constants untuk Tema Industrial SCADA Dark-Mode
  static const Color scadaBg = Color(0xFF0F1218);
  static const Color scadaAppBarBg = Color(0xFF161B22);
  static const Color scadaCardBg = Color(0xFF1A1F29);
  static const Color scadaBorder = Color(0xFF2C3444);
  static const Color scadaNormal = Color(0xFF00E5FF);
  static const Color scadaAlert = Color(0xFFFF3366);
  static const Color scadaTextPrimary = Color(0xFFF0F4F8);
  static const Color scadaTextSecondary = Color(0xFF8B98A9);

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  /// READ: Mengambil seluruh catatan shift dari database SQLite
  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _dbService.getNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  /// Dialog Form untuk Tambah (Create) / Edit (Update) Catatan
  void _showNoteDialog({NoteModel? note}) {
    final isEditing = note != null;
    final titleController = TextEditingController(text: isEditing ? note.title : '');
    final descriptionController = TextEditingController(text: isEditing ? note.description : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: scadaCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: scadaBorder),
          ),
          title: Text(
            isEditing ? 'EDIT CATATAN SHIFT' : 'TAMBAH CATATAN SHIFT',
            style: const TextStyle(
              color: scadaTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    style: const TextStyle(color: scadaTextPrimary),
                    decoration: InputDecoration(
                      labelText: 'Judul / Topik Shift',
                      labelStyle: const TextStyle(color: scadaTextSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaNormal, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaAlert),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaAlert, width: 2),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: scadaTextPrimary),
                    decoration: InputDecoration(
                      labelText: 'Deskripsi / Log Kejadian',
                      labelStyle: const TextStyle(color: scadaTextSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaNormal, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaAlert),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: scadaAlert, width: 2),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
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
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final now = DateTime.now().toString().substring(0, 16);

                if (isEditing) {
                  // UPDATE
                  final updatedNote = note.copyWith(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                  );
                  await _dbService.updateNote(updatedNote);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catatan berhasil diperbarui!'),
                        backgroundColor: scadaNormal,
                      ),
                    );
                  }
                } else {
                  // CREATE
                  final newNote = NoteModel(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    createdAt: now,
                  );
                  await _dbService.createNote(newNote);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Catatan berhasil disimpan!'),
                        backgroundColor: scadaNormal,
                      ),
                    );
                  }
                }

                if (!mounted) return;
                Navigator.pop(context);
                _loadNotes(); // Refresh UI State
              },
              child: Text(isEditing ? 'SIMPAN' : 'TAMBAH'),
            ),
          ],
        );
      },
    );
  }

  /// DELETE: Konfirmasi dan Hapus Catatan
  Future<void> _confirmDelete(NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: scadaCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: scadaBorder),
        ),
        title: const Text('HAPUS CATATAN', style: TextStyle(color: scadaTextPrimary)),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${note.title}"?',
          style: const TextStyle(color: scadaTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL', style: TextStyle(color: scadaTextSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scadaAlert),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('HAPUS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && note.id != null) {
      await _dbService.deleteNote(note.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil dihapus.'),
            backgroundColor: scadaAlert,
          ),
        );
      }
      _loadNotes(); // Refresh UI State
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scadaBg,
      appBar: AppBar(
        title: const Text(
          'CATATAN SHIFT PETUGAS',
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
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 64, color: scadaTextSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada catatan shift.',
                        style: TextStyle(fontSize: 16, color: scadaTextSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showNoteDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scadaNormal,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('TAMBAH CATATAN PERTAMA'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      elevation: 4,
                      color: scadaCardBg,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: scadaBorder),
                      ),
                      child: InkWell(
                        onTap: () => _showNoteDialog(note: note),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // KERAPIAN ELEMEN: Teks dibungkus dengan Expanded agar tidak leaking/overflow ke kanan
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: scadaTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      note.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: scadaTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: scadaNormal),
                                        const SizedBox(width: 4),
                                        Text(
                                          note.createdAt,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: scadaNormal,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Tombol Hapus (Delete)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: scadaAlert),
                                tooltip: 'Hapus Catatan',
                                onPressed: () => _confirmDelete(note),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        backgroundColor: scadaNormal,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text(
          'CATAT SHIFT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
