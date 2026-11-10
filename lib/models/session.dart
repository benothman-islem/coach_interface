import 'package:flutter/material.dart';

enum SessionType {
  hiit('HIIT Training', 'HIIT'),
  cross('Cross Training', 'Cross'),
  mobility('Mobilité', 'Mobilité');

  const SessionType(this.label, this.firestoreValue);
  final String label;
  final String firestoreValue;
}

enum SessionFormMode { create, edit }

class SessionFormState {
  const SessionFormState({
    required this.mode,
    required this.sessionId,
    required this.initial,
  });

  final SessionFormMode mode;
  final String? sessionId;
  final SessionInput initial;
}

class SessionInput {
  const SessionInput({
    required this.type,
    required this.date,
    required this.time,
    required this.studio,
    required this.capacity,
  });

  final SessionType type;
  final DateTime date;
  final TimeOfDay time;
  final String studio;
  final int capacity;
}

class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.time,
    required this.durationMinutes,
    required this.title,
    required this.studio,
    required this.enrolledCount,
    required this.accentColor,
    required this.type,
    required this.date,
    required this.capacity,
    this.documentId,
    this.coachId = '',
    this.enrolledIds = const [],
    this.createdAt,
  });

  final int id;
  final TimeOfDay time;
  final int durationMinutes;
  final String title;
  final String studio;
  final int enrolledCount;
  final Color accentColor;
  final SessionType type;
  final DateTime date;
  final int capacity;
  final String? documentId;
  final String coachId;
  final List<String> enrolledIds;
  final DateTime? createdAt;

  SessionInput toInput() => SessionInput(
    type: type,
    date: date,
    time: time,
    studio: studio,
    capacity: capacity,
  );

  TrainingSession updatedFrom(SessionInput input) => TrainingSession(
    id: id,
    time: input.time,
    durationMinutes: durationMinutes,
    title: input.type.label,
    studio: input.studio,
    enrolledCount: enrolledCount,
    accentColor: _colorFor(input.type),
    type: input.type,
    date: input.date,
    capacity: input.capacity,
    documentId: documentId,
    coachId: coachId,
    enrolledIds: enrolledIds,
    createdAt: createdAt,
  );

  factory TrainingSession.created(int id, SessionInput input) =>
      TrainingSession(
        id: id,
        time: input.time,
        durationMinutes: 45,
        title: input.type.label,
        studio: input.studio,
        enrolledCount: 0,
        accentColor: _colorFor(input.type),
        type: input.type,
        date: input.date,
        capacity: input.capacity,
      );

  static Color _colorFor(SessionType type) => switch (type) {
    SessionType.hiit => const Color(0xFFF4A07A),
    SessionType.cross => const Color(0xFFB8F23C),
    SessionType.mobility => const Color(0xFFA78BFA),
  };
}

String formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

String formatFrenchDate(DateTime date) {
  const weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
}
