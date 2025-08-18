class Game{
  String name;
  bool? leastPointsWinning;

  Game({
    required this.name,
    this.leastPointsWinning,
  });
}

extension HandleListGames on List<Game> {
  get keys => map((e) => e.name).toList();
  lookup(String key) => firstWhere((e) => e.name == key, orElse: null);
}

/*
static const Map<String, bool?> games = {
    "Rummy": true, "Scrabble": false,
    "Table tennis": false,
    "Miscellaneous": null
  };
*/

/*class AvailableGames{
  static final List<Game> games = [
    Game(name: "Rummy", leastPointsWinning: true),
    Game(name: "Scrabble", leastPointsWinning: false),
    Game(name: "Table tennis", leastPointsWinning: false),
    Game(name: "Miscellaneous", leastPointsWinning: null),
  ];
}*/