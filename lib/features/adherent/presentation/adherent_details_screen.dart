import 'package:flutter/material.dart';

import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/models/member.dart';
import 'package:salledesport/models/session.dart';
import 'package:salledesport/models/ui_state.dart';
import 'package:salledesport/core/theme/app_theme.dart';

class AdherentDetailsScreen extends StatelessWidget {
  const AdherentDetailsScreen({
    required this.member,
    required this.sessions,
    super.key,
  });

  final Member member;
  final Stream<UiState<List<TrainingSession>>> sessions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Détails adhérent'),
      backgroundColor: AppColors.background,
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: member.avatarColor,
          child: Text(
            member.initials.isEmpty ? 'A' : member.initials,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(member.name, style: AppText.screenTitle),
        if (member.phone.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(member.phone, style: const TextStyle(color: AppColors.muted)),
        ],
        if (member.email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(member.email, style: const TextStyle(color: AppColors.muted)),
        ],
        if (member.goal.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Objectif : ${member.goal}'),
        ],
        const SizedBox(height: 28),
        Text('Séances (${member.sessionsCount})', style: AppText.sectionTitle),
        const SizedBox(height: 12),
        StreamBuilder<UiState<List<TrainingSession>>>(
          stream: sessions,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'Impossible de charger l’historique des séances.',
                style: TextStyle(color: AppColors.muted),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.lime),
              );
            }
            final state = snapshot.data;
            if (state is UiError<List<TrainingSession>>) {
              return const Text(
                'Impossible de charger l’historique des séances.',
                style: TextStyle(color: AppColors.muted),
              );
            }
            if (state is! UiSuccess<List<TrainingSession>>) {
              return const Text(
                'Aucune séance pour le moment.',
                style: TextStyle(color: AppColors.muted),
              );
            }
            return Column(
              children: [
                for (final session in state.value)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.fitness_center,
                      color: AppColors.lime,
                    ),
                    title: Text(session.title),
                    subtitle: Text(
                      '${session.date.day.toString().padLeft(2, '0')}/'
                      '${session.date.month.toString().padLeft(2, '0')}/'
                      '${session.date.year} · ${formatTime(session.time)}'
                      '${session.studio.isEmpty ? '' : ' · ${session.studio}'}',
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
