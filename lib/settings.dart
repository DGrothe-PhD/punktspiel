import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:punktspiel/locales.dart';
import 'package:punktspiel/styles.dart';

class SettingsAppWidget extends StatelessWidget {
  const SettingsAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : true,
      appBar: AppBar(backgroundColor: Colors.amber,
        title: Text(Locales.settingsTitle[Lang.l]),
      ),
      body: const SingleChildScrollView(
        child: MySettingsPage(),
      )
    );
  }
}

class MySettingsPage extends StatefulWidget{
  const MySettingsPage({super.key});
  @override
  MySettingsPageState createState() => MySettingsPageState();
}

class MySettingsPageState extends State<MySettingsPage> {
  String currentVersionInfo = "";
  String availableVersionInfo = "";
  final now = DateTime.now();

  //SettingsPage({super.key});
  //late String latestAppVersion;

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Widget buildSelectLanguagesMenu({bool wellBehaving = true}){
    return DropdownButton<String>(
    key: ValueKey(Object.hashAll(Lang.availableLanguages)),
    isExpanded: true,
    value: Lang.currentLanguageCode(),
    onChanged: (String? value){
      setState(() => Lang.setLanguage(value ?? "EN"));
    },
    items: Lang.availableLanguages.map<DropdownMenuItem<String>>(
      (String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    menuWidth: 100,
    );
  }
  
  //Network Request to get latest release version of this app.
  void getLatestAppVersionDetails() async {
    currentVersionInfo = "";
    availableVersionInfo = "";
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
        setState(() {
          availableVersionInfo = "Installed:\n$currentVersionInfo\n\n" 
          "Latest version: $tagName\nPublished at: $publishedAt\n";
        });
      }
      else{
        throw HttpException(Locales.isOffline[Lang.l]);
      }
    }
    catch(exception){
      availableVersionInfo = Locales.isOffline[Lang.l];
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Center(
        child: Column(
        children: <Widget>[
          Row(
        children:<Widget>[
          const Icon(Icons.language),
          const Text("\xA0"),
          SizedBox(width: 111, child: buildSelectLanguagesMenu(),),
          ],),
          const SizedBox(height:177),
          availableVersionInfo.isNotEmpty ? Text(availableVersionInfo) : const Text("…"),
          // for FutureBuilder things look into GH history
          ElevatedButton(
            onPressed: //() {},
            getLatestAppVersionDetails,
            style: Themes.cardButtonStyle(Themes.green, fixedSize: Themes.mediumButtonWidth),
            child: const Text("Version Info"),
          ),
        ]
      ));  
    }
  on HttpException catch(e){
      return Text(e.toString());
  }
  catch (exception){
    return Text(exception.toString());
  }
}

}