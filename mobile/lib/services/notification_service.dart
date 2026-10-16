import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk menangani pengiriman Notifikasi Lokal Peringatan (Local Notifications).
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inisialisasi plugin notifikasi lokal
  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    _isInitialized = true;

    await requestPermission();
  }

  /// Meminta izin notifikasi (khusus Android 13+ / API 33+ & iOS)
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Menampilkan notifikasi lokal peringatan SCADA secara langsung
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'trashcycle_alerts',
      'Peringatan SCADA Telemetry',
      channelDescription: 'Saluran notifikasi untuk peringatan anomali alat daur ulang',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Peringatan TrashCycleControl',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
