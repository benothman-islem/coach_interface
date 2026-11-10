import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.onSignIn,
    required this.onRegister,
    required this.onAuthenticated,
    this.notice,
    super.key,
  });

  final Future<AppUser> Function(String email, String password) onSignIn;
  final Future<AppUser> Function({
    required String name,
    required String email,
    required String phone,
    required String password,
  })
  onRegister;
  final Future<void> Function(BuildContext context, AppUser user)
  onAuthenticated;
  final String? notice;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isRegistering = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_isRegistering) {
        final user = await widget.onRegister(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          password: _password.text,
        );
        if (!mounted) return;
        await widget.onAuthenticated(context, user);
      } else {
        final user = await widget.onSignIn(_email.text.trim(), _password.text);
        if (!mounted) return;
        await widget.onAuthenticated(context, user);
      }
    } on UnknownUserRoleException {
      if (mounted) {
        setState(
          () => _error = 'Aucun rôle valide n’est associé à ce compte. Contacte un administrateur.',
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _error = _authError(error.code));
    } on FirebaseException catch (error) {
      debugPrint('Firebase authentication flow failed (${error.code}).');
      setState(() => _error = _firebaseError(error.code));
    } catch (error) {
      debugPrint('Authentication flow failed (${error.runtimeType}).');
      setState(
        () => _error = 'Connexion impossible. Vérifie tes informations.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _authError(String code) => switch (code) {
    'invalid-email' => 'Adresse e-mail invalide.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Adresse e-mail ou mot de passe incorrect.',
    'email-already-in-use' => 'Cette adresse e-mail est déjà utilisée.',
    'weak-password' => 'Choisis un mot de passe plus sécurisé.',
    'network-request-failed' ||
    'unavailable' ||
    'deadline-exceeded' => 'Vérifie ta connexion internet.',
    _ => 'Connexion impossible. Réessaie dans un instant.',
  };

  String _firebaseError(String code) => switch (code) {
    'permission-denied' => 'Accès Firestore refusé. Vérifie et publie les règles du projet Firebase.',
    'failed-precondition' =>
      'Firestore n’est pas prêt. Vérifie la configuration de la base Firebase.',
    'not-found' =>
      'Base Firestore introuvable. Crée la base Cloud Firestore du projet.',
    'unavailable' ||
    'deadline-exceeded' => 'Vérifie ta connexion internet puis réessaie.',
    _ => 'Impossible de créer le compte. Réessaie dans un instant.',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.darkGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.lime,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _isRegistering ? 'Créer mon compte coach' : 'Bienvenue',
                    style: AppText.screenTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegistering
                        ? 'Crée ton espace pour gérer ta salle.'
                        : 'Connecte-toi à ton espace coach.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.notice case final notice?) ...[
                    const SizedBox(height: 14),
                    Text(
                      notice,
                      style: const TextStyle(
                        color: AppColors.lime,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (_isRegistering) ...[
                    _field(_name, 'Nom complet', validator: _required),
                    const SizedBox(height: 12),
                    _field(
                      _phone,
                      'Téléphone',
                      keyboardType: TextInputType.phone,
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _field(
                    _email,
                    'Adresse e-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(value.trim())) {
                        return 'Saisis une adresse e-mail valide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _password,
                    'Mot de passe',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return '6 caractères minimum.';
                      }
                      return null;
                    },
                  ),
                  if (_isRegistering) ...[
                    const SizedBox(height: 12),
                    _field(
                      _confirmPassword,
                      'Confirmer le mot de passe',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme ton mot de passe.';
                        }
                        if (value != _password.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.destructive,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: _busy
                        ? 'Veuillez patienter…'
                        : _isRegistering
                        ? 'Créer mon compte'
                        : 'Se connecter',
                    onPressed: _submit,
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _isRegistering = !_isRegistering;
                            _error = null;
                          }),
                    child: Text(
                      _isRegistering
                          ? 'J’ai déjà un compte'
                          : 'Créer un compte coach',
                      style: const TextStyle(color: AppColors.lime),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ obligatoire.' : null;

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    style: const TextStyle(color: AppColors.text),
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
