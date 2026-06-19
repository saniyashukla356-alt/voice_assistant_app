import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_page.dart';
import 'reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService().init();
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vaani AI',
      home: HomePage(),
    );
  }
}