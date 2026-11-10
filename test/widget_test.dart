import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salledesport/main.dart';

void main() {
  testWidgets('all four original screens are reachable', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GymAdherentApp(useFakeRepositories: true));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'coach@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Coach de test'), findsOneWidget);

    await tester.tap(find.text('Séances').last);
    await tester.pumpAndSettle();
    expect(find.text('Mes séances'), findsOneWidget);

    await tester.tap(find.text('Adhérents'));
    await tester.pumpAndSettle();
    expect(find.text('Mes adhérents'), findsOneWidget);
    expect(find.text('Adhérent de test'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Coach de test'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Coach de test'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('login, profile, logout, and registration flow', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GymAdherentApp(useFakeRepositories: true));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue'), findsOneWidget);
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Saisis une adresse e-mail valide.'), findsOneWidget);
    expect(find.text('6 caractères minimum.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'coach@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Coach de test'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Coach de test'), findsOneWidget);
    await tester.tap(find.text('Informations personnelles'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Adresse e-mail'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer un compte coach'));
    await tester.pumpAndSettle();
    expect(find.text('Créer mon compte coach'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));

    await tester.enterText(find.byType(TextFormField).at(0), 'Nour Test');
    await tester.enterText(find.byType(TextFormField).at(1), '0600000000');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'nour@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'different123');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Nour Test'), findsOneWidget);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Nour Test'), findsOneWidget);
    await tester.tap(find.text('Informations personnelles'));
    await tester.pumpAndSettle();
    expect(find.text('nour@example.com'), findsOneWidget);
  });

  testWidgets('session form creates a local session', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GymAdherentApp(useFakeRepositories: true));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'coach@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Séances').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle séance'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Studio C');
    await tester.enterText(find.byType(TextField).last, '14');
    await tester.tap(find.text('Créer la séance'));
    await tester.pumpAndSettle();

    expect(find.text('4 séances programmées'), findsOneWidget);
    expect(find.text('Studio C'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Modifier la séance'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Studio D');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Studio D'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer').last);
    await tester.pumpAndSettle();
    expect(find.text('3 séances programmées'), findsOneWidget);
    expect(find.text('Studio D'), findsNothing);
  });
}
