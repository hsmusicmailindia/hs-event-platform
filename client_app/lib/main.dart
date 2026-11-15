import 'package:flutter/material.dart';
import 'features/discovery/presentation/discovery_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HsMusicApp());
}

class HsMusicApp extends StatelessWidget {
  const HsMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HS MUSIC Event Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBFBFD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0071E3),
          surface: const Color(0xFFFBFBFD),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          iconTheme: IconThemeData(color: Color(0xFF1D1D1F)),
        ),
      ),
      home: const DiscoveryScreen(),
    );
  }
}