//import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:punktspiel/preferences/mysharedpreferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:punktspiel/locales.dart';
import 'package:punktspiel/models/games.dart';
//import 'package:intl/intl.dart';
//import 'package:flutter/services.dart';

class Spieler{
  static List<String> _names = ["Eins", "Zwei", "Drei", "Vier" ];
  static List<Teilnehmer> gruppe = [];
  static bool hasWinningRuleSet = false;
  static bool hasMembers = false;
  static final Features _features = Features();

  static String? _game;
  static set game(String? value){
    _game = value;
    MySharedPreferences.saveGame(value);
    _checkWinningRule(value);
  }
  static String? get game => _game;

  static void _checkWinningRule(String? value) async {
    if(value != null && _features.games.keys.contains(value)){
      Game found = _features.games.lookup(value);
      if(found.leastPointsWinning != null){
        leastPointsWinning = found.leastPointsWinning!;
        hasWinningRuleSet = true;
        return;
      }
    }
    bool? leastPointsWinningPreset = await MySharedPreferences.getLeastPointsWinning();
    if(leastPointsWinningPreset != null){_leastPointsWinning = leastPointsWinningPreset;}
    hasWinningRuleSet = false;
  }

  // default: rummy, lowest number of points is winning, as opposed to scrabble.
  static bool _leastPointsWinning = true;
  static set leastPointsWinning(bool value){
    _leastPointsWinning = value;
    MySharedPreferences.saveLeastPointsWinning(value);
  }
  static bool get leastPointsWinning => _leastPointsWinning;

  static set names(List<String> values){
    // By making _names private, the new names call settings to update groups.
    _names = values;
    MySharedPreferences.saveNames(_names);
    gruppe = [];
    for(String n in _names){
      gruppe.add(Teilnehmer(name: n));
    }
  }
  static List<String> get names => _names;

  static void settings() async{
    gruppe = [];
    try{
      // prefer the points winning rule if specified for that game
      String? gamePreset = await MySharedPreferences.getGame();
      if(gamePreset != null){
        _game = gamePreset;
        _checkWinningRule(_game);
      }
      else{
        bool? leastPointsWinningPreset = await MySharedPreferences.getLeastPointsWinning();
        if(leastPointsWinningPreset != null){_leastPointsWinning = leastPointsWinningPreset;}
        hasWinningRuleSet = false;
      }
      
      List<String>? namesPreset = await MySharedPreferences.getNames();
      if(namesPreset == null || namesPreset.isEmpty){return;}
      _names = namesPreset;
      hasMembers = true;
    }
    catch(exception){
      _names = ["Eins", "Zwei", "Drei", "Vier" ];
    }
    for(String n in _names){
      gruppe.add(Teilnehmer(name: n));
    }
  }

  static void addPlayer(String name){
    name = name.replaceAll(',', "").split(RegExp(r'\s+')).join(" ").trim();
    if(name.isEmpty) return;
    // avoid duplicates: do nothing if name is already there.
    int trynotfound = gruppe.indexWhere((teilnehmer) => teilnehmer.name == name);
    if(trynotfound != -1) return;
    if(names.contains(name)) return;
    // Good. Go ahead and save.
    Spieler.names.insert(0, name);
    MySharedPreferences.saveNames(_names);
    gruppe.insert(0, Teilnehmer(name: name));
  }

  static void movePlayer(String name, int newIndex) {
    if(!names.remove(name)) return;
    int oldIndex = gruppe.indexWhere((teilnehmer) => teilnehmer.name == name);
    if (oldIndex == -1) return;
    Teilnehmer? tn = gruppe.removeAt(oldIndex);
    // Side exit to remove from active group
    if(newIndex == -1) return;
    // Otherwise: inserting
    Spieler.names.insert(newIndex, name);
    MySharedPreferences.saveNames(_names);
    gruppe.insert(newIndex, tn);
  }

  static void removePlayer(String name) {
    if(!names.remove(name)) return;
    MySharedPreferences.saveNames(_names);
    int oldIndex = gruppe.indexWhere((teilnehmer) => teilnehmer.name == name);
    if (oldIndex == -1) return;
    gruppe.removeAt(oldIndex);
  }
  
  static void addPoints(String name, int punkte){
    int index = gruppe.indexWhere((element) => element.name == name);
    if(index == -1) return;
    gruppe[index].addPoints(punkte);
  }

  // only used for testing. So maybe put it there.
  static num? getSumOfPoints(String name) {
    num? sumPoints;
    try{
      sumPoints = gruppe.firstWhere((element) => element.name == name).sumPoints;
    }
    catch(exception){
      sumPoints = null;
    }
    return sumPoints;
  }

  static void deleteLastEntry(String name){
    int index = gruppe.indexWhere((element) => element.name == name);
    if(index == -1) return;
    gruppe[index].popPointsEntry();
  }
  static bool filledFullRound(){
    var crunchedData = gruppe.map((x) => x.punkte.length);
    int minCounts = crunchedData.min;
    int maxCounts = crunchedData.max;
    return minCounts == maxCounts;
  }

  static get numberOfGamesPlayed => gruppe.map((x) => x.punkte.length).isEmpty ?
  0 : gruppe.map((x) => x.punkte.length).min;

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
      var sumOfPoints = gruppe.map((x) => x.sumPoints);
      var best = _leastPointsWinning? sumOfPoints.min : sumOfPoints.max;
      return gruppe.where((x)=> x.sumPoints == best).toList();
    }
    return <Teilnehmer>[];
  }

  static String report(){
    final now = DateTime.now();
    final String headline = "${Locales.results[Lang.l]} - ${DateFormat('dd.MM.yyyy').format(now)}\n\n";
    StringBuffer buffer = StringBuffer(headline);
    
    for(Teilnehmer player in gruppe){
      buffer.write("${player.name}:\t${player.sumPoints}\n");
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

  num get sumPoints => punkte.sum;
  num? get avgPoints => punkte.isNotEmpty ? punkte.average : null;
  num? get minPoints => punkte.isNotEmpty ? punkte.min : null;
  num? get maxPoints => punkte.isNotEmpty ? punkte.max : null;
  int? get countZeros => punkte.isNotEmpty ? punkte.where((i) => i == 0).length : null;
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
