import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({
    required this.user,
    required this.requiredRole,
    required this.onLogout,
    required this.child,
    super.key,
  });

  final AppUser user;
  final UserRole requiredRole;
  final Future<void> Function() onLogout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // This is a UI guard; Firestore Rules still enforce data authorization.
    if (user.role == requiredRole) return child;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Accès refusé',
                  style: AppText.sectionTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ton rôle ne permet pas d’ouvrir cet espace.',
                  style: TextStyle(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PrimaryButton(text: 'Se déconnecter', onPressed: onLogout),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
