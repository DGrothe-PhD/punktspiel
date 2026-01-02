import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
//import 'package:flutter_html/flutter_html.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import 'package:punktspiel/calc.dart';

// Datum
import 'package:punktspiel/locales.dart';

//
import 'package:punktspiel/generated/l10n.dart';

import 'package:punktspiel/styles.dart';
import 'package:punktspiel/preferences/mysharedpreferences.dart';

class StyleDecorator {
  static const double spacing = -0.4;
  static final textstil = TextStyle(
    fontSize: 12.0,
    color: const Color.fromARGB(255, 27, 26, 26), // fontWeight: FontWeight.bold,
    backgroundColor: Themes.active,
    letterSpacing: spacing, //-1.1,
  );
  static const monoStil = TextStyle(
    fontSize: 12.0,
    color: Colors.black,
    fontFamily: "B612 Mono",
    fontFamilyFallback: <String>["Courier"],
    letterSpacing: spacing,
  );
  static const boldStil = TextStyle(
    fontSize: 12.0, fontFamily: 'B612 Mono',
    color: Colors.black,
    fontWeight: FontWeight.bold, // Setzt die fetten Buchstaben
    letterSpacing: spacing,
  );

  static Text typewriter(String input) {
    return Text(input, style: monoStil);
  }

  static String write(String inputText) {
    return md.markdownToHtml(inputText);
  }

  /*static Html viewMd(String inputText, {bool isMD = true}) {
    return Html(data: isMD ? write(inputText) : inputText);
  }*/
}

BuildContext? tableContext;

class TableExampleApp extends StatelessWidget {
  const TableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    tableContext = context;
    return Scaffold(
      resizeToAvoidBottomInset: true, //maybe false if keyboard
      appBar: Themes.cardboardAppBar(
        S.of(context).resultsTitle,
        actions: [
          IconButton(
            tooltip: S.of(context).shareEverything,
            icon: const Icon(Icons.offline_share),
            onPressed: () => TablePage.onShareTable(context),
          ),
          IconButton(
            tooltip: S.of(context).shareResults,
            icon: const Icon(Icons.speaker_notes),
            onPressed: () => TablePage.onShareResults(context),
          ),
        ],
      ),
      //drawer: ElevatedButton(child: const Column(children:[Text("tbd")]), onPressed: () {},),
      body: SingleChildScrollView(
        child: TablePage(),
      ),
      floatingActionButton: Spieler.filledFullRound()
          ? FloatingActionButton(
              onPressed: storeData,
              backgroundColor: Themes.pumpkinColor,
              shape: Themes.cardShape,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              child: const Icon(Icons.save_rounded),
            )
          : null,
    );
  }

  void storeData() {
    var now = DateTime.now();// no elevated button? Then "now" becomes obsolete.
    UserSettings settings = UserSettings(
      dateTime: Lang.deDateFormat.format(now),
      names: Spieler.names,
      game: Spieler.gameKeyAsString(),
      numberOfGamesPlayed: Spieler.numberOfGamesPlayed,
      leastPointsWinning: Spieler.leastPointsWinning.value,
      sumOfPoints: Spieler.gruppe.map((i) => i.punkte.sum).toList(),
    );
    
    //settings.verboseTesting();
    MySharedPreferences.saveData(settings);
  }
}

class TablePage extends StatelessWidget {
  final List names = Spieler.names;
  static const String winningDecoration = "🎉";
  final now = DateTime.now();
  TablePage({super.key});

  static String headline = "";
  static const int columnWidth = 11;
  static StringBuffer playerNames = StringBuffer();
  static StringBuffer gameResultText = StringBuffer();

  String floatString(num? value) {
    if(value == null){
      return "--";
    }
    else if(value is int){
      return value.toString();
    }
      return value.toStringAsFixed(2);
  }

  void _writePlayerStats(Teilnehmer player, num? stat,
      {bool isLastLine = false}) {
    /// usage: for loop: _writePlayerStats(player, player.countZeros);
    if (player == Spieler.gruppe.last) {
      gameResultText.write(" ${floatString(stat)}\xA0".padLeft(columnWidth, " "));
      if (!isLastLine) gameResultText.write("\n");
    } else {
      gameResultText.write(" ${floatString(stat)} |".padLeft(columnWidth, " "));
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      gameResultText = StringBuffer();
      final gameLocale = Spieler.gameKeyAsString() ?? "";
      headline =
          "${S.of(context).resultsLabel} - ${Lang.deDateFormat.format(now)}\n"
          "$gameLocale - n: ${Spieler.numberOfGamesPlayed}\n";
      int maxCounts = Spieler.gruppe.map((x) => x.punkte.length).max;
      playerNames = StringBuffer();
      //playerNames = StringBuffer("\xA0");

      for (var player in Spieler.gruppe) {
        String decoration = (Spieler.whoIsWinning().contains(player))
            ? winningDecoration
            : "\xA0\xA0";
        if (player == Spieler.gruppe.last) {
          playerNames.write("${player.firstName.truncate(8)}$decoration"
              .padLeft(columnWidth, "\xA0"));
          break;
        }
        playerNames.write("${player.firstName.truncate(8)}$decoration|"
            .padLeft(columnWidth, "\xA0"));
      }
      playerNames.write("\n");

      // Second part of names in second line
      if (Spieler.gruppe.any((person) => person.lastName.isNotEmpty)) {
        for (var player in Spieler.gruppe) {
          if (player == Spieler.gruppe.last) {
            playerNames.write(" ${player.lastName.truncate(8)}\xA0"
                .padLeft(columnWidth, "\xA0"));
            break;
          }
          playerNames.write(" ${player.lastName.truncate(8)}\xA0|"
              .padLeft(columnWidth, "\xA0"));
        }
        playerNames.write("\n");
      }

      // Write points of all games row by row
      for (int j = 0; j < maxCounts; j++) {
        for (var player in Spieler.gruppe) {
          if (player == Spieler.gruppe.last) {
            if (j >= player.punkte.length) {
              gameResultText.write(" \xA0".padLeft(columnWidth, " "));
              continue;
            }
            gameResultText
                .write(" ${player.punkte[j]}\xA0".padLeft(columnWidth, " "));
          } else {
            if (j >= player.punkte.length) {
              gameResultText.write(" |".padLeft(columnWidth, " "));
              continue;
            }
            gameResultText
                .write(" ${player.punkte[j]} |".padLeft(columnWidth, " "));
          }
        }
        gameResultText.write("\n");
      }

      // do a `===============`
      gameResultText.write("${"=" * columnWidth * Spieler.gruppe.length}\n");

      // Sum of points
      for (var player in Spieler.gruppe) {
        _writePlayerStats(player, player.sumPoints);
      }

      gameResultText.write("\n${S.of(context).zeroPointsLabel}\n");
      for (var player in Spieler.gruppe) {
        _writePlayerStats(player, player.countZeros);
      }

      gameResultText.write("${S.of(context).averagePointsLabel}\n");
      for (var player in Spieler.gruppe) {
        _writePlayerStats(player, player.avgPoints);
      }

      gameResultText.write("${S.of(context).best}\n");
      for (var player in Spieler.gruppe) {
        _writePlayerStats(player,
            Spieler.leastPointsWinning.value ? player.minPoints : player.maxPoints);
      }

      return Center(
          child: Column(children: <Widget>[
            const SizedBox(height: 17),
        WidgetAnimator(
          incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
            duration: const Duration(milliseconds: 2000),
          ),
          child: SwipeTo(
            onLeftSwipe: (details) =>
                {onShareResults(tableContext ?? context)},
            onRightSwipe: (details) =>
                {onShareTable(tableContext ?? context)},
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              primary: true,
              //physics: const NeverScrollableScrollPhysics(),
              child: SelectableText.rich(
                TextSpan(
                  text: headline,
                  style: StyleDecorator.monoStil,
                  children: <TextSpan>[
                    TextSpan(
                      text: playerNames.toString(),
                      style: StyleDecorator.textstil,
                    ),
                    TextSpan(
                      text: gameResultText.toString(),
                    ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ]));
    } catch (exception) {
      //Make exception readable.
      return Text(exception.toString());
    }
  }

  static void onShareTable(BuildContext context) async {
    final renderBox = context.findRenderObject();
    if (Platform.isWindows) {
      Clipboard.setData(ClipboardData(
          text: gameResultText.isEmpty
              ? "Nichts/None/Rien"
              : "$headline\n$playerNames$gameResultText"));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Game results copied to clipboard."),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    if (renderBox is RenderBox) {
      await Share.share(
        gameResultText.isEmpty
            ? "Nichts/None/Rien"
            : "$headline\n$playerNames$gameResultText",
        subject: S.of(context).emailSubject,
        sharePositionOrigin:
            renderBox.localToGlobal(Offset.zero) & renderBox.size,
      );
    }
  }

  static void onShareResults(BuildContext context) async {
    final renderBox = context.findRenderObject();
    if (Platform.isWindows) {
      Clipboard.setData(ClipboardData(
        text:
          gameResultText.isEmpty ? "Nichts/None/Rien" : Spieler.report(headline)));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Game results copied to clipboard."),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    if (renderBox is RenderBox) {
      await Share.share(
        gameResultText.isEmpty ? "Nichts/None/Rien" : Spieler.report(headline),
        subject: S.of(context).emailSubject,
        sharePositionOrigin: renderBox.localToGlobal(Offset.zero) & renderBox.size,
      );
    }
  }
}
