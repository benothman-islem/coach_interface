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
}
