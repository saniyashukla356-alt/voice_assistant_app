import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/alarm_service.dart';

class AlarmRingScreen extends StatefulWidget {
  final int alarmId;

  const AlarmRingScreen({
    super.key,
    required this.alarmId,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  final FlutterTts flutterTts = FlutterTts();

  String reminder = "Loading...";

  @override
  void initState() {
    super.initState();
    loadReminder();
  }

  Future<void> loadReminder() async {
    reminder = await AlarmService.getReminder(widget.alarmId);

    setState(() {});

    await speakReminder();
  }

  Future<void> speakReminder() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);

    await flutterTts.speak(
      "Hello! This is your reminder. $reminder",
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> stopAlarm() async {
    await AlarmService.stopAlarm(widget.alarmId);

    await AlarmService.deleteReminder(widget.alarmId);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> snoozeAlarm() async {
    await AlarmService.snoozeAlarm(widget.alarmId);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18122B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.alarm,
                  color: Colors.deepPurpleAccent,
                  size: 120,
                ),

                const SizedBox(height: 30),

                const Text(
                  "Reminder",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  reminder,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(220, 55),
                  ),
                  child: const Text(
                    "STOP",
                    style: TextStyle(fontSize: 20),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: snoozeAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(220, 55),
                  ),
                  child: const Text(
                    "SNOOZE (5 min)",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
