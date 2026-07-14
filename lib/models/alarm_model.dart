class AlarmModel {
  final int id;
  final DateTime dateTime;
  final String task;

  AlarmModel({
    required this.id,
    required this.dateTime,
    required this.task,
  });

  AlarmModel copyWith({
    int? id,
    DateTime? dateTime,
    String? task,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      task: task ?? this.task,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'task': task,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      task: json['task'],
    );
  }
}
