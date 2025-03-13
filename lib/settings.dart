//tbd
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_html/flutter_html.dart';
import './locales.dart';
import './styles.dart';

class SettingsAppWidget extends StatelessWidget {
  const SettingsAppWidget({super.key});
  // how to update the table?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : true,
        body: 
        SingleChildScrollView(
          child: MySettingsPage(title: Locales.settingsTitle[Lang.l]),
        )
    );
    // reduce to the max. Returning MaterialApp shows black screen...
  }
}

class MySettingsPage extends StatefulWidget{
  const MySettingsPage({super.key, required this.title});
  final String title;
  @override
  MySettingsPageState createState() => MySettingsPageState();
}

class MySettingsPageState extends State<MySettingsPage> {
  final now = DateTime.now();
  //SettingsPage({super.key});
  //late String latestAppVersion;

  @override
  initState(){
    super.initState();
  }

  //Network Request to get latest release version of this app.
  Future<String> fetchLatestAppVersionDetails() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/DGrothe-PhD/punktspiel/releases/latest')
    );
    if(response.statusCode == 200){
      Map<String, dynamic> json = jsonDecode(response.body);
      String tagName = json['tag_name'];
      String publishedAt = json['published_at'];
      return "Latest version: $tagName\nPublished at: $publishedAt\n";
    }
    else{
      throw HttpException(Locales.isOffline[Lang.l]);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Center(
        child: SwipeTo(
          onRightSwipe: (details) => {Navigator.pop(context)},
          child: Column(
            children: <Widget>[
            const Text("… coming soon …"),
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
                onPressed: () {Navigator.pop(context);},
                style: ButtonStyle(
                  backgroundColor: Themes.green,
                ),
                child: Text(Locales.close[Lang.l]),
              ),
            ),
          ]
          )
        ),
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