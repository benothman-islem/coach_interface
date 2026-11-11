import 'dart:async';

import 'package:flutter/material.dart';

import 'package:salledesport/models/member.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/ui_state.dart';
import 'package:salledesport/core/data/remote/dtos.dart';

import 'repositories.dart';

class FakeRepositories extends AppRepositories {
  FakeRepositories()
    : this._(_FakeProfileRepository(), _FakeSessionsRepository());

  FakeRepositories._(
    _FakeProfileRepository profiles,
    _FakeSessionsRepository sessions,
  ) : super(
        profiles: profiles,
        sessions: sessions,
        members: _FakeMembersRepository(sessions),
      );
}

class _FakeProfileRepository implements ProfileRepository {
  UserDto _profile = const UserDto(
    name: 'Coach de test',
    email: 'coach@example.com',
    phone: '',
    role: 'coach',
    specialties: [],
  );

  final _controller = StreamController<UiState<UserDto>>.broadcast();

  @override
  Stream<UiState<UserDto>> watchProfile(String uid) => Stream.multi((output) {
    output.add(UiSuccess(_profile));
    final subscription = _controller.stream.listen(output.add);
    output.onCancel = subscription.cancel;
  });

  @override
  Future<void> updateProfile(
    String uid, {
    required String name,
    required String phone,
  }) async {
    _profile = UserDto(
      name: name,
      email: _profile.email,
      phone: phone,
      role: _profile.role,
      createdAt: _profile.createdAt,
      specialties: _profile.specialties,
      coachSince: _profile.coachSince,
      rating: _profile.rating,
      experienceYears: _profile.experienceYears,
      isActive: _profile.isActive,
    );
    _controller.add(UiSuccess(_profile));
  }
}

class _FakeSessionsRepository implements SessionsRepository {
  final _controller =
      StreamController<UiState<List<TrainingSession>>>.broadcast();
  final _sessions = <TrainingSession>[
    _sampleSession(
      1,
      'Yoga Flow',
      'Studio B',
      9,
      0,
      SessionType.mobility,
      const Color(0xFFA78BFA),
      8,
      60,
    ),
    _sampleSession(
      2,
      'Cross Training',
      'Studio A',
      11,
      30,
      SessionType.cross,
      const Color(0xFFB8F23C),
      12,
      45,
    ),
    _sampleSession(
      3,
      'HIIT Training',
      'Studio A',
      18,
      30,
      SessionType.hiit,
      const Color(0xFFF4A07A),
      9,
      45,
    ),
  ];

  static TrainingSession _sampleSession(
    int id,
    String title,
    String studio,
    int hour,
    int minute,
    SessionType type,
    Color color,
    int enrolled,
    int duration,
  ) {
    final now = DateTime.now();
    return TrainingSession(
      id: id,
      time: TimeOfDay(hour: hour, minute: minute),
      durationMinutes: duration,
      title: title,
      studio: studio,
      enrolledCount: enrolled,
      accentColor: color,
      type: type,
      date: DateTime(now.year, now.month, now.day),
      capacity: 16,
      documentId: '$id',
      coachId: 'preview-coach',
      enrolledIds: switch (id) {
        1 => const ['preview-1', 'preview-2'],
        2 => const ['preview-1', 'preview-2', 'preview-3'],
        3 => const ['preview-1'],
        _ => const [],
      },
    );
  }

  Stream<UiState<List<TrainingSession>>> _stream() => Stream.multi((output) {
    output.add(
      _sessions.isEmpty
          ? const UiEmpty()
          : UiSuccess(List.unmodifiable(_sessions)),
    );
    final subscription = _controller.stream.listen(output.add);
    output.onCancel = subscription.cancel;
  });

  void _emit() => _controller.add(
    _sessions.isEmpty
        ? const UiEmpty()
        : UiSuccess(List.unmodifiable(_sessions)),
  );

  @override
  Stream<UiState<List<TrainingSession>>> watchSessions(String coachId) =>
      _stream();

  @override
  Future<void> createSession(String coachId, SessionInput input) async {
    final id =
        (_sessions
            .map((session) => session.id)
            .fold<int>(0, (a, b) => a > b ? a : b)) +
        1;
    _sessions.add(TrainingSession.created(id, input));
    _emit();
  }

  @override
  Future<void> updateSession(String id, SessionInput input) async {
    final index = _sessions.indexWhere((session) => session.documentId == id);
    if (index >= 0) _sessions[index] = _sessions[index].updatedFrom(input);
    _emit();
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((session) => session.documentId == id);
    _emit();
  }
}

class _FakeMembersRepository implements MembersRepository {
  _FakeMembersRepository(this._sessions);

  final _FakeSessionsRepository _sessions;

  @override
  Stream<UiState<List<Member>>> watchMembers(String coachId) => Stream.value(
    const UiSuccess([
      Member(
        id: 'preview-1',
        initials: 'AT',
        name: 'Adhérent de test',
        email: 'adherent@example.com',
        phone: '0600000001',
        goal: '',
        sessionsCount: 3,
        avatarColor: Color(0xFFA78BFA),
      ),
      Member(
        id: 'preview-2',
        initials: 'AT',
        name: 'Adhérent de test 2',
        email: '',
        phone: '',
        goal: '',
        sessionsCount: 2,
        avatarColor: Color(0xFFB8F23C),
      ),
      Member(
        id: 'preview-3',
        initials: 'AT',
        name: 'Adhérent de test 3',
        email: '',
        phone: '',
        goal: '',
        sessionsCount: 1,
        avatarColor: Color(0xFFE8906A),
      ),
      Member(
        id: 'preview-4',
        initials: 'AT',
        name: 'Adhérent de test 4',
        email: '',
        phone: '',
        goal: '',
        sessionsCount: 0,
        avatarColor: Color(0xFF6FA3D8),
      ),
    ]),
  );

  @override
  Stream<UiState<List<TrainingSession>>> watchMemberSessions(
    String coachId,
    String memberId,
  ) => _sessions.watchSessions(coachId).map((state) {
    switch (state) {
      case UiSuccess<List<TrainingSession>>(:final value):
        final sessions =
            value
                .where((session) => session.enrolledIds.contains(memberId))
                .toList()
              ..sort((first, second) => second.date.compareTo(first.date));
        return sessions.isEmpty
            ? const UiEmpty()
            : UiSuccess(List.unmodifiable(sessions));
      case UiEmpty<List<TrainingSession>>():
        return const UiEmpty();
      case UiError<List<TrainingSession>>(:final error):
        return UiError(error);
      case UiLoading<List<TrainingSession>>():
        return const UiLoading();
    }
  });
}
