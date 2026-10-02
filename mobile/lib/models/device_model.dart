import 'dart:convert';

/// Model data untuk menampung informasi alat daur ulang
/// (Incinerator, Composter, Pirolisis) beserta data sensor dan status alert.
class DeviceModel {
  final String id;
  final String name;
  final String type; // Contoh: 'Incinerator', 'Composter', 'Pirolisis'
  final double currentTemperature;
  final double currentHumidity;
  final double currentPressure;
  final String alertStatus; // Contoh: 'Normal', 'Warning', 'Alert', 'Aman', 'Bahaya'

  const DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currentTemperature,
    required this.currentHumidity,
    required this.currentPressure,
    required this.alertStatus,
  });

  /// Factory method untuk konversi data JSON dari REST API Laravel ke object DeviceModel.
  /// Menangani fleksibilitas penamaan atribut (snake_case / camelCase) serta tipe data.
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['device_name'] as String? ?? 'Alat Daur Ulang',
      type: json['type'] as String? ?? json['device_type'] as String? ?? 'Incinerator',
      currentTemperature: _parseDouble(
        json['currentTemperature'] ?? json['current_temperature'] ?? json['temperature'],
      ),
      currentHumidity: _parseDouble(
        json['currentHumidity'] ?? json['current_humidity'] ?? json['humidity'],
      ),
      currentPressure: _parseDouble(
        json['currentPressure'] ?? json['current_pressure'] ?? json['pressure'],
      ),
      alertStatus: (json['alertStatus'] ?? json['alert_status'] ?? json['status'] ?? 'Normal').toString(),
    );
  }

  /// Konversi object DeviceModel ke Map JSON untuk dikirim ke API atau disimpan secara lokal.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currentTemperature': currentTemperature,
      'currentHumidity': currentHumidity,
      'currentPressure': currentPressure,
      'alertStatus': alertStatus,
    };
  }

  /// Getter untuk mengecek apakah alat memiliki status alert/peringatan.
  bool get hasAlert {
    final status = alertStatus.trim().toLowerCase();
    return status != 'normal' && status != 'aman' && status != 'ok' && status.isNotEmpty;
  }

  /// Helper untuk menyalin object dengan opsi mengubah properti tertentu.
  DeviceModel copyWith({
    String? id,
    String? name,
    String? type,
    double? currentTemperature,
    double? currentHumidity,
    double? currentPressure,
    String? alertStatus,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      currentPressure: currentPressure ?? this.currentPressure,
      alertStatus: alertStatus ?? this.alertStatus,
    );
  }

  /// Utility privat untuk konversi tipe data dinamis (int, double, String) ke double.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'DeviceModel(id: $id, name: $name, type: $type, temp: $currentTemperature°C, humidity: $currentHumidity%, pressure: ${currentPressure}bar, alertStatus: $alertStatus)';
  }
}
