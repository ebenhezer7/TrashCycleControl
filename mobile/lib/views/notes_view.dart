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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Edit Catatan Shift' : 'Tambah Catatan Shift Baru'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul / Topik Shift',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi / Log Kejadian',
                      border: OutlineInputBorder(),
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
              child: const Text('Batal'),
            ),
            FilledButton(
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
                      const SnackBar(content: Text('Catatan berhasil diperbarui!')),
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
                      const SnackBar(content: Text('Catatan berhasil disimpan!')),
                    );
                  }
                }

                if (!mounted) return;
                Navigator.pop(context);
                _loadNotes(); // Refresh UI State
              },
              child: Text(isEditing ? 'Simpan' : 'Tambah'),
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
        title: const Text('Hapus Catatan'),
        content: Text('Apakah Anda yakin ingin menghapus catatan "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && note.id != null) {
      await _dbService.deleteNote(note.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus.')),
        );
      }
      _loadNotes(); // Refresh UI State
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Shift Petugas'),
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada catatan shift.',
                        style: TextStyle(fontSize: 16, color: colorScheme.outline),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showNoteDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Catatan Pertama'),
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
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              note.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: colorScheme.outline),
                                const SizedBox(width: 4),
                                Text(
                                  note.createdAt,
                                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: colorScheme.error),
                          tooltip: 'Hapus Catatan',
                          onPressed: () => _confirmDelete(note),
                        ),
                        onTap: () => _showNoteDialog(note: note), // UPDATE saat item di-tap
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(), // CREATE
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Catat Shift'),
      ),
    );
  }
}
