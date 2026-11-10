import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class CoachAvatar extends StatelessWidget {
  const CoachAvatar({required this.coach, required this.size, super.key});

  final CoachProfile coach;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photoUrl = coach.photoUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.darkGreen,
      child: photoUrl == null || photoUrl.isEmpty
          ? _initials
          : ClipOval(
              child: Image.network(
                photoUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initials,
              ),
            ),
    );
  }

  Widget get _initials => Text(coach.initials, style: AppText.avatarInitials);
}
