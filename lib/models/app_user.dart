<<<<<<< HEAD
enum UserRole {
  admin,
  adherent,
  coach;

  // Keep the existing Firestore "member" role compatible with the new name.
  static UserRole? fromString(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'admin' => UserRole.admin,
        'adherent' || 'member' => UserRole.adherent,
        'coach' => UserRole.coach,
        _ => null,
      };
}

class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.role,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final UserRole? role;
}

class UnknownUserRoleException implements Exception {
  const UnknownUserRoleException();
=======
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' | 'coach' | 'member'
  final bool isActive;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? 'Administrateur',
      email: map['email'] ?? 'admin@gym.tn',
      role: map['role'] ?? 'admin',
      isActive: map['isActive'] ?? true,
    );
  }
>>>>>>> admin/master
}
