import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salledesport/main.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GymCoachApp());
    await tester.pumpAndSettle();
  }

  testWidgets('launches on home and navigates to all coach screens', (
    tester,
  ) async {
    await openApp(tester);
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
    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Coach de test'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsNothing);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(find.text('Salut, Coach de test'), findsOneWidget);
  });

  testWidgets('coach can update their profile', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Informations personnelles'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('coach@example.com'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Nom'), 'Nour Test');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Nour Test'), findsOneWidget);
  });

  testWidgets('coach can create, edit, and delete a session', (tester) async {
    await openApp(tester);
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
