import 'package:flutter/material.dart';

import '../data/repositories/repositories.dart';
import '../theme/app_theme.dart';
import 'adherent_coaches_screen.dart';

class AdherentHomeScreen extends StatelessWidget {
  const AdherentHomeScreen({
    required this.onLogout,
    required this.coachesRepository,
    super.key,
  });

  final Future<void> Function() onLogout;
  final CoachesRepository coachesRepository;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Espace adhérent'),
      actions: [
        IconButton(
          tooltip: 'Se déconnecter',
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, size: 52, color: AppColors.lime),
            const SizedBox(height: 16),
            const Text(
              'Bienvenue dans ton espace adhérent.',
              style: TextStyle(color: AppColors.text, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdherentCoachesScreen(
                      coachesRepository: coachesRepository,
                    ),
                  ),
                ),
                icon: const Icon(Icons.people_outline),
                label: const Text('Découvrir tous les coachs'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
