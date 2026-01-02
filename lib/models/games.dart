//import 'package:collection/collection.dart';
//import 'package:punktspiel/locales.dart';

import 'package:punktspiel/generated/l10n.dart';

class Game{
  final GameKey key;
  final bool? leastPointsWinning;

  Game({
    required this.key,
    this.leastPointsWinning,
  });
}

/*extension HandleListGames on List<Game> {
  get keys => map((e) => e.name).toList();
  Game? lookup(String key) => firstWhereOrNull((e) => e.name == key);
}*/

/*
Legacy suggestion
Game? lookup(String key) => firstWhere(
      (e) => e.name == key,
      orElse: () => null,
    );
*/

enum GameKey{
  rummy, scrabble, tabletennis, misc
}

extension GameKeyL10n on GameKey {
  String l10n(S locale) {
    switch (this) {
      case GameKey.rummy:
        return locale.Rummy;
      case GameKey.scrabble:
        return locale.Scrabble;
      case GameKey.tabletennis:
        return locale.TableTennis;
      default:
        return locale.Miscellaneous;
    }
  }
}

class Features{
  // singleton pattern as described in  https://dev.to/lucianojung/global-variable-access-in-flutter-3ijm

  /*List<Game> games = [
    Game(
      name: "Rummy",
      leastPointsWinning: true,
      translatedName: locale.Rummy,//gonna do this
      //translated: {"de": "Rommee", "en": "Rummy", "fr" : "Rami"},
    ),
    Game(
      name: "Scrabble",
      leastPointsWinning: false,
      translatedName: "tbd",
    ),
    Game(
      name: "Table tennis",
      leastPointsWinning: false,
      //translated: {"de": "Tischtennis", "en": "Table tennis", "fr" : "Ping-pong"},
    ),
    Game(
      name: "Miscellaneous",
      leastPointsWinning: null,
      translatedName: "tbd",
      //translated: {"de": "Verschiedenes", "en": "Miscellaneous", "fr" : "Un jeu de votre choix"},
    )
  ];*/

  final Map<GameKey, Game> games = {
    GameKey.rummy: Game(
      key: GameKey.rummy,
      leastPointsWinning: true,
    ),
    GameKey.scrabble: Game(
      key: GameKey.scrabble,
      leastPointsWinning: false,
    ),
    GameKey.tabletennis: Game(
      key: GameKey.tabletennis,
      leastPointsWinning: false,
    ),
    GameKey.misc: Game(
      key: GameKey.misc,
      leastPointsWinning: null,
    ),
  };

  static final Features _instance = Features._internal();

  Features._internal();

  // passes the instantiation to the _instance object
  factory Features() => _instance;

}