//tbd
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:flutter_html/flutter_html.dart';
import './locales.dart';
import './styles.dart';

class SettingsAppWidget extends StatelessWidget {
  const SettingsAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : true,
        appBar: AppBar(backgroundColor: Colors.amber,
         title: Text(Locales.settingsTitle[Lang.l]),
        ),
        body: 
        const SingleChildScrollView(
          child: MySettingsPage(),
        )
    );
    // reduce to the max. Returning MaterialApp shows black screen...
  }
}

class MySettingsPage extends StatefulWidget{
  const MySettingsPage({super.key});
  @override
  MySettingsPageState createState() => MySettingsPageState();
}

class MySettingsPageState extends State<MySettingsPage> {
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

  Widget buildselectLanguagesMenu({bool wellBehaving = true}){
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
  Future<String> fetchLatestAppVersionDetails() async {
    String currentVersionInfo = "";
    try{
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      String releaseTag = "build v0.0.16beta";//packageInfo.packageName;
      String version = "";// packageInfo.version;
      String buildNumber = "";//packageInfo.buildNumber;
      currentVersionInfo = "$appName $releaseTag\n$version $buildNumber";
    }
    catch(exception){
      currentVersionInfo += "Version info could not be found.";
    }
    try{
      final response = await http.get(
      Uri.parse('https://api.github.com/repos/DGrothe-PhD/punktspiel/releases/latest')
      );
    
    if(response.statusCode == 200){
      Map<String, dynamic> json = jsonDecode(response.body);
      String tagName = json['tag_name'];
      String publishedAt = json['published_at'];
      return "Installed:\n$currentVersionInfo\n\n" 
      "Latest version: $tagName\nPublished at: $publishedAt\n";
    }
    else{
      throw HttpException(Locales.isOffline[Lang.l]);
    }
    }
    catch(exception){
      return Locales.isOffline[Lang.l];
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return PopScope(
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if(didPop){
            return;
          }
          Navigator.pop(context, true);
          //return false;
        },
        child: 
        Center(
        child: SwipeTo(
          onRightSwipe: (details) => {Navigator.pop(context, true)},
          child: Column(
            children: <Widget>[
              Row(
                children:<Widget>[
                  const Icon(Icons.language),
                  SizedBox(width: 111, child: buildselectLanguagesMenu(),),
              ],),
            const SizedBox(height:177),
            FutureBuilder<String>(
              future: fetchLatestAppVersionDetails(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const CircularProgressIndicator();
                }
                if(snapshot.hasError){
                  return Text("Error: ${snapshot.error}");
                }
                return Text("${snapshot.data}");
              },
            ),
            //Text(latestAppVersion),
            SizedBox(
              width: 120,
              //height: 50,
              child: ElevatedButton(
                onPressed: () {setState(() => Navigator.pop(context, true));},
                style: ButtonStyle(
                  backgroundColor: Themes.green,
                ),
                child: Text(Locales.close[Lang.l]),
              ),
            ),
          ]
          )
        ),
        )
      );  
  }
    on HttpException catch(e){
      return Text(e.toString());
    }
    catch (exception){
      return Text(exception.toString());
  }
}

}