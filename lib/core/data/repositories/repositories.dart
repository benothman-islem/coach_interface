import 'dart:async';

import 'package:salledesport/models/member.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/ui_state.dart';
import 'package:salledesport/models/user_profile.dart';
import 'package:salledesport/models/app_user.dart';
import 'package:salledesport/core/data/remote/dtos.dart';

abstract interface class AuthRepository {
  Future<AppUser?> restoreSession();
  Future<AppUser> signIn(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<AppUser> registerCoach({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> signOut();
}

abstract interface class ProfileRepository {
  Stream<UiState<UserDto>> watchProfile(String uid);
  Future<void> updateProfile(
    String uid, {
    required String name,
    required String phone,
  });
}

abstract interface class SessionsRepository {
  Stream<UiState<List<TrainingSession>>> watchSessions(String coachId);
  Future<void> createSession(String coachId, SessionInput input);
  Future<void> updateSession(String id, SessionInput input);
  Future<void> deleteSession(String id);
  Future<void> toggleEnrollment(String id, String memberUid, bool enrolled);
}

abstract interface class MembersRepository {
  Stream<UiState<List<Member>>> watchMembers(String coachId);
  Stream<UiState<List<TrainingSession>>> watchMemberSessions(
    String coachId,
    String memberId,
  );
}

abstract interface class CoachesRepository {
  // Returns every coach profile, independent of any session enrollment.
  Future<List<CoachProfile>> getAllCoaches();
}

class AppRepositories {
  const AppRepositories({
    required this.auth,
    required this.profiles,
    required this.sessions,
    required this.members,
    required this.coaches,
  });

  final AuthRepository auth;
  final ProfileRepository profiles;
  final SessionsRepository sessions;
  final MembersRepository members;
  final CoachesRepository coaches;
}

abstract interface class DebugSessionSeeder {
  Future<void> seedSessionsOnce(String coachId);
}

Stream<UiState<T>> asUiState<T, S>(
  Stream<S> source,
  FutureOr<UiState<T>> Function(S value) convert,
) => source.transform(
  StreamTransformer<S, UiState<T>>.fromHandlers(
    handleData: (value, sink) {
      Future<UiState<T>>.sync(() => convert(value)).then(
        sink.add,
        onError: (Object error, StackTrace stackTrace) {
          sink.add(UiError<T>(error));
        },
      );
    },
    handleError: (error, stackTrace, sink) {
      sink.add(UiError<T>(error));
    },
  ),
);
