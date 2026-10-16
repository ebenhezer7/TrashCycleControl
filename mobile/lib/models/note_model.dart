/// Model data untuk "Catatan Shift Petugas" (Offline Shift Notes).
class NoteModel {
  final int? id;
  final String title;
  final String description;
  final String createdAt;

  const NoteModel({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  /// Konversi object NoteModel ke Map untuk disimpan di database SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Factory untuk mengkonversi Map dari SQLite ke object NoteModel.
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  /// Helper untuk membuat salinan object dengan perubahan nilai tertentu.
  NoteModel copyWith({
    int? id,
    String? title,
    String? description,
    String? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
