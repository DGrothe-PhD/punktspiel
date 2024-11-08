//import 'package:collection/collection.dart';

// I know that officially this is done differently, however, this is a MVP.
// Just to let English-speaking people use and understand my little app as well.
class Lang{
  static int l = 0;
  static List<String> availableLanguages = ["DE", "EN"];

  static void setLanguage(String code){
    switch(code) {
      case "DE":
        l = 0;
      default:
        l = 1;
    }
  }
}


class Locales {
  //static int i = 0;
  static const List<String> noSecondEntry = [
    "Punkte für %s sind schon eingetragen.",
    "Points for %s already submitted for this round."
  ];
  static const List<String> hint = ["Hinweis: Punkte fehlen für ", "Hint: Missing results for "];
  static const List<String> gotIt = ["Verstanden!", "Got it!"];
  static const List<String> playedRounds = ["Gespielt:", "Played:"];
  static const List<String> players = ["Teilnehmer:", "Players:"];
  static const List<String> points = ["Punkte:", "Points:"];
  //
  static const List<String> submit = ["Eintragen", "Submit"];
  static const List<String> deleteLastEntry = ["Letzten löschen", "Delete last"];
  static const List<String> deleteAllResults = ["Alles löschen", "Delete everything"];
  //
  static const List<String> close = ["Schließen", "Close view"];
  static const List<String> results = ["Ergebnisse", "Results"];
  static const List<String> nextRound = ["Neue Runde", "Next Round"];
  static const List<String> resultsTitle = ["SPIELSTAND", "RESULTS"];
  static const List<String> pointsTotal = ["Punkte insgesamt:", "Sum of points:"];
}