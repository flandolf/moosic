import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:moosic/screens/home_screen.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const BaseApp());
}

class BaseApp extends StatelessWidget {
  const BaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),

    );
  }
}
