import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service Logging Terpusat untuk Tracing & Error Handling Production-Ready.
class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    // Pada mode release, log dibatasi hanya untuk level warning & error agar hemat memori
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  /// Menulis log informasi umum
  static void info(String message) {
    _logger.i('[INFO] $message');
  }

  /// Menulis log peringatan (warning)
  static void warning(String message) {
    _logger.w('[WARNING] $message');
  }

  /// Menulis log error terstruktur beserta Exception dan StackTrace
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[ERROR] $message', error: error, stackTrace: stackTrace);
  }
}
