import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/member.dart';
import '../../models/session.dart';
import '../../models/ui_state.dart';
import '../../models/app_user.dart';
import '../../models/user_profile.dart';
import '../remote/dtos.dart';
import 'repositories.dart';

class FirebaseRepositories extends AppRepositories {
  FirebaseRepositories(FirebaseAuth auth, FirebaseFirestore firestore)
    : super(
        auth: FirebaseAuthRepository(auth, firestore),
        profiles: FirestoreProfileRepository(firestore),
        sessions: FirestoreSessionsRepository(firestore),
        members: FirestoreMembersRepository(firestore),
        coaches: FirestoreCoachesRepository(firestore),
      );
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<AppUser?> restoreSession() async {
    // Firebase Authentication persists its current user between app launches.
    final user = _auth.currentUser;
    if (user == null) return null;
    await _ensureProfile(user);
    return _loadAppUser(user);
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase Authentication did not return a user.');
    }
    await _ensureProfile(user);
    return _loadAppUser(user);
  }

  @override
  Future<AppUser> registerCoach({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase Authentication did not return a user.');
    }
    try {
      await _ensureProfile(user, name: name, phone: phone);
      return await _loadAppUser(user);
    } catch (error, stackTrace) {
      await user.delete();
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<AppUser> _loadAppUser(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final storedRole = snapshot.data()?['role'];
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      role: UserRole.fromString(storedRole is String ? storedRole : null),
    );
  }

  Future<void> _ensureProfile(User user, {String? name, String? phone}) async {
    final profile = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(profile);
      if (snapshot.exists) return;
      final email = user.email ?? '';
      final displayName = user.displayName?.trim();
      final inferredName = displayName != null && displayName.isNotEmpty
          ? displayName
          : email.split('@').first;
      transaction.set(profile, {
        'name': name?.trim().isNotEmpty == true ? name!.trim() : inferredName,
        'email': email,
        'phone': phone?.trim() ?? user.phoneNumber ?? '',
        'role': 'coach',
        'createdAt': FieldValue.serverTimestamp(),
        'specialties': <String>[],
        'isActive': true,
        'experienceYears': 0,
      });
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UiState<UserDto>> watchProfile(String uid) => asUiState(
    _firestore.collection('users').doc(uid).snapshots(),
    (snapshot) => snapshot.exists
        ? UiSuccess(UserDto.fromMap(snapshot.data()))
        : const UiEmpty(),
  );

  @override
  Future<void> updateProfile(
    String uid, {
    required String name,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
    });
  }
}

class FirestoreCoachesRepository implements CoachesRepository {
  FirestoreCoachesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<CoachProfile>> getAllCoaches() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get();
    final coaches = snapshot.docs
        .map(
          (document) =>
              UserDto.fromMap(document.data()).toCoachProfile(id: document.id),
        )
        .toList();
    coaches.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
    return coaches;
  }
}

class FirestoreSessionsRepository implements SessionsRepository {
  FirestoreSessionsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('sessions');

  @override
  Stream<UiState<List<TrainingSession>>> watchSessions(String coachId) =>
      asUiState(
        _collection
            .where('coachId', isEqualTo: coachId)
            .orderBy('startAt')
            .limit(100)
            .snapshots(),
        (snapshot) {
          final sessions = snapshot.docs
              .map((doc) => SessionDto.fromMap(doc.data()).toModel(doc.id))
              .toList(growable: false);
          return sessions.isEmpty ? const UiEmpty() : UiSuccess(sessions);
        },
      );

  @override
  Future<void> createSession(String coachId, SessionInput input) async {
    final startAt = DateTime(
      input.date.year,
      input.date.month,
      input.date.day,
      input.time.hour,
      input.time.minute,
    );
    await _collection.add({
      'coachId': coachId,
      'type': input.type.firestoreValue,
      'title': input.type.label,
      'studio': input.studio.trim(),
      'startAt': Timestamp.fromDate(startAt),
      'durationMin': 45,
      'capacity': input.capacity,
      'enrolledIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateSession(String id, SessionInput input) async {
    final startAt = DateTime(
      input.date.year,
      input.date.month,
      input.date.day,
      input.time.hour,
      input.time.minute,
    );
    await _collection.doc(id).update({
      'type': input.type.firestoreValue,
      'title': input.type.label,
      'studio': input.studio.trim(),
      'startAt': Timestamp.fromDate(startAt),
      'capacity': input.capacity,
    });
  }

  @override
  Future<void> deleteSession(String id) => _collection.doc(id).delete();

  @override
  Future<void> toggleEnrollment(
    String id,
    String memberUid,
    bool enrolled,
  ) async {
    await _collection.doc(id).update({
      'enrolledIds': enrolled
          ? FieldValue.arrayUnion([memberUid])
          : FieldValue.arrayRemove([memberUid]),
    });
  }
}

class FirestoreMembersRepository implements MembersRepository {
  FirestoreMembersRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UiState<List<Member>>> watchMembers(String coachId) =>
      Stream.multi((controller) {
        QuerySnapshot<Map<String, dynamic>>? memberSnapshot;
        QuerySnapshot<Map<String, dynamic>>? sessionSnapshot;

        void publish() {
          if (memberSnapshot == null || sessionSnapshot == null) return;
          if (memberSnapshot!.docs.isEmpty) {
            controller.add(const UiEmpty());
            return;
          }
          final enrollments = <String, int>{};
          for (final session in sessionSnapshot!.docs) {
            final ids =
                (session.data()['enrolledIds'] as List<dynamic>?)
                    ?.whereType<String>() ??
                const <String>[];
            for (final uid in ids) {
              enrollments.update(
                uid,
                (sessionCount) => sessionCount + 1,
                ifAbsent: () => 1,
              );
            }
          }
          final members = memberSnapshot!.docs
              .map(
                (doc) => Member.fromFirestore(
                  doc,
                  sessionsCount: enrollments[doc.id] ?? 0,
                ),
              )
              .toList(growable: false);
          controller.add(UiSuccess(members));
        }

        final memberSubscription = _firestore
            .collection('users')
            .where('role', isEqualTo: 'member')
            .snapshots()
            .listen((snapshot) {
              memberSnapshot = snapshot;
              publish();
            }, onError: controller.addError);
        final sessionSubscription = _firestore
            .collection('sessions')
            .where('coachId', isEqualTo: coachId)
            .snapshots()
            .listen((snapshot) {
              sessionSnapshot = snapshot;
              publish();
            }, onError: controller.addError);
        controller.onCancel = () async {
          await memberSubscription.cancel();
          await sessionSubscription.cancel();
        };
      });

  @override
  Stream<UiState<List<TrainingSession>>> watchMemberSessions(
    String coachId,
    String memberId,
  ) => asUiState(
    _firestore
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .snapshots(),
    (snapshot) {
      final sessions =
          snapshot.docs
              .where((doc) {
                final ids = doc.data()['enrolledIds'];
                return ids is List && ids.contains(memberId);
              })
              .map((doc) => SessionDto.fromMap(doc.data()).toModel(doc.id))
              .toList()
            ..sort((first, second) => second.date.compareTo(first.date));
      return sessions.isEmpty
          ? const UiEmpty()
          : UiSuccess(List.unmodifiable(sessions));
    },
  );
}

class FirebaseDebugSessionSeeder implements DebugSessionSeeder {
  FirebaseDebugSessionSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> seedSessionsOnce(String coachId) async {
    final collection = _firestore.collection('sessions');
    final examples = <String, Map<String, Object>>{
      'debug_${coachId}_yoga_flow': {
        'coachId': coachId,
        'type': 'Mobilité',
        'title': 'Yoga Flow',
        'studio': 'Studio B',
        'startAt': Timestamp.fromDate(_nextWeekday(1, 9)),
        'durationMin': 60,
        'capacity': 12,
        'enrolledIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      },
      'debug_${coachId}_cross_training': {
        'coachId': coachId,
        'type': 'Cross',
        'title': 'Cross Training',
        'studio': 'Studio A',
        'startAt': Timestamp.fromDate(_nextWeekday(2, 11)),
        'durationMin': 45,
        'capacity': 16,
        'enrolledIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      },
      'debug_${coachId}_hiit': {
        'coachId': coachId,
        'type': 'HIIT',
        'title': 'HIIT Training',
        'studio': 'Studio A',
        'startAt': Timestamp.fromDate(_nextWeekday(3, 18)),
        'durationMin': 45,
        'capacity': 12,
        'enrolledIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      },
    };

    final refs = examples.keys.map(collection.doc).toList(growable: false);
    final snapshots = await Future.wait(refs.map((ref) => ref.get()));
    final batch = _firestore.batch();
    var pending = false;
    for (var index = 0; index < refs.length; index++) {
      if (snapshots[index].exists) continue;
      batch.set(refs[index], examples.values.elementAt(index));
      pending = true;
    }
    if (pending) await batch.commit();
  }

  static DateTime _nextWeekday(int weekday, int hour) {
    final now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day);
    while (date.weekday != weekday || date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }
    return DateTime(date.year, date.month, date.day, hour);
  }
}
