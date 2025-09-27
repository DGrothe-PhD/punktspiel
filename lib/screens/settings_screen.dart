import 'dart:io';
//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;
//import 'package:package_info_plus/package_info_plus.dart';
import 'package:punktspiel/locales.dart';
import 'package:punktspiel/styles.dart';

import 'package:punktspiel/preferences/mysharedpreferences.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  
  final ValueNotifier<String> selectedLanguage =
      ValueNotifier(Lang.currentLanguageCode());

  Widget _selectLanguagesMenu() {
    return ValueListenableBuilder<String>(
      valueListenable: selectedLanguage,
      builder: (context, value, child) {
        return PopupMenuButton<String>(
          onSelected: (val) {
            selectedLanguage.value = val;
            Lang.setLanguage(val);

            MySharedPreferences.androidMessage.value += 
              "${MySharedPreferences.androidMessage.value == "" ? "" : "\n"}[INFO] language changed\n";
          },
          itemBuilder: (context) => Lang.availableLanguages
              .map((lang) => PopupMenuItem(value: lang, child: Text(lang)))
              .toList(),
          child: Text(value),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : true,
      appBar: Themes.cardboardAppBar(Locales.settingsTitle[Lang.l]),
      body: SingleChildScrollView(
        child: _content(),
      )
    );
  }

  Widget _content(){
    //String currentVersionInfo = "";
    //String availableVersionInfo = "";
    //final now = DateTime.now();
    try {
      return Center(
          child: Column(children: <Widget>[
            const Text("Sprache/Language"),
        Row(
          children: <Widget>[
            const Icon(Icons.language),
            SizedBox(
              width: 111,
              child: _selectLanguagesMenu(),
            ),
          ],
        ),
        const SizedBox(height: 177),
        /*availableVersionInfo.isNotEmpty
            ? Text(availableVersionInfo)
            : const Text("…"),*/
        // for FutureBuilder things look into GH history
        /*ElevatedButton(
          onPressed: //() {},
            _getLatestAppVersionDetails,
          style: Themes.cardButtonStyle(Themes.green,
              fixedSize: Themes.mediumButtonWidth),
          child: const Text("Version Info"),
        ),*/
        ValueListenableBuilder(valueListenable: MySharedPreferences.androidMessage,
         builder: (context, message, _) {
              return Column(
                children: [
                  const Text("Debug info:"),
                  InkWell(
                    onTap: () {
                      MySharedPreferences.androidMessage.value = "";
                    },
                    child: const Text("Clear All"),
                  ),
                  SingleChildScrollView(
                    child: Text(message),
                  )
                ],
              );
            }
         ),
      ]));
    } on HttpException catch (e) {
      return Text(e.toString());
    } catch (exception) {
      return Text(exception.toString());
    }
  }
  
  //Network Request to get latest release version of this app.
  /*
  void _getLatestAppVersionDetails() async {
    String currentVersionInfo = "";
    String availableVersionInfo = "";
    try{
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      String releaseTag = "build v0.0.19beta";//packageInfo.packageName;
      String version = "";// packageInfo.version;
      String buildNumber = "";//packageInfo.buildNumber;
      currentVersionInfo = "$appName $releaseTag\n$version $buildNumber";
    }
    catch(exception){
      currentVersionInfo += "Version info could not be found.";
    }
    try{
      availableVersionInfo = Locales.isOffline[Lang.l];
      //dynamic foo = Uri.parse('https://api.github.com/repos/DGrothe-PhD/punktspiel/releases/latest');
      dynamic response = await http.get(
        Uri.parse('https://api.github.com/repos/DGrothe-PhD/punktspiel/releases/latest'), 
        headers: {'User-Agent': 'MyFlutterAppdgphd',}
      );
      if(response.statusCode == 200){
        Map<String, dynamic> json = jsonDecode(response.body);
        String tagName = json['tag_name'];
        String publishedAt = json['published_at'];
        //setState(() {
          availableVersionInfo = "Installed:\n$currentVersionInfo\n\n" 
          "Latest version: $tagName\nPublished at: $publishedAt\n";
        //});
      }
      else{
        throw HttpException(Locales.isOffline[Lang.l]);
      }
    }
    catch(exception){
      availableVersionInfo = Locales.isOffline[Lang.l];
    }
  }*/
}
