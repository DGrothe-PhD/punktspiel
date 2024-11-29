import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:punktspiel/main.dart';
import 'package:punktspiel/locales.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('Eins'), findsAtLeast(1));
    //expect(find.text('Vier').hitTestable(), findsAtLeast(1));


    // Let's type some names and check if that's effective.
    await tester.enterText(
      find.bySemanticsLabel(Locales.players[Lang.l]),
      "Anna 🍂,Dagmar 🦆",
    );
    await tester.tap(find.text('0'));
    // Won't let me tap on AppBar or Scaffold by type.

    await tester.pumpAndSettle();
    expect(find.text('Eins'), findsNothing);

    expect(find.text('Dagmar 🦆'), findsNothing);
    // Set a name for the names dropdownMenu

    // TRYING
    final nameSelector = find.text("Anna 🍂");
    expect(nameSelector, findsOneWidget);// ☺

    // Enter points
    await tester.enterText(find.bySemanticsLabel(Locales.points[Lang.l]), '42');
    await tester.tap(find.bySemanticsLabel(Locales.submit[Lang.l]));

    // Enter some further points through opening the nameSelector dropdownMenu
    await tester.tap(nameSelector);
    await tester.pumpAndSettle();
    final secondPlayerThere = find.text("Dagmar 🦆").hitTestable();
    expect(secondPlayerThere, findsOneWidget);

    // Now that second player exists, select that one and give that `guy` 21 points.
    await tester.tap(secondPlayerThere);
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel(Locales.points[Lang.l]), '21');
    await tester.tap(find.bySemanticsLabel(Locales.submit[Lang.l]));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
