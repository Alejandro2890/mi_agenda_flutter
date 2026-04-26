import 'package:flutter/material.dart';

class EventModel {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String? imagePath;
  final bool hasNotification;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.imagePath,
    this.hasNotification = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'imagePath': imagePath,
      'hasNotification': hasNotification ? 1 : 0,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      imagePath: map['imagePath'],
      hasNotification: map['hasNotification'] == 1,
    );
  }
}
