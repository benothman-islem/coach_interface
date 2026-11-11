import 'package:flutter/material.dart';

import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/core/data/remote/dtos.dart';
import 'package:salledesport/models/user_profile.dart';
import 'package:salledesport/core/theme/app_theme.dart';
import 'package:salledesport/core/widgets/app_widgets.dart';
import 'package:salledesport/core/widgets/ui_state_view.dart';
import 'package:salledesport/features/coach/viewmodels/screen_viewmodels.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.viewModel,
    required this.onItemSelected,
    super.key,
  });

  final ProfileViewModel viewModel;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Column(
      children: [
        Expanded(
          child: UiStateView<UserDto>(
            state: viewModel.state,
            onRetry: viewModel.retry,
            emptyMessage: 'Profil introuvable.',
            onSuccess: (dto) => _profileContent(context, dto.toCoachProfile()),
          ),
        ),
        BottomNavBar(selectedIndex: 3, onItemSelected: onItemSelected),
      ],
    ),
  );

  Widget _profileContent(BuildContext context, CoachProfile profile) =>
      ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 16),
            child: _ProfileHeader(),
          ),
          _ProfileCard(profile: profile),
          const SizedBox(height: 16),
          _SpecialtiesCard(profile: profile),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Mon compte', style: AppText.sectionTitle),
          ),
          const SizedBox(height: 16),
          OutlinedCard(
            child: Column(
              children: [
                _MenuRow(
                  label: 'Informations personnelles',
                  icon: Icons.person_outline,
                  onTap: () => _editProfile(context, profile),
                ),
                const Divider(height: 1, color: AppColors.border),
                const _MenuRow(
                  label: 'Mes disponibilités',
                  icon: Icons.calendar_month_outlined,
                ),
                const Divider(height: 1, color: AppColors.border),
                const _MenuRow(
                  label: 'Paramètres',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      );

  Future<void> _editProfile(BuildContext context, CoachProfile profile) async {
    try {
      final result = await showDialog<(String, String)>(
        context: context,
        builder: (context) => _ProfileEditDialog(profile: profile),
      );
      if (result != null && context.mounted) {
        await viewModel.update(name: result.$1, phone: result.$2);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de modifier le profil.')),
        );
      }
    }
  }
}

class _ProfileEditDialog extends StatefulWidget {
  const _ProfileEditDialog({required this.profile});

  final CoachProfile profile;

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.profile.phone,
  );

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.sheet,
    title: const Text('Informations personnelles'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Adresse e-mail'),
          child: Text(widget.profile.email),
        ),
        InputDecorator(
          decoration: const InputDecoration(labelText: 'Rôle'),
          child: Text(widget.profile.role),
        ),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Téléphone'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, (_name.text, _phone.text)),
        child: const Text('Enregistrer'),
      ),
    ],
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('ESPACE COACH'),
              SizedBox(height: 3),
              Text(
                'Mon profil',
                style: AppText.screenTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      NotificationButton(onPressed: () {}),
    ],
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final CoachProfile profile;

  @override
  Widget build(BuildContext context) => OutlinedCard(
    padding: const EdgeInsets.all(20),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              _ProfileAvatar(initials: profile.initials),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: AppText.coachName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.memberSince,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (profile.isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.selectedDay,
                border: Border.all(
                  color: AppColors.lime.withValues(alpha: 0.35),
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.lime),
                  SizedBox(width: 5),
                  Text(
                    'ACTIF',
                    style: TextStyle(
                      color: AppColors.lime,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 72,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [AppColors.purple, AppColors.purpleDark],
      ),
    ),
    child: Text(
      initials,
      style: AppText.avatarInitials.copyWith(
        fontSize: 24,
        color: AppColors.background,
      ),
    ),
  );
}

class _SpecialtiesCard extends StatelessWidget {
  const _SpecialtiesCard({required this.profile});

  final CoachProfile profile;

  @override
  Widget build(BuildContext context) => OutlinedCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('SPÉCIALITÉS'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final specialty in profile.specialties)
              _SpecialtyChip(label: specialty),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, color: AppColors.border),
        ),
        Row(
          children: [
            Expanded(
              child: _ProfileStat(
                label: 'EXPÉRIENCE',
                value: profile.experienceYears == null
                    ? '—'
                    : '${profile.experienceYears} ans',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileStat(label: 'NOTE MOYENNE', value: profile.rating),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.specialtyChip,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      label,
      style: AppText.caption.copyWith(fontSize: 11, color: AppColors.text),
      maxLines: 1,
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppText.eyebrow.copyWith(
          fontSize: 10,
          letterSpacing: 0.7,
          color: AppColors.muted,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: AppText.trailingLabel.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.selectedDay,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: AppColors.lime),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppText.trailingLabel.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
