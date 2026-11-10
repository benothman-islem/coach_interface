<<<<<<< HEAD
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
=======
enum MemberStatus { active, expiring, toVerify, inactive }

class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final MemberStatus status;
  final String subscriptionName;
  final DateTime createdAt;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.status,
    required this.subscriptionName,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'M';
  }

  factory Member.fromMap(Map<String, dynamic> map, String docId) {
    return Member(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      status: _parseStatus(map['status']),
      subscriptionName: map['subscriptionName'] ?? 'Sans abonnement',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status.name,
      'subscriptionName': subscriptionName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    MemberStatus? status,
    String? subscriptionName,
    DateTime? createdAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static MemberStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'active':
        return MemberStatus.active;
      case 'expiring':
        return MemberStatus.expiring;
      case 'toVerify':
        return MemberStatus.toVerify;
      case 'inactive':
      default:
        return MemberStatus.inactive;
    }
  }
}
>>>>>>> admin/master
