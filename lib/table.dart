import 'package:flutter/material.dart';
import './calc.dart';

class StyleDecorator {
  static const textstil = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  //const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
}

class TableExampleApp extends StatelessWidget {
  const TableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Table Sample')),
        body: TableExample(),
      ),
    );
  }
}
/*
 TODO Make table work
 ! First add return-to-front-page button
 ? Background canvas?
 * Music playing
*/

class TableExample extends StatelessWidget {
  final List<Teilnehmer> gruppe = [];
  final List names = ["Eins", "Zwei", "Drei", "Vier" ];
  TableExample({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      for(int i=0;i<3; i++){
        gruppe.add(Teilnehmer(name: names[i]));
      }
      String placeholder = "Hallo erstmal\n";
      for(var player in gruppe){
        placeholder += "${player.name}: ${player.punkte.toString()}\n";
        placeholder += " - Punkte insgesamt: ${player.sumPoints()}\n\n";
      }
      return Text(placeholder);
  }
    catch (exception){
      //Make exception readable.
      return Text(exception.toString());
  }
}}