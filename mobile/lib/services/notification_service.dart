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

  /// 1. Inisialisasi plugin flutter_local_notifications
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

  /// 2. Meminta izin notifikasi (wajib untuk Android 13/API 33 ke atas & iOS)
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// 3. Memunculkan notifikasi peringatan bahaya di system tray HP
  Future<void> showWarningNotification(String title, String body) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'trashcycle_warning_channel',
      'Peringatan Anomali Telemetry',
      channelDescription: 'Notifikasi otomatis saat parameter alat daur ulang melewati batas aman',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Peringatan TrashCycleControl',
      icon: '@mipmap/ic_launcher',
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

  /// Method alias jika dipanggil dengan nama fungsi alternatif
  Future<void> showNotification({required String title, required String body}) async {
    await showWarningNotification(title, body);
  }
}
