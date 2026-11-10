<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/repositories/fake_repositories.dart';
import 'data/repositories/firebase_repositories.dart';
import 'data/repositories/repositories.dart';
import 'models/app_user.dart';
import 'screens/adherent_home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/coach_home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';
import 'widgets/role_guard.dart';

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

class GymAdherentApp extends StatelessWidget {
  const GymAdherentApp({this.useFakeRepositories, super.key});

  final bool? useFakeRepositories;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'salle de sport',
    debugShowCheckedModeBanner: false,
    locale: const Locale('fr'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('fr')],
    theme: buildAppTheme(),
    home: _AppBootstrap(
      useFakeRepositories: useFakeRepositories ?? _useFakeRepositories,
    ),
  );
}

class _Runtime {
  const _Runtime({required this.repositories, this.error});

  final AppRepositories? repositories;
  final Object? error;
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap({required this.useFakeRepositories});

  final bool useFakeRepositories;

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late Future<_Runtime> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<_Runtime> _initialize() async {
    if (widget.useFakeRepositories) {
      return _Runtime(repositories: FakeRepositories());
    }
    try {
      await Firebase.initializeApp();
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(persistenceEnabled: true);
      return _Runtime(
        repositories: FirebaseRepositories(FirebaseAuth.instance, firestore),
      );
    } catch (error) {
      return _Runtime(repositories: null, error: error);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Runtime>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const _LoadingScreen();
      }
      final runtime = snapshot.data;
      if (runtime == null || runtime.repositories == null) {
        return _FirebaseSetupScreen(
          onRetry: () => setState(() => _initialization = _initialize()),
        );
      }
      return _AuthGate(runtime: runtime);
    },
  );
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.runtime});

  final _Runtime runtime;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late Future<AppUser?> _restoredSession;
  String? _authNotice;

  @override
  void initState() {
    super.initState();
    _restoredSession = _restoreSession();
  }

  Future<AppUser?> _restoreSession() async {
    final auth = widget.runtime.repositories!.auth;
    final user = await auth.restoreSession();
    if (user != null && user.role == null) {
      await auth.signOut();
      _authNotice = 'Aucun rôle valide n’est associé à ce compte. Contacte un administrateur.';
      return null;
    }
    return user;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppUser?>(
    future: _restoredSession,
    builder: (context, snapshot) {
      final repositories = widget.runtime.repositories!;
      if (snapshot.hasError) {
        return _MessageScreen(
          title: 'Impossible de restaurer ta session.',
          message: 'Vérifie ta connexion internet puis réessaie.',
          action: 'Réessayer',
          onPressed: () => setState(() => _restoredSession = _restoreSession()),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const _LoadingScreen();
      }
      final user = snapshot.data;
      if (user == null) {
        return _buildAuthScreen(context, repositories, _authNotice);
      }
      final role = user.role;
      if (role == null) {
        return _buildAuthScreen(
          context,
          repositories,
          'Aucun rôle valide n’est associé à ce compte.',
        );
      }
      return _screenForRole(context, role, user, repositories);
    },
  );
}

AuthScreen _buildAuthScreen(
  BuildContext context,
  AppRepositories repositories,
  String? notice,
) => AuthScreen(
  onSignIn: repositories.auth.signIn,
  onRegister: repositories.auth.registerCoach,
  notice: notice,
  onAuthenticated: (context, user) async {
    final role = user.role;
    if (role == null) {
      await repositories.auth.signOut();
      throw const UnknownUserRoleException();
    }
    navigateByRole(context, role, user: user, repositories: repositories);
  },
);

void navigateByRole(
  BuildContext context,
  UserRole role, {
  required AppUser user,
  required AppRepositories repositories,
}) {
  if (user.role != role) throw const UnknownUserRoleException();
  // Replacing the login route prevents returning to it with the Back button.
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (context) => _screenForRole(context, role, user, repositories),
    ),
  );
}

Widget _screenForRole(
  BuildContext context,
  UserRole role,
  AppUser user,
  AppRepositories repositories,
) {
  Future<void> logout() async {
    await repositories.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (loginContext) =>
            _buildAuthScreen(loginContext, repositories, null),
      ),
      (_) => false,
    );
  }

  final screen = switch (role) {
    UserRole.admin => AdminHomeScreen(onLogout: logout),
    UserRole.adherent => AdherentHomeScreen(
      onLogout: logout,
      coachesRepository: repositories.coaches,
    ),
    UserRole.coach => CoachHomeScreen(
      repositories: repositories,
      user: user,
      onLogout: logout,
    ),
  };
  return RoleGuard(
    user: user,
    requiredRole: role,
    onLogout: logout,
    child: screen,
  );
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: CircularProgressIndicator(color: AppColors.lime)),
  );
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _MessageScreen(
    title: 'Firebase n’est pas encore configuré.',
    message: 'Ajoute la configuration Android du projet Firebase, puis relance l’application.',
    action: 'Réessayer',
    onPressed: onRetry,
  );
}

class _MessageScreen extends StatelessWidget {
  const _MessageScreen({
    required this.title,
    required this.message,
    required this.action,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppText.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              PrimaryButton(text: action, onPressed: onPressed),
            ],
          ),
        ),
      ),
    ),
  );
=======
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/management_controller.dart';
import 'controllers/member_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/reservation_controller.dart';
import 'controllers/session_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/firebase_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseSeeder.seedInitialData();
  } catch (e) {
    debugPrint('Firebase Core non configuré ou initialisé hors-ligne: $e');
  }

  runApp(const GymAdminApp());
}

class GymAdminApp extends StatelessWidget {
  const GymAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => MemberController()),
        ChangeNotifierProvider(create: (_) => SessionController()),
        ChangeNotifierProvider(create: (_) => ManagementController()),
        ChangeNotifierProvider(create: (_) => ReservationController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: MaterialApp.router(
        title: 'GYM ADMIN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
>>>>>>> admin/master
}
