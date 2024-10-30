import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
//import 'package:flutter/services.dart';

// Idee: Umschreiben. Die Klasse soll keine Daten beinhalten, nur Text zerpflücken und 
// die Punkteberechnung ermöglichen.
class Spieler{
  List<Teilnehmer> spieler = [];
  String daten = "";
  
  /*Future init() async
  {
    try{
      daten = await rootBundle.loadString('assets/data/players.txt');
      //.then((value) => {daten});
      //final input = File('assets/data/players.txt').openRead();
      //String daten = input.toString();
      readData();
    }
    catch(exception){
      print(exception.toString());
    }
  }*/

  void readData()
  {
    try{
      List<String> zeilen = daten.split("\r\n");
      List<String> names = zeilen[0].split(" ");

      for(String n in names){
        spieler.add(Teilnehmer(name : n));
      }

      // extract points like grandma
      for(int i=1;i<zeilen.length;i++){
        List<String> p = zeilen[i].split(" ");
        for(int j=0;j<p.length;j++){
          spieler[j].addPoints(int.tryParse(p[i]) ?? 0);
        }
      }
    }
    catch(exception){
      print(exception.toString());
    }
  }
}

class Teilnehmer{
  String name = "";
  List<int> punkte = [2,3,4] ;
  Teilnehmer({required this.name});

  void addPoints(int value){
    punkte.add(value);
  }

  int sumPoints() => punkte.sum;
}

extension IntListParsing on List<int>{
  String enumerateString(){
    return map((i) => i.toString()).join(", ");
  }
}