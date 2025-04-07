import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import './calc.dart';
import './locales.dart';
import './styles.dart';

class StyleDecorator {
  static const double spacing = -0.4;
  static final textstil = TextStyle(
    fontSize: 12.0, color: const Color.fromARGB(255, 27, 26, 26),// fontWeight: FontWeight.bold,
    backgroundColor: Themes.greenishColor,
    letterSpacing: spacing,//-1.1,
  );
  static const monoStil = TextStyle(
    fontSize: 12.0, color: Colors.black, fontFamily: "B612 Mono",
    fontFamilyFallback: <String>["Courier"],
    letterSpacing: spacing,
  );
  static const boldStil = TextStyle(
    fontSize: 12.0,  fontFamily: 'B612 Mono',
    color: Colors.black,
    fontWeight: FontWeight.bold, // Setzt die fetten Buchstaben
    letterSpacing: spacing,
  );

  static Text typewriter(String input){
    return Text(input, style: monoStil);
  }

  static String write(String inputText){
    return md.markdownToHtml(inputText);
  }

  static Html viewMd(String inputText, {bool isMD = true}){
    return Html(
      data: isMD ? write(inputText) : inputText
    );
  }
}

class TableExampleApp extends StatelessWidget {
  const TableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO test without portrait preference first. Otherwise fix portrait by uncommenting this.
    //SystemChrome.setPreferredOrientations([
    //  DeviceOrientation.portraitUp,
    //  DeviceOrientation.portraitDown,
    //]);
    return Scaffold(
        resizeToAvoidBottomInset : true,//maybe false if keyboard
        appBar: AppBar(title: Text(Locales.resultsTitle[Lang.l])),
        body: 
        SingleChildScrollView(
          child: TableExample(),
        )
    );
    // reduce to the max. Returning MaterialApp shows black screen...
  }
}

class TableExample extends StatelessWidget {
  final List names = Spieler.names;
  static const String winningDecoration = "🎉";
  final now = DateTime.now();
  TableExample({super.key});
  static String headline = "";
  static StringBuffer playerNames = StringBuffer();
  static StringBuffer gameResultText = StringBuffer();

  @override
  Widget build(BuildContext context) {
    int columnWidth = 11;
    try {
      gameResultText = StringBuffer();
      headline = "${Locales.results[Lang.l]} - ${DateFormat('dd.MM.yyyy').format(now)}\n";
      int maxCounts = Spieler.gruppe.map((x) => x.punkte.length).max;
      playerNames = StringBuffer();
      //playerNames = StringBuffer("\xA0");
      
      for(var player in Spieler.gruppe){
        String decoration = (Spieler.whoIsWinning().contains(player)) ? winningDecoration : "\xA0\xA0";
        //String decoration = (Spieler.whoIsWinning().contains(player)) ? '' : "\xA0";
          if(player == Spieler.gruppe.last){
            playerNames.write("${player.firstName.truncate(8)}$decoration".padLeft(columnWidth, "\xA0"));
            break;
          }
          playerNames.write("${player.firstName.truncate(8)}$decoration|".padLeft(columnWidth, "\xA0"));
      }
      playerNames.write("\n");
      
      // Second part of names in second line
      if(Spieler.gruppe.any((person) => person.lastName.isNotEmpty)){
        for(var player in Spieler.gruppe){
          if(player == Spieler.gruppe.last){
            playerNames.write(" ${player.lastName.truncate(8)}\xA0".padLeft(columnWidth, "\xA0"));
            break;
          }
          playerNames.write(" ${player.lastName.truncate(8)}\xA0|".padLeft(columnWidth, "\xA0"));
        }
        playerNames.write("\n");
      }

      for(int j=0;j<maxCounts;j++){
        for(var player in Spieler.gruppe){
          if(player == Spieler.gruppe.last){
            if(j >= player.punkte.length){
              gameResultText.write(" \xA0".padLeft(columnWidth, " "));
              continue;
            }
            gameResultText.write(" ${player.punkte[j]}\xA0".padLeft(columnWidth, " "));
          }
          else{
            if(j >= player.punkte.length){
              gameResultText.write(" |".padLeft(columnWidth, " "));
              continue;
            }
            gameResultText.write(" ${player.punkte[j]} |".padLeft(columnWidth, " "));
          }
        }
        gameResultText.write("\n");
      }
      // do a `===============`
      gameResultText.write("${"=" * columnWidth * Spieler.gruppe.length}\n");

      // Sum of points
      for(var player in Spieler.gruppe){
        if(player == Spieler.gruppe.last){
          gameResultText.write(" ${player.sumPoints()} \xA0".padLeft(columnWidth, " "));
          break;
        }
        gameResultText.write(" ${player.sumPoints()} |".padLeft(columnWidth, " "));
      }
      
      return Center(
        child: SwipeTo(
          onRightSwipe: (details) => {Navigator.pop(context)},
          onLeftSwipe: (details) => {_onShare(context)},
          child: Column(
          children: <Widget>[
            WidgetAnimator(
              incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
                duration: const Duration(milliseconds: 2000),
              ),
              child:
              SelectionArea(
                child: 
                RichText(
                  selectionRegistrar: SelectionContainer.maybeOf(context),
                  textAlign: TextAlign.center,
                  //textAlign: TextAlign.right,
                  text: TextSpan(
                    text: headline,
                    style: StyleDecorator.monoStil,
                    children: <TextSpan>[
                      TextSpan(
                        text: playerNames.toString(),
                        style: StyleDecorator.textstil,
                      ),
                      TextSpan(text: gameResultText.toString(),),
                  ],
                  ),
                ),
              ),
            ),
            const SizedBox(height:20),
            ElevatedButton(
              onPressed: () => {_onShare(context)},
              style: ButtonStyle(
                  backgroundColor: Themes.sunflower,
                  minimumSize: WidgetStateProperty.all<Size>(const Size(120, 40)),
              ),
              child: Text(Locales.share[Lang.l]),
            ),
            const SizedBox(height:20),
            ElevatedButton(
              onPressed: () {Navigator.pop(context);},
              style: ButtonStyle(
                backgroundColor: Themes.green,
                minimumSize: WidgetStateProperty.all<Size>(const Size(120, 40)),
              ),
              child: Text(Locales.close[Lang.l]),
            ),
          ]
          )
        ),
      );  
  }
    catch (exception){
      //Make exception readable.
      return Text(exception.toString());
  }
}

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if(Platform.isWindows){
      Clipboard.setData(ClipboardData(
        text: gameResultText.isEmpty? "Nichts/None/Rien" 
        : "$headline\n$playerNames$gameResultText"
      ));
      showDialog(
        context: context,
        builder:(context) => const AlertDialog(
          title: Text("Copied"),
          content: Text("Game results copied to clipboard."),
      ));
      return;
    }
    await Share.share(
      gameResultText.isEmpty? "Nichts/None/Rien" 
      : "$headline\n$playerNames$gameResultText",
      subject: Locales.emailSubject[Lang.l],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}