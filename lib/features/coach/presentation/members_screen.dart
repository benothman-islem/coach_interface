import 'package:flutter/material.dart';

import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/models/member.dart';
import 'package:salledesport/core/theme/app_theme.dart';
import 'package:salledesport/core/widgets/app_widgets.dart';
import 'package:salledesport/core/widgets/ui_state_view.dart';
import 'package:salledesport/features/coach/viewmodels/screen_viewmodels.dart';

import 'member_details_screen.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({
    required this.viewModel,
    required this.onItemSelected,
    super.key,
  });

  final MembersViewModel viewModel;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Column(
      children: [
        Expanded(
          child: UiStateView<List<Member>>(
            state: viewModel.state,
            onRetry: viewModel.retry,
            emptyMessage: 'Aucun adhérent pour le moment',
            onSuccess: (members) => ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              children: [
                const _MembersHeader(),
                const SizedBox(height: 20),
                // TODO: Show the average when Firestore attendance data exists.
                StatsCard(memberCount: members.length, attendance: '—'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tous les adhérents',
                        style: AppText.sectionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${members.length} au total',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: OutlinedCard(
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < members.length;
                          index++
                        ) ...[
                          AdherentTile(
                            member: members[index],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MemberDetailsScreen(
                                  member: members[index],
                                  sessions: viewModel.watchMemberSessions(
                                    members[index].id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (index < members.length - 1)
                            const Divider(height: 1, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        BottomNavBar(selectedIndex: 2, onItemSelected: onItemSelected),
      ],
    ),
  );
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('TON ÉQUIPE'),
            SizedBox(height: 3),
            Text('Mes adhérents', style: AppText.screenTitle),
            SizedBox(height: 3),
            Text(
              'Suis leur progression et leurs programmes.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
      NotificationButton(onPressed: () {}),
    ],
  );
}

class StatsCard extends StatelessWidget {
  const StatsCard({
    required this.memberCount,
    required this.attendance,
    super.key,
  });

  final int memberCount;
  final String attendance;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
      gradient: const LinearGradient(
        colors: [Color(0xFF1A2014), AppColors.card],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              value: '$memberCount',
              label: 'Adhérents suivis',
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: _SummaryStat(value: attendance, label: 'Présence moyenne'),
          ),
        ],
      ),
    ),
  );
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: AppText.statNumber.copyWith(fontSize: 36, height: 38 / 36),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: AppText.caption.copyWith(fontSize: 12, color: AppColors.muted),
      ),
    ],
  );
}

class AdherentTile extends StatelessWidget {
  const AdherentTile({required this.member, required this.onTap, super.key});

  final Member member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          InitialsAvatar(member: member),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppText.trailingLabel.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.phone.trim().isEmpty ? 'Adhérent' : member.phone.trim()} · ${member.sessionsCount} séances',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
        ],
      ),
    ),
  );
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({required this.member, super.key});

  final Member member;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: member.avatarColor,
      shape: BoxShape.circle,
    ),
    child: Text(
      member.initials.isEmpty ? 'A' : member.initials,
      style: AppText.avatarInitials.copyWith(
        fontSize: 14,
        color: AppColors.background,
      ),
    ),
  );
}
