import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import './calc.dart';
import './locales.dart';

class StyleDecorator {
  static const textstil = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  static String write(String inputText){
    return md.markdownToHtml(inputText);
  }

  static Html viewMd(String inputText){
    return Html(data: write(inputText));
  }
}

class TableExampleApp extends StatelessWidget {
  const TableExampleApp({super.key});
  // how to update the table?

  @override
  Widget build(BuildContext context) {
    // reduce to the max. Returning MaterialApp shows black screen...
    return Scaffold(
      resizeToAvoidBottomInset : true,//maybe false if keyboard
      appBar: AppBar(title: Text(Locales.resultsTitle[Lang.l])),
      body: 
      SingleChildScrollView(
        child: TableExample(),
      )
    );
  }
}

class TableExample extends StatelessWidget {
  final List names = Spieler.names;
  final now = DateTime.now();
  TableExample({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      String placeholder = "# ${Locales.results[Lang.l]} - ${DateFormat('dd.MM.yyyy').format(now)}\n";
      for(var player in Spieler.gruppe){
        placeholder += "## ${player.name}:\n - ${player.punkte.enumerateString()}\n";
        placeholder += " - ${Locales.pointsTotal[Lang.l]} ${player.sumPoints()}\n\n";
      }
      return Center(
          child: Column(
            children: <Widget>[
            StyleDecorator.viewMd(placeholder),
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