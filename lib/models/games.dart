import 'package:punktspiel/locales.dart';

class Game{
  final String name;
  final Map<String, String>? translated;
  bool? leastPointsWinning;

  Game({
    required this.name,
    this.leastPointsWinning,
    this.translated,
  });

  String get localName {
    if(translated?.containsKey(Lang.currentLanguageCode()) ?? false){
      return translated![Lang.currentLanguageCode()] ?? name;
    }
    return name;
  }
}

extension HandleListGames on List<Game> {
  get keys => map((e) => e.name).toList();
  Game lookup(String key) => firstWhere((e) => e.name == key, orElse: null);
}


class Features{
  // singleton pattern as described in  https://dev.to/lucianojung/global-variable-access-in-flutter-3ijm

  final List<Game> games = [
    Game(
      name: "Rummy",
      leastPointsWinning: true,
      translated: {"de": "Rommee", "en": "Rummy", "fr" : "Rami"},
    ),
    Game(
      name: "Scrabble",
      leastPointsWinning: false,
    ),
    Game(
      name: "Table tennis",
      leastPointsWinning: false,
      translated: {"de": "Tischtennis", "en": "Table tennis", "fr" : "Ping-pong"},
    ),
    Game(
      name: "Miscellaneous",
      leastPointsWinning: null,
      translated: {"de": "Verschiedenes", "en": "Miscellaneous", "fr" : "Un jeu de votre choix"},
    ),
  ];


  static final Features _instance = Features._internal();

  Features._internal();

  // passes the instantiation to the _instance object
  factory Features() => _instance;

}