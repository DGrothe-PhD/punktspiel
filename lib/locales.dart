//import 'package:collection/collection.dart';

import 'package:intl/intl.dart';
import 'package:punktspiel/preferences/mysharedpreferences.dart';

// I know that officially this is done differently, however, this is a MVP.
// Just to let English-speaking people use and understand my little app as well.
class Lang{
  static int l = 0;
  static List<String> availableLanguages = ["de", "en", "fr"];

  static void setLanguage(String code){
    MySharedPreferences.saveLanguage(code);
    _applyLanguage(code);
  }

  static void _applyLanguage(String? code){
    switch(code) {
      case "de":
        l = 0;
      case "en":
        l = 1;
      case "fr":
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
      code = "en";
    }
    _applyLanguage(code);
  }
}


class Locales {
  static const List<String> opener = ["%s fängt an", "%s starts", "%s commence"];
  static const List<String> points = ["Punkte:", "Points:", "Points :"];
  //
  static const List<String> deletePlayer = ["Spieler %s löschen?", "Delete player %s?", "Effacer joueur/se %s ?"];
  static const List<String> undo = ["Widerrufen", "Undo", "Annuler"];
  static const List<String> deleteAllResults = ["Alles löschen", "Delete it all", "Tout effacer"];
  //
  static const List<String> close = ["Schließen", "Close view", "Fermer"];
  static const List<String> results = ["Ergebnisse", "Results", "Les résultats"];
  static const List<String> settingsTitle = ["Einstellungen", "Settings", "Configurer"];
  static const List<String> furtherSettingsTitle = ["Weitere Einstellungen", "More settings", "Autres paramètres"];
  static const List<String> nextRound = ["Neue Runde", "Next Round", "Encore une fois"];

  static const List<String> overviewTabTitle = ["Punktevergabe", "Collecting points", "Donner les points"];
  static const List<String> gameModeTabTitle = ["Spielmodus", "Game mode", "Mode de jeu"];
  static const List<String> clearNameField = ["Text löschen", "Clear field", "Effacer ce texte"];
  static const List<String> helpTitle = ["Anleitung", "How to use this app", "Mode d'emploi"];
  static const List<String> resultsTitle = ["Spielstand", "Results", "Les résultats"];
  static const List<String> aboutTitle = ["Über die App", "About this app", "A propos de l'application"];
  static const List<String> showTable = ["Spielstand", "Show results", "Les résultats"];
  static const List<String> hideTable = ["Zurück", "Back", "Retourner"];
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
  static const List<String> shareEverything = ["Tabelle teilen", "Share all", "Partager tout"];
  static const List<String> shareResults = ["Ergebnis teilen", "Share result", "Partager le résultat"];
  static const List<String> emailSubject = [
    "Unsere Spielergebnisse", "Our game results", "Notres résultats de jeu"
  ];
}