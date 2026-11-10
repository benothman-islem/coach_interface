class CoachProfile {
  const CoachProfile({
    this.id = '',
    required this.initials,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.memberSince,
    required this.isActive,
    required this.specialties,
    required this.experienceYears,
    required this.rating,
    this.photoUrl,
  });

  final String id;
  final String initials;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String memberSince;
  final bool isActive;
  final List<String> specialties;
  final int? experienceYears;
  final String rating;
  final String? photoUrl;
}
