import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

class AlarmService {
  static Future<void> initialize() async {
    await Alarm.init();
  }

  static Future<void> setAlarm({
    required AlarmModel alarm,
  }) async {
    // Save the reminder text
    await saveReminder(alarm.id, alarm.task);
    // Also save the alarm model for persistence
    await saveAlarm(alarm);

    final settings = AlarmSettings(
      id: alarm.id,
      dateTime: alarm.dateTime,
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),
      notificationSettings: const NotificationSettings(
        title: 'Vaani Reminder',
        body: 'Tap to open Vaani',
      ),
    );

    await Alarm.set(alarmSettings: settings);
  }

  static Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
    await deleteReminder(id);
    await deleteAlarm(id);
  }

  static Future<void> snoozeAlarm(int id) async {
    final alarm = await Alarm.getAlarm(id);
    if (alarm == null) return;

    final newSettings = alarm.copyWith(
      dateTime: DateTime.now().add(const Duration(minutes: 5)),
    );

    await Alarm.set(alarmSettings: newSettings);
  }

  // --- Persistence Methods ---

  static Future<void> saveReminder(int id, String reminder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminder_$id', reminder);
  }

  static Future<String> getReminder(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reminder_$id') ?? "Time's up!";
  }

  static Future<void> deleteReminder(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_$id');
  }

  static Future<void> saveAlarm(AlarmModel alarm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "alarm_${alarm.id}",
      jsonEncode(alarm.toJson()),
    );
  }

  static Future<AlarmModel?> getAlarm(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("alarm_$id");
    if (jsonString == null) return null;
    return AlarmModel.fromJson(jsonDecode(jsonString));
  }

  static Future<void> deleteAlarm(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("alarm_$id");
  }
}
