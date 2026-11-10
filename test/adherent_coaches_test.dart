import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salledesport/data/repositories/fake_repositories.dart';
import 'package:salledesport/screens/adherent_coaches_screen.dart';
import 'package:salledesport/screens/coach_details_screen.dart';
import 'package:salledesport/theme/app_theme.dart';

void main() {
  test(
    'fake coach repository returns every coach, independently of sessions',
    () async {
      final repositories = FakeRepositories();
      final coaches = await repositories.coaches.getAllCoaches();

      expect(coaches, hasLength(2));
      expect(
        coaches.map((coach) => coach.name),
        orderedEquals(['Coach de test', 'Nour Ben Ali']),
      );
    },
  );

  testWidgets('searches and filters coaches and opens coach details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: AdherentCoachesScreen(
          coachesRepository: FakeRepositories().coaches,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coach de test'), findsOneWidget);
    expect(find.text('Nour Ben Ali'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nour');
    await tester.pumpAndSettle();
    expect(find.text('Nour Ben Ali'), findsOneWidget);
    expect(find.text('Coach de test'), findsNothing);

    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'HIIT'));
    await tester.pumpAndSettle();
    expect(find.text('Coach de test'), findsOneWidget);
    expect(find.text('Nour Ben Ali'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Toutes'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nour');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nour Ben Ali'));
    await tester.pumpAndSettle();
    expect(find.byType(CoachDetailsScreen), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Réserver une séance'), findsOneWidget);
    expect(find.text('Yoga · Renforcement'), findsOneWidget);
  });
}
