/// Model data Catatan Shift Petugas untuk penyimpanan SQLite lokal (Offline Mode).
class NoteModel {
  final int? id;
  final String userId;
  final String? userName;
  final String title;
  final String description;
  final String createdAt;

  NoteModel({
    this.id,
    required this.userId,
    this.userName,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  /// Konversi dari Map SQLite ke Object NoteModel
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      userId: map['user_id']?.toString() ?? '1',
      userName: map['user_name'] as String? ?? 'Petugas SCADA',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  /// Konversi dari Object NoteModel ke Map SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'user_name': userName ?? 'Petugas SCADA',
      'title': title,
      'description': description,
      'created_at': createdAt,
    };
  }

  /// Helper untuk copyWith
  NoteModel copyWith({
    int? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    String? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
