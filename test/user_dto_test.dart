import 'package:flutter_test/flutter_test.dart';
import 'package:salledesport/core/data/remote/dtos.dart';

void main() {
  test('maps coach profile fields from Firestore data', () {
    final profile = UserDto.fromMap({
      'name': 'Coach de test',
      'email': 'coach@example.com',
      'phone': '0600000000',
      'photoUrl': 'https://example.com/coach.jpg',
      'role': 'coach',
      'createdAt': DateTime(2023, 1, 2),
      'specialties': ['HIIT', 'Mobilité'],
      'coachSince': DateTime(2023, 2, 1),
      'rating': 4.75,
      'experienceYears': 6,
      'isActive': true,
    }).toCoachProfile(id: 'coach-123');

    expect(profile.id, 'coach-123');
    expect(profile.name, 'Coach de test');
    expect(profile.email, 'coach@example.com');
    expect(profile.phone, '0600000000');
    expect(profile.photoUrl, 'https://example.com/coach.jpg');
    expect(profile.initials, 'CD');
    expect(profile.memberSince, 'Coach depuis Mercredi 1 février');
    expect(profile.specialties, ['HIIT', 'Mobilité']);
    expect(profile.experienceYears, 6);
    expect(profile.rating, '4.8 / 5');
    expect(profile.isActive, isTrue);
  });

  test('does not invent optional profile values', () {
    final profile = UserDto.fromMap({
      'name': 'Coach de test',
      'email': 'coach@example.com',
      'role': 'coach',
    }).toCoachProfile();

    expect(profile.memberSince, '—');
    expect(profile.specialties, isEmpty);
    expect(profile.experienceYears, isNull);
    expect(profile.rating, '—');
    expect(profile.isActive, isFalse);
  });
}
