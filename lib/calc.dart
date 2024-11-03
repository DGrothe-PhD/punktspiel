import 'package:collection/collection.dart';
//import 'package:intl/intl.dart';
//import 'package:flutter/services.dart';

class Spieler{
  static List<String> _names = ["Eins", "Zwei", "Drei", "Vier" ];
  static List<Teilnehmer> gruppe = [];

  static set names(List<String> values){
    // By making _names private, the new names call settings to update groups.
    _names = values;
    settings();
  }
  static List<String> get names => _names;

  static void settings(){
    gruppe = [];
    for(String n in _names){
        gruppe.add(Teilnehmer(name: n));
    }
  }
  
  static void addPoints(String name, int punkte){
    gruppe[
      gruppe.indexWhere((element) => element.name == name)
    ].addPoints(punkte);
  }
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

  /*void readData()
  {
    try{
      List<String> zeilen = daten.split("\r\n");
      List<String> names = zeilen[0].split(" ");

      for(String n in names){
        gruppe.add(Teilnehmer(name : n));
      }

      // extract points like grandma
      for(int i=1;i<zeilen.length;i++){
        List<String> p = zeilen[i].split(" ");
        for(int j=0;j<p.length;j++){
          gruppe[j].addPoints(int.tryParse(p[i]) ?? 0);
        }
      }
    }
    catch(exception){
      print(exception.toString());
    }
  }*/
}

class Teilnehmer{
  String name = "";
  List<int> punkte = [] ;
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