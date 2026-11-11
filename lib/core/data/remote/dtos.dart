import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:salledesport/models/member.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/user_profile.dart';

class UserDto {
  const UserDto({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.photoUrl,
    this.role = '',
    this.createdAt,
    this.specialties = const [],
    this.coachSince,
    this.rating,
    this.experienceYears,
    this.isActive,
    this.coachId,
    this.goal,
  });

  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String role;
  final DateTime? createdAt;
  final List<String> specialties;
  final DateTime? coachSince;
  final double? rating;
  final int? experienceYears;
  final bool? isActive;
  final String? coachId;
  final String? goal;

  factory UserDto.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    return UserDto(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? '',
      createdAt: _date(data['createdAt']),
      specialties:
          (data['specialties'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
      coachSince: _date(data['coachSince']),
      rating: (data['rating'] as num?)?.toDouble(),
      experienceYears: data['experienceYears'] as int?,
      isActive: data['isActive'] as bool?,
      coachId: data['coachId'] as String?,
      goal: data['goal'] as String?,
    );
  }

  static DateTime? _date(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime date => date,
    _ => null,
  };

  CoachProfile toCoachProfile({String id = ''}) {
    final startDate = coachSince ?? createdAt;
    final displayName = name.trim().isNotEmpty ? name : email;
    return CoachProfile(
      id: id,
      name: displayName,
      email: email,
      phone: phone,
      role: role.isEmpty ? 'coach' : role,
      initials: displayName.isEmpty ? '—' : initialsFor(displayName),
      memberSince: startDate == null
          ? '—'
          : 'Coach depuis ${formatFrenchDate(startDate)}',
      isActive: isActive ?? false,
      specialties: specialties,
      experienceYears: experienceYears,
      rating: rating == null ? '—' : '${rating!.toStringAsFixed(1)} / 5',
      photoUrl: photoUrl,
    );
  }
}

class SessionDto {
  const SessionDto({
    this.coachId = '',
    this.type = '',
    this.title = '',
    this.studio = '',
    this.startAt,
    this.durationMin = 45,
    this.capacity = 0,
    this.enrolledIds = const [],
    this.createdAt,
  });

  final String coachId;
  final String type;
  final String title;
  final String studio;
  final DateTime? startAt;
  final int durationMin;
  final int capacity;
  final List<String> enrolledIds;
  final DateTime? createdAt;

  factory SessionDto.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    return SessionDto(
      coachId: data['coachId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      title: data['title'] as String? ?? '',
      studio: data['studio'] as String? ?? '',
      startAt: _date(data['startAt']),
      durationMin: data['durationMin'] as int? ?? 45,
      capacity: data['capacity'] as int? ?? 0,
      enrolledIds:
          (data['enrolledIds'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
      createdAt: _date(data['createdAt']),
    );
  }

  static DateTime? _date(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime date => date,
    _ => null,
  };

  TrainingSession toModel(String id) {
    final type = SessionType.values.firstWhere(
      (value) => value.firestoreValue == this.type,
      orElse: () => SessionType.hiit,
    );
    final date = startAt ?? DateTime.now();
    return TrainingSession(
      id: id.hashCode,
      documentId: id,
      time: TimeOfDay(hour: date.hour, minute: date.minute),
      durationMinutes: durationMin,
      title: title.isEmpty ? type.label : title,
      studio: studio,
      enrolledCount: enrolledIds.length,
      accentColor: _colorFor(type),
      type: type,
      date: date,
      capacity: capacity,
      enrolledIds: enrolledIds,
      coachId: coachId,
      createdAt: createdAt,
    );
  }

  static Color _colorFor(SessionType type) => switch (type) {
    SessionType.hiit => const Color(0xFFF4A07A),
    SessionType.cross => const Color(0xFFB8F23C),
    SessionType.mobility => const Color(0xFFA78BFA),
  };
}
