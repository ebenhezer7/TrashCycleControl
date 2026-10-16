import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'views/login_view.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cek token tersimpan di SharedPreferences saat aplikasi dibuka
  final apiService = ApiService();
  final bool loggedIn = await apiService.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
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
