import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk menangani Notifikasi Lokal System Tray di HP Petugas.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inisialisasi awal Flutter Local Notifications & Channel Peringatan SCADA
  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Meminta izin Notifikasi untuk Android 13+ (API 33)
    await _requestPermissions();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Menampilkan Notifikasi Peringatan Bahaya Telemetry SCADA
  Future<void> showWarningNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scada_alert_channel',
      'Peringatan Telemetry SCADA',
      channelDescription: 'Saluran notifikasi khusus untuk bahaya anomali alat daur ulang',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFFF3366),
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }
}
