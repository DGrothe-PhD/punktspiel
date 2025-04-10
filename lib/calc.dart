//import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import './locales.dart';
//import 'package:intl/intl.dart';
//import 'package:flutter/services.dart';

class Spieler{
  static List<String> _names = ["Eins", "Zwei", "Drei", "Vier" ];
  static List<Teilnehmer> gruppe = [];

  // default: rummy, lowest number of points is winning, as opposed to scrabble.
  static bool leastPointsWinning = true;

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

  static int getSumOfPoints(String name) {
    return gruppe.firstWhere((element) => element.name == name).sumPoints();
  }

  static void deleteLastEntry(String name){
    gruppe[
      gruppe.indexWhere((element) => element.name == name)
    ].popPointsEntry();
  }
  static bool filledFullRound(){
    var crunchedData = gruppe.map((x) => x.punkte.length);
    int minCounts = crunchedData.min;
    int maxCounts = crunchedData.max;
    return minCounts == maxCounts;
  }

  static bool fillingTwice(String name){
    var crunchedData = gruppe.map((x) => x.punkte.length);
    int minCounts = crunchedData.min;
    int nameCounts = gruppe[
      gruppe.indexWhere((element) => element.name == name)
    ].punkte.length;
    return minCounts < nameCounts;
  }

  static List<String> whoIsEmpty(){
    var crunchedData = gruppe.map((x) => x.punkte.length);
    int minCounts = crunchedData.min;
    return gruppe
      .where((x)=> x.punkte.length == minCounts)
      .map((x)=>x.name).toList();
  }
  
  static List<Teilnehmer> whoIsWinning(){
    if(gruppe.length > 1 && filledFullRound() && gruppe[0].punkte.length >= gruppe.length){
      var sumOfPoints = gruppe.map((x) => x.sumPoints());
      var best = leastPointsWinning? sumOfPoints.min : sumOfPoints.max;
      return gruppe.where((x)=> x.sumPoints() == best).toList();
    }
    return <Teilnehmer>[];
  }

  static String report(){
    final now = DateTime.now();
    final String headline = "${Locales.results[Lang.l]} - ${DateFormat('dd.MM.yyyy').format(now)}\n\n";
    StringBuffer buffer = StringBuffer(headline);
    
    for(Teilnehmer player in gruppe){
      buffer.write("${player.name}:\t${player.sumPoints()}\n");
    }
    return buffer.toString();
  }
}

class Teilnehmer{
  String name = "";
  String firstName = "";
  String lastName = "";
  List<int> punkte = [] ;
  Teilnehmer({required this.name}){
    int index = name.indexOf(" ");
    if(index == -1 || index == name.length - 1){
      firstName = name;
      return;
    }
    firstName = name.substring(0, index);
    lastName = name.substring(index+1);
  }

  void addPoints(int value){
    punkte.add(value);
  }

  void popPointsEntry(){
    if (punkte.isNotEmpty){
      punkte.removeLast();
    }
  }

  int sumPoints() => punkte.sum;
}

extension IntListParsing on List<int>{
  String enumerateString(){
    return map((i) => i.toString()).join(", ");
  }
}

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);
  String truncate(int maxLength) {
    if(length > maxLength){
      return "${substring(0, maxLength)}.";
    }
    return this;
  }
}
