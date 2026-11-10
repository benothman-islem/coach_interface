import 'package:flutter_test/flutter_test.dart';
import 'package:salledesport/models/app_user.dart';

void main() {
  test('parses supported roles case-insensitively', () {
    expect(UserRole.fromString('admin'), UserRole.admin);
    expect(UserRole.fromString('adherent'), UserRole.adherent);
    expect(UserRole.fromString('member'), UserRole.adherent);
    expect(UserRole.fromString('coach'), UserRole.coach);
    expect(UserRole.fromString('  COACH '), UserRole.coach);
  });

  test('returns null for missing or unknown roles', () {
    expect(UserRole.fromString(null), isNull);
    expect(UserRole.fromString(''), isNull);
    expect(UserRole.fromString('guest'), isNull);
  });
}
