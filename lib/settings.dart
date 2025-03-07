//tbd
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
//import 'package:flutter_html/flutter_html.dart';
import './locales.dart';

class SettingsAppWidget extends StatelessWidget {
  const SettingsAppWidget({super.key});
  // how to update the table?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : true,//maybe false if keyboard
        appBar: AppBar(title: Text(Locales.settingsTitle[Lang.l])),
        body: 
        SingleChildScrollView(
          child: SettingsPage(),
        )
    );
    // reduce to the max. Returning MaterialApp shows black screen...
  }
}

class SettingsPage extends StatelessWidget {
  final now = DateTime.now();
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return Center(
        child: SwipeTo(
          onRightSwipe: (details) => {Navigator.pop(context)},
          child: Column(
            children: <Widget>[
            const Text("… coming soon …"),
            const SizedBox(height:200),
            SizedBox(
              width: 120,
              //height: 50,
              child: ElevatedButton(
                onPressed: () {Navigator.pop(context);},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 63, 186, 110)
                  ),
                ),
                child: Text(Locales.close[Lang.l]),
              ),
            ),
          ]
          )
        ),
      );  
  }
    catch (exception){
      //Make exception readable.
      return Text(exception.toString());
  }
}

}