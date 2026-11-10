import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Member {
  const Member({
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
    required this.goal,
    required this.sessionsCount,
    required this.avatarColor,
  });

  final String id;
  final String initials;
  final String name;
  final String email;
  final String phone;
  final String goal;
  final int sessionsCount;
  final Color avatarColor;

  factory Member.fromMap(
    String id,
    Map<String, dynamic> data, {
    int sessionsCount = 0,
  }) {
    final storedName = data['name'];
    final name = storedName is String && storedName.trim().isNotEmpty
        ? storedName.trim()
        : 'Adhérent';
    final storedGoal = data['goal'];
    final goal = storedGoal is String && storedGoal.trim().isNotEmpty
        ? storedGoal.trim()
        : '';
    final storedEmail = data['email'];
    final storedPhone = data['phone'];
    return Member(
      id: id,
      initials: initialsFor(name),
      name: name,
      email: storedEmail is String ? storedEmail.trim() : '',
      phone: storedPhone is String ? storedPhone.trim() : '',
      goal: goal,
      sessionsCount: sessionsCount,
      avatarColor: Color(
        avatarColorFor(
          storedName is String && storedName.trim().isNotEmpty ? name : id,
        ),
      ),
    );
  }

  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    int sessionsCount = 0,
  }) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Adherent document ${snapshot.id} has no data.');
    }
    return Member.fromMap(snapshot.id, data, sessionsCount: sessionsCount);
  }
}

String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  return parts.take(2).map((part) => part.substring(0, 1).toUpperCase()).join();
}

int avatarColorFor(String value) {
  const colors = [0xFFA78BFA, 0xFFB8F23C, 0xFFE8906A, 0xFF6FA3D8];
  var hash = 0;
  for (final codeUnit in value.toLowerCase().codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return colors[hash % colors.length];
}
