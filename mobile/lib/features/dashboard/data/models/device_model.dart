/// Model data Perangkat Alat Daur Ulang beserta status telemetry sensornya.
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String status;
  final double currentTemperature;
  final double currentHumidity;
  final double currentPressure;
  final String alertStatus;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.status = 'operational',
    required this.currentTemperature,
    required this.currentHumidity,
    required this.currentPressure,
    this.alertStatus = 'Normal',
  });

  /// Parsing JSON dari REST API Laravel backend
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('Device ID is required');
    }
    return DeviceModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Alat Daur Ulang',
      type: json['type'] as String? ?? 'Sensor',
      status: json['status'] as String? ?? 'operational',
      currentTemperature: (json['current_temperature'] as num?)?.toDouble() ??
          (json['temperature'] as num?)?.toDouble() ??
          0.0,
      currentHumidity: (json['current_humidity'] as num?)?.toDouble() ??
          (json['humidity'] as num?)?.toDouble() ??
          0.0,
      currentPressure: (json['current_pressure'] as num?)?.toDouble() ??
          (json['pressure'] as num?)?.toDouble() ??
          0.0,
      alertStatus: json['alert_status'] as String? ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'current_temperature': currentTemperature,
      'current_humidity': currentHumidity,
      'current_pressure': currentPressure,
      'alert_status': alertStatus,
    };
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    double? currentTemperature,
    double? currentHumidity,
    double? currentPressure,
    String? alertStatus,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      currentPressure: currentPressure ?? this.currentPressure,
      alertStatus: alertStatus ?? this.alertStatus,
    );
  }

  bool get hasAlert => alertStatus != 'Normal' && alertStatus.isNotEmpty;
}
