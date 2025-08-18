import 'package:shared_preferences/shared_preferences.dart';
import 'package:punktspiel/locales.dart';

class UserSettings {
  String? dateTime = Lang.deDateFormat.format(DateTime.now());
  //final int age;
  //final bool isDarkMode;
  final List<String>? names;
  final String? game;
  final bool? leastPointsWinning;
  final int? numberOfGamesPlayed;
  final List<int>? sumOfPoints;

  UserSettings({
    String? dateTime,
    //required this.isDarkMode,
    required this.names,
    required this.game,
    required this.numberOfGamesPlayed,
    required this.leastPointsWinning,
    required this.sumOfPoints,
  });

  void verboseTesting(){
    StringBuffer sb = StringBuffer();
    sb.write("$dateTime\n");
    sb.write("${names!.join(", ")}\n");
    sb.write("${sumOfPoints!.map((i) => i.toString()).toList().join(", ")}\n");
    // ignore: avoid_print
    print(sb.toString());
  }
}

class MySharedPreferences {
  // Language
  static Future<void> saveLanguage(String code) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
  }

  static Future<String?> getLanguage() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('languageCode');
  }

  static Future<void> saveLeastPointsWinning(bool value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('leastPointsWinning', value);
  }

  static Future<bool?> getLeastPointsWinning() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('leastPointsWinning');
  }

  // Player names
  static Future<void> saveNames(List<String> names) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('names', names);
  }

  static Future<List<String>?> getNames() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('names');
  }

  // Game
  static Future<void> saveGame(String? game) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('game', game ?? "");
  }

  static Future<String?> getGame() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('game');
  }

  // General data (game results)
  static Future<void> saveData(UserSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateTime', settings.dateTime ?? "----");
    //await prefs.setBool('isDarkMode', settings.isDarkMode);
    await prefs.setStringList('names', settings.names ?? List.empty());
    await prefs.setString('game', settings.game ?? "");
    await prefs.setInt('numberOfGamesPlayed', settings.numberOfGamesPlayed ?? 0);
    await prefs.setBool('leastPointsWinning', settings.leastPointsWinning ?? true);
    await prefs.setStringList(
        'sumOfPoints',
        settings.sumOfPoints?.map((i) => i.toString()).toList() ??
            List.empty());
  }

  static Future<UserSettings?> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //final isDarkMode = prefs.getBool('isDarkMode');
    String? dateTime = prefs.getString('dateTime');
    List<String>? names = prefs.getStringList('names');
    String? game = prefs.getString('game');
    int? numberOfGamesPlayed = prefs.getInt('numberOfGamesPlayed');
    bool? leastPointsWinning = prefs.getBool('leastPointsWinning');
    List<String>? sumOfPoints = prefs.getStringList('sumOfPoints');

    return UserSettings(
      dateTime: dateTime,
      names: names,
      game: game,
      numberOfGamesPlayed: numberOfGamesPlayed,
      leastPointsWinning: leastPointsWinning,
      sumOfPoints: sumOfPoints?.map((i) => int.tryParse(i) ?? 0).toList(),
    );
  }

  static Future<void> removeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dateTime');
    await prefs.remove('names');
    //await prefs.remove('game');
    //await prefs.remove('leastPointsWinning');
    await prefs.remove('sumOfPoints');
    // etc wird schon.
  }

  static Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
