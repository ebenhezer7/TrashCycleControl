import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/network/api_service.dart';
import 'core/services/log_service.dart';
import 'features/auth/presentation/login_view.dart';
import 'features/navigation/presentation/main_navigation.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Tangkapan Error UI Rendering Flutter (Widget / Layout Error)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      Log.error(
        'Unhandled Flutter UI Error: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    };

    // 2. Tangkapan Error Asynchronous / Platform Engine Error
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      Log.error('Unhandled Platform/Async Error: $error', error, stack);
      return true;
    };

    // Memeriksa status login petugas
    final apiService = ApiService();
    final bool loggedIn = await apiService.isLoggedIn();

    Log.info('Aplikasi TrashCycleControl berhasil diinisialisasi. LoggedIn: $loggedIn');

    runApp(MyApp(isLoggedIn: loggedIn));
  }, (Object error, StackTrace stack) {
    Log.error('Unhandled Zone Error: $error', error, stack);
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrashCycleControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: isLoggedIn ? const MainNavigationView() : const LoginView(),
    );
  }
}
