import 'package:flutter/material.dart';

import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const _items = [
    (label: 'Accueil', icon: Icons.home_outlined),
    (label: 'Séances', icon: Icons.calendar_month_outlined),
    (label: 'Adhérents', icon: Icons.groups_outlined),
    (label: 'Profil', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.card,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _NavItem(
                  label: _items[index].label,
                  icon: _items[index].icon,
                  selected: index == selectedIndex,
                  onTap: () => onItemSelected(index),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.darkGreen : Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected ? AppColors.lime : AppColors.muted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppText.navLabel.copyWith(
                color: selected ? AppColors.lime : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    height: 48,
    child: Stack(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.border),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.notifications_none, size: 24),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.lime,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
          ),
        ),
      ],
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({required this.text, required this.onPressed, super.key});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.background,
        shape: const StadiumBorder(),
        padding: EdgeInsets.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, size: 21),
          const SizedBox(width: 8),
          Text(text, style: AppText.button),
        ],
      ),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color = AppColors.lime, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppText.eyebrow,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    required this.trailing,
    this.onTrailingTap,
    super.key,
  });

  final String title;
  final String trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: AppText.sectionTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onTrailingTap,
        child: Text(
          trailing,
          style: AppText.trailingLabel.copyWith(color: AppColors.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class OutlinedCard extends StatelessWidget {
  const OutlinedCard({
    required this.child,
    this.padding,
    this.radius = 24,
    this.color = AppColors.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    ),
    padding: padding,
    child: child,
  );
}
