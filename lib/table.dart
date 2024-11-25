import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    try {
      StringBuffer buffer = StringBuffer();
      String headline = "${Locales.results[Lang.l]} - ${DateFormat('dd.MM.yyyy').format(now)}\n";
      int maxCounts = Spieler.gruppe.map((x) => x.punkte.length).max;

      StringBuffer playerNames = StringBuffer();
      for(var player in Spieler.gruppe){
        String decoration = (Spieler.whoIsWinning().contains(player)) ? winningDecoration : "";
        playerNames.write(" ${player.name.truncate(10)}$decoration |".padLeft(14, " "));
      }
      playerNames.write("\n");

      for(int j=0;j<maxCounts;j++){
        for(var player in Spieler.gruppe){
          if(j >= player.punkte.length){
            buffer.write(" |".padLeft(14, " "));
            continue;
          }
          buffer.write(" ${player.punkte[j]} |".padLeft(14, " "));
        //buffer.write("## ${player.name}:$decoration\n - ${player.punkte.enumerateString()}\n");
        //buffer.write(" - ${Locales.pointsTotal[Lang.l]} ${player.sumPoints()}\n\n");
        }
        buffer.write("\n");
      }
      // do a `===============`
      buffer.write("${"=" * 14 * Spieler.gruppe.length}\n");

      // Sum of points
      for(var player in Spieler.gruppe){
        buffer.write(" ${player.sumPoints()} |".padLeft(14, " "));
      }
      // try SelectableText.rich, onTap
      // as here https://stackoverflow.com/q/60395983/17677104
      // or some https://api.flutter.dev/flutter/widgets/RichText-class.html
      // Scrollable (Windows testable I guess)
      // https://stackoverflow.com/questions/49617934/how-to-make-text-or-richtext-scrollable-in-flutter
      
      return Center(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SelectionArea(
                child: 
                RichText(
                  //TODO test IRL aka Android Phone
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
                      TextSpan(
                        text: buffer.toString(),
                        style: StyleDecorator.monoStil,
                      ),
                    ],
                  ),
                ),
                //child: StyleDecorator.typewriter(buffer.toString()),
                //child: StyleDecorator.viewMd(buffer.toString(), isMD: true),
              ),
              const SizedBox(height:20),
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
      );  
  }
    catch (exception){
      //Make exception readable.
      return Text(exception.toString());
  }
}}