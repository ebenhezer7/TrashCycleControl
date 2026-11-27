import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/scada_colors.dart';
import '../../../core/services/local_db_service.dart';
import '../data/models/note_model.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final LocalDbService _dbService = LocalDbService();
  List<NoteModel> _notes = [];
  bool _isLoading = true;

  String _userRole = 'superadmin';
  String _currentUserId = '1';
  String _currentUserName = 'Petugas SCADA';

  static const Color scadaBg = ScadaColors.scadaBg;
  static const Color scadaAppBarBg = ScadaColors.scadaAppBarBg;
  static const Color scadaCardBg = ScadaColors.scadaCardBg;
  static const Color scadaBorder = ScadaColors.scadaBorder;
  static const Color scadaNormal = ScadaColors.scadaNormal;
  static const Color scadaAlert = ScadaColors.scadaAlert;
  static const Color scadaTextPrimary = ScadaColors.scadaTextPrimary;
  static const Color scadaTextSecondary = ScadaColors.scadaTextSecondary;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('user_role') ?? 'superadmin').toLowerCase();
    final userId = prefs.getString('user_id') ?? '1';
    final userName = prefs.getString('user_name') ?? 'Rudi Hermawan';

    List<NoteModel> notes;
    if (role == 'superadmin' || role == 'supervisor') {
      notes = await _dbService.getNotes();
    } else {
      notes = await _dbService.getNotesByUser(userId);
    }

    setState(() {
      _userRole = role;
      _currentUserId = userId;
      _currentUserName = userName;
      _notes = notes;
      _isLoading = false;
    });
  }

  void _showNoteDialog({NoteModel? note}) {
    final isEditing = note != null;
    final titleController = TextEditingController(text: isEditing ? note.title : '');
    final descriptionController = TextEditingController(text: isEditing ? note.description : '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('BATAL', style: TextStyle(color: scadaTextSecondary)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scadaNormal,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() => isSaving = true);

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final now = DateTime.now().toString().substring(0, 16);

                          if (isEditing) {
                            final updatedNote = note.copyWith(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                            );
                            await _dbService.updateNote(updatedNote);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Catatan berhasil diperbarui!'),
                                backgroundColor: scadaNormal,
                              ),
                            );
                          } else {
                            final newNote = NoteModel(
                              userId: _currentUserId,
                              userName: _currentUserName,
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              createdAt: now,
                            );
                            await _dbService.createNote(newNote);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Catatan berhasil disimpan!'),
                                backgroundColor: scadaNormal,
                              ),
                            );
                          }

                          navigator.pop();
                          _loadNotes();
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(isEditing ? 'SIMPAN' : 'TAMBAH'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFullAccess = _userRole == 'superadmin' || _userRole == 'supervisor';

    return Scaffold(
      backgroundColor: scadaBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'CATATAN SHIFT PETUGAS',
              style: TextStyle(
                color: scadaTextPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 16,
              ),
            ),
            Text(
              isFullAccess
                  ? 'Akses: Semua Catatan (${_userRole.toUpperCase()})'
                  : 'Akses: Catatan Pribadi (${_userRole.toUpperCase()})',
              style: const TextStyle(
                color: scadaNormal,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: scadaAppBarBg,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: scadaNormal),
            tooltip: 'Refresh Catatan Shift',
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: scadaNormal))
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.assignment_late_outlined,
                        size: 72,
                        color: scadaTextSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada catatan shift saat ini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scadaTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isFullAccess
                            ? 'Silakan tambahkan catatan baru jika ada aktivitas shift.'
                            : 'Catatan shift yang Anda buat akan muncul di sini.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF627182)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showNoteDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scadaNormal,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add_comment_outlined),
                        label: const Text(
                          'TAMBAH CATATAN SHIFT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Semantics(
                      label: 'Catatan Shift ${note.title}, ditulis oleh ${note.userName ?? "Petugas SCADA"}, dibuat pada ${note.createdAt}. Deskripsi: ${note.description}',
                      child: Card(
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
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: scadaNormal.withAlpha(25),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: scadaNormal.withAlpha(80)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.person_outline, size: 12, color: scadaNormal),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Oleh: ${note.userName ?? "Petugas SCADA"}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: scadaNormal,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: scadaAlert),
                                  tooltip: 'Hapus Catatan Shift',
                                  onPressed: () => _confirmDelete(note),
                                ),
                              ],
                            ),
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
        tooltip: 'Tambah Catatan Shift Baru',
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text(
          'CATAT SHIFT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
