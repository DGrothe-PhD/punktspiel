import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart';

// Datum
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
    sb.write("${names?.join(", ") ?? "<names empty>"}\n");
    sb.write("${sumOfPoints?.map((i) => i.toString()).toList().join(", ") ?? '<no points given>'}\n");
    // ignore: avoid_print
    print(sb.toString());
  }
}

class MySharedPreferences {
  
  //static final MySharedPreferences _instance = MySharedPreferences._internal();

  //MySharedPreferences._internal();

  // passes the instantiation to the _instance object
  //factory MySharedPreferences() => _instance;

  static final ValueNotifier<String> androidMessage = ValueNotifier("");
  static SharedPreferencesAsync? prefs = safeGetInstanceAsync();

  /*static Future<SharedPreferences?> safeGetInstance() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      androidMessage.value += "\nCould not retrieve locally saved data. Android issue.";
      return null;
    }
  }*/

  // Testing another option
  static SharedPreferencesAsync? safeGetInstanceAsync() {
    try {
      return SharedPreferencesAsync();
    } catch (_) {
      //androidMessage.value += "\nCould not retrieve locally saved data. Android issue.\nat: ";
      return null;
    }
  }

  static void _safeGetInstanceAsyncRetryIf() {
    //! switch on when needed
    /*try {
      if(prefs != null){
        return;
      }
      for(int i=0;i<5;i++){
        final testPrefs = safeGetInstanceAsync();
        if(testPrefs != null){
          prefs = testPrefs;
          break;
        }
      }
    } catch (_) {
      androidMessage.value += "\nCould not retrieve locally saved data. Android issue.\nat: ";
      return;
    }*/
  }

  // Language
  /*/  static Future<void> saveLanguage(String code) async{
    final SharedPreferences? prefs = await safeGetInstance();
    if(prefs == null){
      androidMessage.value += "setting languageCode";
      return;
    }
    await prefs.setString('languageCode', code);
  }
  
  static Future<String?> getLanguage() async{
    final SharedPreferences? prefs = await safeGetInstance();
    if(prefs == null){
      androidMessage.value += 'getting languageCode';
      return "de";
    }
    return prefs.getString('languageCode');
  }
  */

  static Future<void> saveLanguage(String code) async{
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += "setting languageCode";
      return;
    }
    await prefs?.setString('languageCode', code).catchError(
      (err) {androidMessage.value += '$err getting languageCode';}
    );
  }

  static Future<String?> getLanguage() async{
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'getting languageCode';
      return "de";
    }
    return prefs?.getString('languageCode').catchError(
      (err) {androidMessage.value += '$err getting languageCode'; return "en";}
    );
  }

  static Future<void> saveLeastPointsWinning(bool value) async{
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'setting leastPointsWinning';
      return;
    }
    await prefs?.setBool('leastPointsWinning', value)
      .catchError((err) {androidMessage.value += 'setting leastPointsWinning';});
  }

  static Future<bool?> getLeastPointsWinning() async {
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'getting leastPointsWinning';
      return null;
    }
    return prefs?.getBool('leastPointsWinning').catchError(
      (err) {androidMessage.value += '$err getting languageCode'; return null;}
    );
  }

  // Player names
  static Future<void> saveNames(List<String> names) async{
    _safeGetInstanceAsyncRetryIf();
    await prefs?.setStringList('names', names)
      .catchError((err) {androidMessage.value += 'setting player names';});
  }

  static Future<List<String>?> getNames() async{
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'getting names';
      return null;
    }
    return prefs?.getStringList('names').catchError(
      (err) {androidMessage.value += '$err getting names'; return null;}
    );
  }

  // Game
  static Future<void> saveGame(String? game) async{
   _safeGetInstanceAsyncRetryIf();
    await prefs?.setString('game', game ?? "")
      .catchError((err) {androidMessage.value += 'setting leastPointsWinning';});
  }

  static Future<String?> getGame() async{
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'getting game';
      return null;
    }
    return prefs?.getString('game')
      .catchError((err) {androidMessage.value += 'setting leastPointsWinning'; return null;});
  }

  // General data (game results)
  static Future<void> saveData(UserSettings settings) async {
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'setting userSettings';
      return;
    }
    await prefs?.setString('dateTime', settings.dateTime ?? "----");
    //await prefs.setBool('isDarkMode', settings.isDarkMode);
    await prefs?.setStringList('names', settings.names ?? List.empty());
    await prefs?.setString('game', settings.game ?? "");
    await prefs?.setInt('numberOfGamesPlayed', settings.numberOfGamesPlayed ?? 0);
    await prefs?.setBool('leastPointsWinning', settings.leastPointsWinning ?? true);
    await prefs?.setStringList(
        'sumOfPoints',
        settings.sumOfPoints?.map((i) => i.toString()).toList() ??
            List.empty());
  }

  static Future<UserSettings?> loadData() async {
    _safeGetInstanceAsyncRetryIf();
    if (prefs == null) {
      androidMessage.value += 'getting userSettings';
      return UserSettings(
        dateTime: null,
        names: ["Username1", "Username2"],
        game: "Miscellaneous",
        numberOfGamesPlayed: 0,
        leastPointsWinning: null,
        sumOfPoints: [0, 0],
      );
    }
    //final isDarkMode = prefs.getBool('isDarkMode');
    String? dateTime = await prefs?.getString('dateTime');
    List<String>? names = await prefs?.getStringList('names');
    String? game = await prefs?.getString('game');
    int? numberOfGamesPlayed = await prefs?.getInt('numberOfGamesPlayed');
    bool? leastPointsWinning = await prefs?.getBool('leastPointsWinning');
    List<String>? sumOfPoints = await prefs?.getStringList('sumOfPoints');

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
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'removing some of data';
      return;
    }
    await prefs?.remove('dateTime');
    await prefs?.remove('names');
    //await prefs.remove('game');
    //await prefs.remove('leastPointsWinning');
    await prefs?.remove('sumOfPoints');
    // etc wird schon.
  }

  static Future<void> clearData() async {
    _safeGetInstanceAsyncRetryIf();
    if(prefs == null){
      androidMessage.value += 'remove all data';
      return;
    }
    await prefs?.clear();
  }
}
