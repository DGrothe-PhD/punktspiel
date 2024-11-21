//import 'package:collection/collection.dart';

// I know that officially this is done differently, however, this is a MVP.
// Just to let English-speaking people use and understand my little app as well.
class Lang{
  static int l = 0;
  static List<String> availableLanguages = ["DE", "EN", "FR"];

  static void setLanguage(String code){
    switch(code) {
      case "DE":
        l = 0;
      case "FR":
        l = 2;
      default:
        l = 1;
    }
  }
}


class Locales {
  //static int i = 0;
  static const List<String> noSecondEntry = [
    "Punkte für %s sind schon eingetragen.",
    "Points for %s already submitted for this round.",
    "Les points pour %s sont déjà inscrits."
  ];
  
  static const List<String> hint = [
    "Hinweis: Punkte fehlen für ", "Hint: Missing results for ",
    "Remarque : il manque des points pour"
    ];
  static const List<String> gotIt = ["Verstanden!", "Got it!", "Compris !"];
  static const List<String> playedRounds = ["Gespielt:", "Played:", "Joué :"];
  static const List<String> players = ["Teilnehmer:", "Players:", "Joueurs :"];
  static const List<String> opener = ["%s fängt an", "%s starts", "%s commence"];
  static const List<String> points = ["Punkte:", "Points:", "Points :"];
  //
  static const List<String> submit = ["Eintragen", "Submit", "Inscrire"];
  static const List<String> deleteLastEntry = ["Letzten löschen", "Delete last", "Effacer le dernier"];
  static const List<String> deleteAllResults = ["Alles löschen", "Delete everything", "Tout effacer"];
  //
  static const List<String> close = ["Schließen", "Close view", "Fermer"];
  static const List<String> results = ["Ergebnisse", "Results", "Les résultats"];
  static const List<String> nextRound = ["Neue Runde", "Next Round", "Encore une fois"];
  static const List<String> resultsTitle = ["SPIELSTAND", "RESULTS", "RESULTATS"];
  static const List<String> pointsTotal = ["Punkte insgesamt:", "Sum of points:", "Somme de points :"];
}