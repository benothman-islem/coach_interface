import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:salledesport/core/data/remote/dtos.dart';
import 'package:salledesport/core/data/repositories/repositories.dart';
import 'package:salledesport/models/member.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/ui_state.dart';

class HomeDashboard {
  const HomeDashboard({required this.profile, required this.sessions});
  final UserDto profile;
  final List<TrainingSession> sessions;

  int get weekSessionCount {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    return sessions
        .where(
          (session) =>
              !session.date.isBefore(monday) &&
              session.date.isBefore(nextMonday),
        )
        .length;
  }

  int get weekParticipants {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    return sessions
        .where(
          (session) =>
              !session.date.isBefore(monday) &&
              session.date.isBefore(nextMonday),
        )
        .fold(0, (total, session) => total + session.enrolledCount);
  }

  int get previousWeekSessionCount {
    final now = DateTime.now();
    final thisMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final previousMonday = thisMonday.subtract(const Duration(days: 7));
    return sessions
        .where(
          (session) =>
              !session.date.isBefore(previousMonday) &&
              session.date.isBefore(thisMonday),
        )
        .length;
  }

  TrainingSession? get nextSession {
    final now = DateTime.now();
    final upcoming =
        sessions.where((session) => session.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }
}

abstract class WatchingViewModel<T> extends ChangeNotifier {
  WatchingViewModel(this._watch);

  final Stream<UiState<T>> Function() _watch;
  StreamSubscription<UiState<T>>? _subscription;
  UiState<T> state = const UiLoading();

  void start() {
    _subscription?.cancel();
    state = const UiLoading();
    notifyListeners();
    _subscription = _watch().listen(
      (value) {
        state = value;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Repository stream failed: $error\n$stackTrace');
        state = UiError(error);
        notifyListeners();
      },
    );
  }

  void retry() => start();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class SessionsViewModel extends WatchingViewModel<List<TrainingSession>> {
  SessionsViewModel(this._repository, this.coachId)
    : super(() => _repository.watchSessions(coachId)) {
    start();
  }

  final SessionsRepository _repository;
  final String coachId;

  Future<void> create(SessionInput input) =>
      _repository.createSession(coachId, input);

  Future<void> update(String id, SessionInput input) =>
      _repository.updateSession(id, input);

  Future<void> delete(String id) => _repository.deleteSession(id);
}

class MembersViewModel extends WatchingViewModel<List<Member>> {
  MembersViewModel(MembersRepository repository, String coachId)
    : _repository = repository,
      _coachId = coachId,
      super(() => repository.watchMembers(coachId)) {
    start();
  }

  final MembersRepository _repository;
  final String _coachId;

  Stream<UiState<List<TrainingSession>>> watchMemberSessions(String memberId) =>
      _repository.watchMemberSessions(_coachId, memberId);
}

class ProfileViewModel extends WatchingViewModel<UserDto> {
  ProfileViewModel(this._repository, this.uid)
    : super(() => _repository.watchProfile(uid)) {
    start();
  }

  final ProfileRepository _repository;
  final String uid;

  Future<void> update({required String name, required String phone}) =>
      _repository.updateProfile(uid, name: name, phone: phone);
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.profiles,
    required SessionsRepository sessions,
    required this.uid,
  }) : _sessionsRepository = sessions {
    _watch();
  }

  final ProfileRepository profiles;
  final SessionsRepository _sessionsRepository;
  final String uid;

  StreamSubscription<UiState<UserDto>>? _profileSubscription;
  StreamSubscription<UiState<List<TrainingSession>>>? _sessionsSubscription;
  UiState<HomeDashboard> state = const UiLoading();
  UserDto? _profile;
  List<TrainingSession>? _sessions;

  void _watch() {
    _profileSubscription = profiles
        .watchProfile(uid)
        .listen(
          (value) {
            switch (value) {
              case UiSuccess<UserDto>(:final value):
                _profile = value;
                _publish();
              case UiEmpty<UserDto>():
                state = const UiEmpty();
                notifyListeners();
              case UiError<UserDto>(:final error):
                state = UiError(error);
                notifyListeners();
              case UiLoading<UserDto>():
                state = const UiLoading();
                notifyListeners();
            }
          },
          onError: (Object error) {
            state = UiError(error);
            notifyListeners();
          },
        );
    _sessionsSubscription = _sessionsRepository
        .watchSessions(uid)
        .listen(
          (value) {
            switch (value) {
              case UiSuccess<List<TrainingSession>>(:final value):
                _sessions = value;
                _publish();
              case UiEmpty<List<TrainingSession>>():
                _sessions = [];
                _publish();
              case UiError<List<TrainingSession>>(:final error):
                state = UiError(error);
                notifyListeners();
              case UiLoading<List<TrainingSession>>():
                _sessions = null;
                state = const UiLoading();
                notifyListeners();
            }
          },
          onError: (Object error) {
            state = UiError(error);
            notifyListeners();
          },
        );
  }

  void _publish() {
    if (_profile != null && _sessions != null) {
      state = UiSuccess(
        HomeDashboard(profile: _profile!, sessions: _sessions!),
      );
      notifyListeners();
    }
  }

  void retry() {
    _profile = null;
    _sessions = null;
    state = const UiLoading();
    notifyListeners();
    _profileSubscription?.cancel();
    _sessionsSubscription?.cancel();
    _watch();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
