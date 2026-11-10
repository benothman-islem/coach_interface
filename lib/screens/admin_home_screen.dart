import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({required this.onLogout, super.key});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Espace administrateur'),
      actions: [
        IconButton(
          tooltip: 'Se déconnecter',
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: const Center(
      child: Text(
        'Bienvenue dans l’espace administrateur.',
        style: TextStyle(color: AppColors.text, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
