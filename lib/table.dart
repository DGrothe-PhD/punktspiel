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

class StyleDecorator {
  static const textstil = TextStyle(
    fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold
  );
  static const monoStil = TextStyle(
    fontSize: 12.0, color: Colors.black, fontFamily: "B612 Mono",
    fontFamilyFallback: <String>["Courier"]
  );
  static const boldStil = TextStyle(
    fontSize: 12.0,  fontFamily: 'B612 Mono',
    color: Colors.black,
    fontWeight: FontWeight.bold, // Setzt die fetten Buchstaben
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
  // how to update the table?

  @override
  Widget build(BuildContext context) {
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
    try {
      gameResultText = StringBuffer();
      headline = "${Locales.results[Lang.l]} - ${DateFormat('dd.MM.yyyy').format(now)}\n";
      int maxCounts = Spieler.gruppe.map((x) => x.punkte.length).max;

      playerNames = StringBuffer();
      for(var player in Spieler.gruppe){
        String decoration = (Spieler.whoIsWinning().contains(player)) ? winningDecoration : "  ";
        playerNames.write("${player.name.truncate(10)}$decoration|".padLeft(14, " "));
      }
      playerNames.write("\n");

      for(int j=0;j<maxCounts;j++){
        for(var player in Spieler.gruppe){
          if(j >= player.punkte.length){
            gameResultText.write(" |".padLeft(14, " "));
            continue;
          }
          gameResultText.write(" ${player.punkte[j]} |".padLeft(14, " "));
        }
        gameResultText.write("\n");
      }
      // do a `===============`
      gameResultText.write("${"=" * 14 * Spieler.gruppe.length}\n");

      // Sum of points
      for(var player in Spieler.gruppe){
        gameResultText.write(" ${player.sumPoints()} |".padLeft(14, " "));
      }
      // try SelectableText.rich, onTap
      // as here https://stackoverflow.com/q/60395983/17677104
      // or some https://api.flutter.dev/flutter/widgets/RichText-class.html
      // Scrollable (Windows testable I guess)
      // https://stackoverflow.com/questions/49617934/how-to-make-text-or-richtext-scrollable-in-flutter
      
      return Center(
        child: SwipeTo(
          onRightSwipe: (details) => {Navigator.pop(context)},
          onLeftSwipe: (details) => {_onShare(context)},
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.end,
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
                      textAlign: TextAlign.right,
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
                  padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                    (Set<WidgetState> states) {
                  return const EdgeInsets.all(7);
                  },),
                  backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 221, 215, 157)
                  ),
              ),
              child: Text(Locales.share[Lang.l]),
            ),
            SizedBox(
              width: 120,
              height: 50,
              child: ElevatedButton(
                onPressed: () {Navigator.pop(context);},
                style: ButtonStyle(
                  padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                    (Set<WidgetState> states) {
                  return const EdgeInsets.all(7);
                  },),
                  backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 63, 186, 110)
                  ),
                ),
                child: Text(Locales.close[Lang.l]),
              ),
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