import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salledesport/models/member.dart';
import 'package:salledesport/main.dart';

void main() {
  test(
    'member mapping uses available contact data and stable presentation data',
    () {
      final first = Member.fromMap({
        'name': 'Yasmine Ali',
        'phone': '0612345678',
      }, 'member-1');
      final second = Member.fromMap({
        'name': 'Yasmine Ali',
        'phone': '0612345678',
      }, 'member-1');

      expect(first.name, 'Yasmine Ali');
      expect(first.initials, 'YA');
      expect(first.phone, '0612345678');
      expect(first.goal, isEmpty);
      expect(first.avatarColor, second.avatarColor);
    },
  );

  testWidgets('opens the selected adherent details and session history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GymCoachApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adhérents'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adhérent de test'));
    await tester.pumpAndSettle();

    expect(find.text('Adhérent de test'), findsOneWidget);
    expect(find.text('0600000001'), findsOneWidget);
    expect(find.text('Séances (3)'), findsOneWidget);
    expect(find.text('Yoga Flow'), findsOneWidget);
    expect(find.text('Cross Training'), findsOneWidget);
    expect(find.text('HIIT Training'), findsOneWidget);
  });
}
