import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:punktspiel/main.dart';
import 'package:punktspiel/calc.dart';

import 'package:punktspiel/generated/l10n.dart';

void main() {
  PointsSubmittingTest testSuite = PointsSubmittingTest();
  //testSuite.testIfEverythingFineAndCounterIncrements();
  testSuite.testWhoIsWinning();
}

class PointsSubmittingTest{
  Finder? firstPlayer, numPointsField, submittingPointsButton, secondPlayer;
  Finder? tapAnchor;
  final S locale = S();

  Future givePoints({required WidgetTester tester, required int points}) 
    async {
      await tester.enterText(numPointsField!, "$points");
      await tester.tap(tapAnchor!);
      await tester.pumpAndSettle();
      await tester.tap(submittingPointsButton!);
      await tester.pumpAndSettle();
  }

  void testIfEverythingFineAndCounterIncrements(){
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(find.text('Eins'), findsAtLeast(1));
      //expect(find.text('Vier').hitTestable(), findsAtLeast(1));


      // Let's type some names and check if that's effective.
      //TODO fix this test.
      await tester.enterText(
        find.bySemanticsLabel(locale.playersLabel),
        "Anna 🍂,Dagmar 🦆",
      );
      // Just tap somewhere I can code for. 
      // First try was AppBar or Scaffold by type. Guess that's due to some hierarchical confusion.
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      // Assert that there's just Anna on top, nothing else.
      expect(find.text('Eins'), findsNothing);
      expect(find.text('Dagmar 🦆'), findsNothing);

      // Define some variables for the DropdownButton and point submitting
      firstPlayer = find.text("Anna 🍂");
      expect(firstPlayer, findsOneWidget);// ☺
      numPointsField = find.bySemanticsLabel(locale.pointsLabel);
      expect(numPointsField, findsOneWidget);
      submittingPointsButton = find.bySemanticsLabel(locale.submitPoints);
      expect(submittingPointsButton, findsOneWidget);

      // Enter points for first player
      await givePoints(tester: tester, points: 42);

      // Select other player through opening the firstPlayer dropdownMenu
      await tester.tap(firstPlayer!);
      await tester.pumpAndSettle();
      secondPlayer = find.text("Dagmar 🦆").hitTestable();
      expect(secondPlayer, findsOneWidget);

      // Now that second player exists, select that one and give that `guy` 21 points.
      await tester.tap(secondPlayer!);
      await tester.pumpAndSettle();
      await givePoints(tester: tester, points: 21);

      // Verify that our counter is incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });
  }

  void testWhoIsWinning(){
    testWidgets('Check point sum, Who is winning', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      tapAnchor = find.text(locale.playedRoundsLabel);

      // Let's type some names and check if that's effective.
      // TODO https://api.flutter.dev/flutter/flutter_test/TestTextInput/receiveAction.html
      var nameField = find.byType(TextField).first;
      await tester.enterText(
        nameField,
        //find.bySemanticsLabel(Locales.players[Lang.l]),
        "Anna 🍂,Dagmar 🦆",
      );
      // * I was trying to do
      //* await nameField.receiveAction(TextInputAction.done);
      //* but it has to be:
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // Just tap somewhere I can code for. 
      // First try was AppBar or Scaffold by type. Guess that's due to some hierarchical confusion.
      await tester.tap(find.text(locale.playedRoundsLabel));
      await tester.pumpAndSettle();

      // Assert that there's just Anna on top, nothing else.
      expect(find.text('Eins'), findsNothing);
      expect(find.text('Dagmar 🦆'), findsNothing);

      // Define some variables for the DropdownButton and point submitting
      firstPlayer = find.text("Anna 🍂");
      expect(firstPlayer, findsOneWidget);// ☺
      numPointsField = find.bySemanticsLabel(locale.pointsLabel);
      expect(numPointsField, findsOneWidget);
      submittingPointsButton = find.bySemanticsLabel(locale.submitPoints);
      expect(submittingPointsButton, findsOneWidget);

      // ! Enter points for first player
      expect(Spieler.getSumOfPoints("Anna 🍂"), equals(0));
      await givePoints(tester: tester, points: 42);

      expect(Spieler.getSumOfPoints("Anna 🍂"), equals(42));

      // Select other player through opening the firstPlayer dropdownMenu
      await tester.tap(firstPlayer!);
      await tester.pumpAndSettle();
      secondPlayer = find.text("Dagmar 🦆").hitTestable();
      expect(secondPlayer, findsOneWidget);

      // 2nd player gets points.
      await tester.tap(secondPlayer!);
      await tester.pumpAndSettle();
      await givePoints(tester: tester, points: 0);
      expect(Spieler.getSumOfPoints("Dagmar 🦆"), equals(0));

      // ! Second round
      await switchToPlayerNumber(tester: tester, i: 1);
      await givePoints(tester: tester, points: 21);
      expect(Spieler.getSumOfPoints("Dagmar 🦆"), equals(0));
      expect(Spieler.getSumOfPoints("Anna 🍂"), equals(63));

      // 2nd player gets points.
      await switchToPlayerNumber(tester: tester, i: 2);
      await givePoints(tester: tester, points: 0);
      expect(Spieler.getSumOfPoints("Dagmar 🦆"), equals(0));

      // ! Third round
      await switchToPlayerNumber(tester: tester, i: 1);
      await givePoints(tester: tester, points: 17);
      expect(Spieler.getSumOfPoints("Anna 🍂"), equals(80));

      await switchToPlayerNumber(tester: tester, i: 2);
      await givePoints(tester: tester, points: 11);
      expect(Spieler.getSumOfPoints("Dagmar 🦆"), equals(11));

      // Verify that our counter is incremented.
      expect(find.text('1'), findsNothing);
      expect(find.text('3'), findsOneWidget);

      expect(Spieler.whoIsWinning().first.name, equals("Dagmar 🦆"));
    });
  }

  Future switchToPlayerNumber({required WidgetTester tester, required int i}) async {
    switch(i){
      case 1:
        await tester.tap(secondPlayer!);
        await tester.pumpAndSettle();
        await tester.tap(firstPlayer!);
        break;
      case 2:
        await tester.tap(firstPlayer!);
        await tester.pumpAndSettle();
        await tester.tap(secondPlayer!);
      default:
        break;
    }
  }
}