import 'package:flutter/material.dart';
import 'home_page.dart'; // 👈 Check karna ye import sahi se ho

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vaani AI',
      home: const HomePage(), // 👈 Yahan 'HomePage()' kar do!
    );
  }
}