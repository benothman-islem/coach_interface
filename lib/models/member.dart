import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MemberStatus { active, expiring, toVerify, inactive }

class Member {
  const Member({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    String? initials,
    Color? avatarColor,
    this.goal = '',
    this.sessionsCount = 0,
    this.photoUrl,
    this.status = MemberStatus.inactive,
    this.subscriptionName = 'Sans abonnement',
    this.createdAt,
  }) : _providedInitials = initials,
       avatarColor = avatarColor ?? const Color(0xFFA78BFA);

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final MemberStatus status;
  final String subscriptionName;
  final DateTime? createdAt;
  final String goal;
  final int sessionsCount;
  final Color avatarColor;
  final String? _providedInitials;

  String get initials => _providedInitials?.isNotEmpty == true
      ? _providedInitials!
      : initialsFor(name);

  factory Member.fromMap(
    Map<String, dynamic> map,
    String docId, {
    int sessionsCount = 0,
  }) {
    final nameValue = map['name'];
    final name = nameValue is String && nameValue.trim().isNotEmpty
        ? nameValue.trim()
        : 'Adhérent';
    final emailValue = map['email'];
    final phoneValue = map['phone'];
    final photoValue = map['photoUrl'];
    final goalValue = map['goal'];
    final subscriptionValue = map['subscriptionName'];
    return Member(
      id: docId,
      name: name,
      email: emailValue is String ? emailValue.trim() : '',
      phone: phoneValue is String ? phoneValue.trim() : '',
      photoUrl: photoValue is String ? photoValue : null,
      status: _parseStatus(map['status']),
      subscriptionName: subscriptionValue is String
          ? subscriptionValue
          : 'Sans abonnement',
      createdAt: _parseDate(map['createdAt']),
      goal: goalValue is String ? goalValue.trim() : '',
      sessionsCount: sessionsCount,
      avatarColor: Color(avatarColorFor(nameValue is String ? name : docId)),
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
    return Member.fromMap(data, snapshot.id, sessionsCount: sessionsCount);
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'photoUrl': photoUrl,
    'status': status.name,
    'subscriptionName': subscriptionName,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    'goal': goal,
    'sessionsCount': sessionsCount,
  };

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    MemberStatus? status,
    String? subscriptionName,
    DateTime? createdAt,
    String? goal,
    int? sessionsCount,
    String? initials,
    Color? avatarColor,
  }) => Member(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    status: status ?? this.status,
    subscriptionName: subscriptionName ?? this.subscriptionName,
    createdAt: createdAt ?? this.createdAt,
    goal: goal ?? this.goal,
    sessionsCount: sessionsCount ?? this.sessionsCount,
    initials: initials ?? _providedInitials,
    avatarColor: avatarColor ?? this.avatarColor,
  );

  static MemberStatus _parseStatus(Object? value) => switch (value) {
    'active' => MemberStatus.active,
    'expiring' => MemberStatus.expiring,
    'toVerify' => MemberStatus.toVerify,
    _ => MemberStatus.inactive,
  };

  static DateTime? _parseDate(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    DateTime date => date,
    String date => DateTime.tryParse(date),
    _ => null,
  };
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
