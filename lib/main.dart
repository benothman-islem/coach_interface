import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:salledesport/core/data/repositories/fake_repositories.dart';
import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/core/theme/app_theme.dart';
import 'package:salledesport/features/coach/presentation/coach_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.card,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GymCoachApp());
}

class GymCoachApp extends StatelessWidget {
  const GymCoachApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Espace coach',
    debugShowCheckedModeBanner: false,
    locale: const Locale('fr'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('fr')],
    theme: AppTheme.darkTheme,
    home: CoachHomeScreen(repositories: FakeRepositories()),
  );
}
