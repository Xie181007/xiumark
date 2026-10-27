import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';

void main() => runApp(const XiuMarkApp());

class XiuMarkApp extends StatelessWidget {
  const XiuMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF152B43);
    const teal = Color(0xFF087E83);
    return MaterialApp(
      title: 'XiuMark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7F8),
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
