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
  lookup(String key) => firstWhere((e) => e.name == key, orElse: null);
}

/*class AvailableGames{
  static final List<Game> games = [
    Game(name: "Rummy", leastPointsWinning: true),
    Game(name: "Scrabble", leastPointsWinning: false),
    Game(name: "Table tennis", leastPointsWinning: false),
    Game(name: "Miscellaneous", leastPointsWinning: null),
  ];
}*/