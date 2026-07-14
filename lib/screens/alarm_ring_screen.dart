import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:alarm/alarm.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmRingScreen extends StatefulWidget {
  final String task;
  final int alarmId;

  const AlarmRingScreen({
    super.key,
    required this.task,
    required this.alarmId,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speakReminder();
  }

  Future<void> speakReminder() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);

    await tts.speak(
      "Good morning. This is Vaani. "
          "You asked me to remember ${widget.task}. "
          "Have a wonderful day.",
    );
  }

  Future<void> stopAlarm() async {
    await Alarm.stop(widget.alarmId);
    await tts.stop();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.alarm,
              size: 120,
              color: Colors.white,
            ),

            const SizedBox(height: 30),

            const Text(
              "VAANI ALARM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.task,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 50),

            ElevatedButton(
              onPressed: stopAlarm,
              child: const Text("STOP"),
            )
          ],
        ),
      ),
    );
  }
}