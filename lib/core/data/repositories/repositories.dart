import 'package:salledesport/models/member.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/ui_state.dart';
import 'package:salledesport/core/data/remote/dtos.dart';

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
}

abstract interface class MembersRepository {
  Stream<UiState<List<Member>>> watchMembers(String coachId);
  Stream<UiState<List<TrainingSession>>> watchMemberSessions(
    String coachId,
    String memberId,
  );
}

class AppRepositories {
  const AppRepositories({
    required this.profiles,
    required this.sessions,
    required this.members,
  });

  final ProfileRepository profiles;
  final SessionsRepository sessions;
  final MembersRepository members;
}
