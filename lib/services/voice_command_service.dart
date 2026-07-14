import '../models/alarm_model.dart';

class VoiceCommandService {
  bool isAlarmCommand(String text) {
    text = text.toLowerCase();

    return text.contains("alarm") ||
        text.contains("wake me") ||
        text.contains("remind me") ||
        text.contains("set alarm") ||
        text.contains("morning walk");
  }

  AlarmModel? parseAlarm(String text) {
    text = text.toLowerCase();

    // VERY SIMPLE VERSION
    // We'll make this AI-level later.

    int hour = 7;
    int minute = 0;

    if (text.contains("6")) hour = 6;
    if (text.contains("7")) hour = 7;
    if (text.contains("8")) hour = 8;
    if (text.contains("9")) hour = 9;
    if (text.contains("10")) hour = 10;
    if (text.contains("11")) hour = 11;
    if (text.contains("12")) hour = 12;

    String task = "Reminder";

    if (text.contains("walk")) {
      task = "Morning Walk";
    } else if (text.contains("study")) {
      task = "Study Time";
    } else if (text.contains("gym")) {
      task = "Gym";
    } else if (text.contains("medicine")) {
      task = "Medicine";
    } else if (text.contains("meeting")) {
      task = "Meeting";
    }

    DateTime now = DateTime.now();

    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    return AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch,
      dateTime: alarmTime,
      task: task,
    );
  }
}