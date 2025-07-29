//import 'package:collection/collection.dart';

import 'package:intl/intl.dart';
import 'package:punktspiel/preferences/mysharedpreferences.dart';

// I know that officially this is done differently, however, this is a MVP.
// Just to let English-speaking people use and understand my little app as well.
class Lang{
  static bool tableVisible = false;

  static int l = 0;
  static List<String> availableLanguages = ["DE", "EN", "FR"];

  static void setLanguage(String code){
    MySharedPreferences.saveLanguage(code);
    _applyLanguage(code);
  }

  static void _applyLanguage(String? code){
    switch(code) {
      case "DE":
        l = 0;
      case "EN":
        l = 1;
      case "FR":
        l = 2;
      default:
        l = 1;
    }
  }

  static DateFormat deDateFormat = DateFormat('dd.MM.yyyy HH:mm');

  static String currentLanguageCode() => availableLanguages[l];

  static Future<void> initLanguage() async {
    String? code;
    try{
      code = await MySharedPreferences.getLanguage();
    }
    catch(exception) {
      code = "EN";
    }
    _applyLanguage(code);
  }
}


class Locales {
  static const List<String> noSecondEntry = [
    "Punkte für %s sind schon eingetragen.",
    "Points for %s already submitted for this round.",
    "Les points pour %s sont déjà inscrits."
  ];
  static const List<String> noColon = [
    "Ohne Komma wird „%s“ als ein Name gelesen, korrekt?",
    "Without at least one colon, ‘%s’ is read as one name. Proceed anyway?",
    "Sans virgule(s), « %s » est lu comme un seul nom, correct ?"
  ];
  
  static const List<String> hint = [
    "Hinweis: Punkte fehlen für ", "Hint: Missing results for ",
    "Remarque : il manque des points pour"
  ];
  static const List<String> foundDuplicateName = [
    "Doppelte(n) Namen gefunden", 
    "Found duplicate name(s)", 
    "Trouvé un/des double(s) nom(s)"
  ];
  static const List<String> gotIt = ["Verstanden!", "Got it!", "Compris !"];
  static const List<String> answerYes = ["Ja", "Yes", "Oui"];
  static const List<String> answerNo = ["Nein", "No", "Non"];
  static const List<String> playedRounds = ["Gespielt:", "Played:", "Joué :"];
  static const List<String> players = ["Teilnehmer:", "Players:", "Joueurs :"];
  static const List<String> opener = ["%s fängt an", "%s starts", "%s commence"];
  static const List<String> points = ["Punkte:", "Points:", "Points :"];
  //
  static const List<String> submit = ["Eintragen", "Submit", "Inscrire"];
  static const List<String> deleteLastEntry = ["Letzten löschen", "Delete last", "Effacer le dernier"];
  static const List<String> deleteAllResults = ["Alles löschen", "Delete it all", "Tout effacer"];
  //
  static const List<String> close = ["Schließen", "Close view", "Fermer"];
  static const List<String> results = ["Ergebnisse", "Results", "Les résultats"];
  static const List<String> settingsTitle = ["Einstellungen", "Settings", "Configurer"];
  static const List<String> nextRound = ["Neue Runde", "Next Round", "Encore une fois"];

  static const List<String> overviewTabTitle = ["Punktevergabe", "Collecting points", "Donner les points"];
  static const List<String> gameModeTabTitle = ["Spielmodus", "Game mode", "Mode de jeu"];
  static const List<String> resultsTitle = ["SPIELSTAND", "RESULTS", "RESULTATS"];
  static const List<String> pointsTotal = [
    "Punkte insgesamt:", "Sum of points:", "Somme de points :"
  ];
  static const List<String> winFor = ["Gewinn", "Winning", "Gagner"];
  static const List<String> best = ["Bestes Spiel:", "Best game:", "Le meilleur jeu :"];
  static const List<List<String>> pointsRule = [
    ["-- weniger", "++ mehr"],
    ["-- the least", "++ the most"],
    ["-- les moins", "++ les plus"]
  ];

  static const List<String> zeroPoints = [
    "Spiele punktlos:",
    "Games with zero points:",
    "Joué zéro points:"
  ];
  static const List<String> averagePoints = [
    "Mittelwert Punkte/Spiel:",
    "Average of points/game:",
    "La moyenne de points :"
  ];


  static const List<String> isOffline = [
    "Diese Seite kann nicht angezeigt werden.",
    "Sorry, the website cannot be displayed",
    "Cette page ne peut pas être affichée."
  ];
  static const List<String> share = ["Tabelle teilen", "Share all", "Partager tout"];
  static const List<String> shareResults = ["Ergebnis teilen", "Share result", "Partager le résultat"];
  static const List<String> emailSubject = [
    "Unsere Spielergebnisse", "Our game results", "Notres résultats de jeu"
  ];
}