import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:salledesport/core/app_runtime.dart';
import 'package:salledesport/core/router/app_router.dart';
import 'package:salledesport/core/theme/app_colors.dart';
import 'package:salledesport/core/theme/app_theme.dart';
import 'package:salledesport/features/admin/controllers/auth_controller.dart';
import 'package:salledesport/features/admin/controllers/dashboard_controller.dart';
import 'package:salledesport/features/admin/controllers/management_controller.dart';
import 'package:salledesport/features/admin/controllers/member_controller.dart';
import 'package:salledesport/features/admin/controllers/notification_controller.dart';
import 'package:salledesport/features/admin/controllers/reservation_controller.dart';
import 'package:salledesport/features/admin/controllers/session_controller.dart';

const _useFakeRepositories = bool.fromEnvironment(
  'USE_FAKE_REPOSITORIES',
  defaultValue: false,
);

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
  runApp(const GymAdherentApp());
}

class GymAdherentApp extends StatefulWidget {
  const GymAdherentApp({this.useFakeRepositories, super.key});

  final bool? useFakeRepositories;

  @override
  State<GymAdherentApp> createState() => _GymAdherentAppState();
}

class _GymAdherentAppState extends State<GymAdherentApp> {
  late final AppRuntime _runtime = AppRuntime(
    useFakeRepositories: widget.useFakeRepositories ?? _useFakeRepositories,
  );
  late final AppRouter _appRouter = AppRouter.create();

  @override
  void initState() {
    super.initState();
    _runtime.initialize();
  }

  @override
  void dispose() {
    _appRouter.router.dispose();
    _runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AppRuntime>.value(value: _runtime),
      ChangeNotifierProvider(
        create: (context) =>
            AuthController(context.read<AppRuntime>().repositories!.auth),
      ),
      ChangeNotifierProvider(create: (_) => DashboardController()),
      ChangeNotifierProvider(create: (_) => MemberController()),
      ChangeNotifierProvider(create: (_) => SessionController()),
      ChangeNotifierProvider(create: (_) => ManagementController()),
      ChangeNotifierProvider(create: (_) => ReservationController()),
      ChangeNotifierProvider(create: (_) => NotificationController()),
    ],
    child: MaterialApp.router(
      title: 'salle de sport',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr')],
      theme: AppTheme.darkTheme,
      routerConfig: _appRouter.router,
    ),
  );
}
