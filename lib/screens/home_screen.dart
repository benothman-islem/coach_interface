import 'dart:async';

import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ui_state_view.dart';
import '../viewmodels/screen_viewmodels.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.viewModel,
    required this.onItemSelected,
    super.key,
  });

  final HomeViewModel viewModel;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Column(
      children: [
        Expanded(
          child: UiStateView<HomeDashboard>(
            state: viewModel.state,
            onRetry: viewModel.retry,
            emptyMessage: 'Profil introuvable.',
            onSuccess: (dashboard) => ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                _HomeHeader(
                  name: dashboard.profile.toCoachProfile().name,
                  onNotificationsClick: () {},
                ),
                const SizedBox(height: 24),
                _CoachCard(profile: dashboard.profile.toCoachProfile()),
                const SizedBox(height: 24),
                const SectionHeading(
                  title: 'Vue d’ensemble',
                  trailing: 'Cette semaine',
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '${dashboard.weekSessionCount}',
                        label: 'Séances',
                        caption:
                            '${dashboard.weekSessionCount - dashboard.previousWeekSessionCount >= 0 ? '+' : ''}${dashboard.weekSessionCount - dashboard.previousWeekSessionCount} cette semaine',
                        icon: Icons.calendar_month_outlined,
                        iconTint: AppColors.lime,
                        iconBackground: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '${dashboard.weekParticipants}',
                        label: 'Participants',
                        caption: '—% de présence',
                        icon: Icons.groups_outlined,
                        iconTint: AppColors.purple,
                        iconBackground: AppColors.purpleTint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeading(
                  title: 'Prochaine séance',
                  trailing: 'Voir tout',
                  onTrailingTap: () => onItemSelected(1),
                ),
                const SizedBox(height: 14),
                _NextSessionCard(session: dashboard.nextSession),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Créer une séance',
                  onPressed: () => onItemSelected(1),
                ),
              ],
            ),
          ),
        ),
        BottomNavBar(selectedIndex: 0, onItemSelected: onItemSelected),
      ],
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name, required this.onNotificationsClick});

  final String name;
  final VoidCallback onNotificationsClick;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('BON RETOUR, COACH'),
            SizedBox(height: 3),
            Text(
              'Salut, $name',
              style: AppText.screenTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      NotificationButton(onPressed: onNotificationsClick),
    ],
  );
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.profile});

  final CoachProfile profile;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
      gradient: const LinearGradient(
        colors: [Color(0xFF1B2116), AppColors.card, Color(0xFF151912)],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          left: -20,
          top: -50,
          child: Container(
            width: 190,
            height: 190,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x333DAA32), Colors.transparent],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.purple, AppColors.purpleDark],
                  ),
                ),
                child: Text(profile.initials, style: AppText.avatarInitials),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('ESPACE COACH'),
                    SizedBox(height: 3),
                    Text(
                      profile.name,
                      style: AppText.coachName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      profile.specialties.join(' · '),
                      style: AppText.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkGreen,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.lime,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.caption,
    required this.icon,
    required this.iconTint,
    required this.iconBackground,
  });

  final String value;
  final String label;
  final String caption;
  final IconData icon;
  final Color iconTint;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) => OutlinedCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 21, color: iconTint),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppText.statNumber),
        const SizedBox(height: 7),
        Text(label, style: AppText.statLabel),
        const SizedBox(height: 7),
        Text(
          caption,
          style: AppText.caption.copyWith(color: AppColors.lime),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _NextSessionCard extends StatefulWidget {
  const _NextSessionCard({required this.session});

  final TrainingSession? session;

  @override
  State<_NextSessionCard> createState() => _NextSessionCardState();
}

class _NextSessionCardState extends State<_NextSessionCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OutlinedCard(
    padding: const EdgeInsets.all(14),
    child: widget.session == null
        ? const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Aucune séance à venir',
              style: TextStyle(color: AppColors.muted),
            ),
          )
        : _buildSession(widget.session!),
  );

  Widget _buildSession(TrainingSession session) => Row(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdayAbbreviation(session.date.weekday),
              style: AppText.dateDay,
              textAlign: TextAlign.center,
            ),
            Text(
              '${session.date.day}',
              style: AppText.dateNumber,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(_countdown(session.date)),
            SizedBox(height: 3),
            Text(
              session.title,
              style: AppText.sessionTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 3),
            Text(
              '${formatTime(session.time)} · ${session.durationMinutes} min · ${session.studio}',
              style: AppText.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 0),
                SizedBox(width: 8),
                Text(
                  '${session.enrolledCount} inscrits',
                  style: AppText.caption,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
      SizedBox(width: 8),
      SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.border),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.chevron_right, size: 24),
          tooltip: 'Détails de la séance',
        ),
      ),
    ],
  );

  String _countdown(DateTime date) {
    final minutes = date.difference(DateTime.now()).inMinutes;
    return 'DANS ${minutes < 0 ? 0 : minutes} MIN';
  }

  String _weekdayAbbreviation(int weekday) =>
      const ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'][weekday - 1];
}
