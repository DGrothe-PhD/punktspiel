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
