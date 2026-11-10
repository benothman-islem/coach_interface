import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/coach_avatar.dart';

class CoachDetailsScreen extends StatelessWidget {
  const CoachDetailsScreen({required this.coach, super.key});

  final CoachProfile coach;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Profil du coach')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: CoachAvatar(coach: coach, size: 116)),
          const SizedBox(height: 20),
          Text(
            coach.name,
            style: AppText.screenTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            coach.specialties.isEmpty
                ? 'Spécialité non renseignée'
                : coach.specialties.join(' · '),
            style: const TextStyle(color: AppColors.lime, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          OutlinedCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _CoachInfoRow(label: 'E-mail', value: coach.email),
                _CoachInfoRow(label: 'Téléphone', value: coach.phone),
                _CoachInfoRow(
                  label: 'Expérience',
                  value: coach.experienceYears == null
                      ? 'Non renseignée'
                      : '${coach.experienceYears} ans',
                ),
                _CoachInfoRow(label: 'Note', value: coach.rating),
                _CoachInfoRow(label: 'Membre depuis', value: coach.memberSince),
                _CoachInfoRow(
                  label: 'Disponibilité',
                  value: coach.isActive ? 'Actif' : 'Inactif',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La réservation sera disponible prochainement.'),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lime,
              foregroundColor: AppColors.background,
              minimumSize: const Size.fromHeight(54),
            ),
            child: const Text('Réserver une séance'),
          ),
        ],
      ),
    ),
  );
}

class _CoachInfoRow extends StatelessWidget {
  const _CoachInfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
