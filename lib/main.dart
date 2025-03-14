// ignore_for_file: prefer_adjacent_string_concatenation
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import './table.dart';
import './settings.dart';
import './calc.dart';
import './locales.dart';
import './styles.dart';

void main() {
  Spieler.settings();
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  //SettingsAppWidget settingsPage = const SettingsAppWidget();
  const MyApp({super.key});
  //final TableExampleApp punkteTabelle = const TableExampleApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Punktspiel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Punktspiel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //Each editable field needs their controller.
  //Otherwise, stuff happens, such as that a name appears in a number field.
  final TextEditingController numberFieldController = TextEditingController();
  final TextEditingController namesFieldController = TextEditingController();
  final TextEditingController selectableNamesMenuController = TextEditingController();
  final EdgeInsets edgeInsets = const EdgeInsets.all(12);
  final double? buttonHeight = 30;

  int selectedPlayerPoints = 0;
  int whoseTurnIndex = 0;
  int whoseFirstTurnIndex = 0;
  String selectedPlayerName = Spieler.names.first;

  bool dontEditNames = false;

  Widget buildselectableNamesMenu(){
    //var dropdown = 
    return DropdownButton<String>(
      key: ValueKey(Object.hashAll(Spieler.names)),
      isExpanded: true,
      padding: edgeInsets,
      value: selectedPlayerName,
      onChanged: (String? value){
        setState((){ selectedPlayerName = value ?? ""; });
      },
      items: Spieler.names.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value, child: Text(value));
        }).toList(),
    );
  }

  Widget buildselectLanguagesMenu({bool wellBehaving = true}){
    if(wellBehaving){
      return DropdownButton<String>(
      key: ValueKey(Object.hashAll(Lang.availableLanguages)),
      isExpanded: true,
      value: Lang.currentLanguageCode(),
      padding: edgeInsets,
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
    else{
      return const SizedBox(width: 50, child: Text(" [tbd]"));
    }
  }

  Widget buildpointsWinningSwitch() {
   return DropdownButton<String>(
      key: ValueKey(Object.hashAll(Locales.pointsRule[Lang.l])),
      isExpanded: true,
      value: Locales.pointsRule[Lang.l][Spieler.leastPointsWinning ? 0 : 1],
      padding: const EdgeInsets.symmetric(horizontal: 3), // Adjust padding
      onChanged: (String? value){
        dontEditNames ? null :
        setState(
          () => Spieler.leastPointsWinning = (value == Locales.pointsRule[Lang.l].first)
        );
      },
      items: Locales.pointsRule[Lang.l].map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      menuWidth: 100,
   );
  }

  _MyHomePageState();
  TableExampleApp punkteTabelle = const TableExampleApp();
  SettingsAppWidget settingsPage = const SettingsAppWidget();
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      whoseTurnIndex = (whoseFirstTurnIndex + _counter) % Spieler.names.length;
    });
  }

  void _decrementCounter() {
    if(_counter>0) {
      setState(() {
        _counter--;
        whoseTurnIndex = (whoseFirstTurnIndex + _counter) % Spieler.names.length;
      });
    }
  }

  Future<void> submitPoints() async {
    // Validating names list
    if(!dontEditNames){
      var namesList = namesFieldController.text.split(",");
      if(namesList.length < 2){
        bool onlyOnePlayer = await _showYesNoDialog(
          Locales.noColon[Lang.l].format([namesFieldController.text])
        );
        if(!onlyOnePlayer){
          setState(() {
            numberFieldController.clear();
            selectedPlayerPoints = 0;
          });
          return;
        }
      }
      setState(() => dontEditNames = true);
    }

    // Validating and submitting points
    if (Spieler.fillingTwice(selectedPlayerName)){
      var empty = Spieler.whoIsEmpty();
      _showAlertDialog(
        "${Locales.noSecondEntry[Lang.l].format([selectedPlayerName])}\n"
          + "${Locales.hint[Lang.l]} ${empty.join(', ')}"
      );
      return;
    }
    Spieler.addPoints(selectedPlayerName, selectedPlayerPoints);
    setState(() {
      numberFieldController.clear();
      selectedPlayerPoints = 0;
    });
    if(Spieler.filledFullRound()){
      _incrementCounter();
    }
  }

  void _finishEditingNames(String newText){
    List<String> names = newText.split(",")
      .map((x)=> x.trim()).toList()
      .where((x) => x != "").toList();
    if(names.isNotEmpty) {
      if(names.toSet().length < names.length){
        _showAlertDialog(Locales.foundDuplicateName[Lang.l]);
        return;
      }
      Spieler.names = names;
      selectedPlayerName = Spieler.names.first;
      setState(() => {});
    }
  }

  void setOpener(){
    if(!dontEditNames){
      setState(() {
        whoseFirstTurnIndex = Spieler.names.indexOf(selectedPlayerName);
        whoseTurnIndex = whoseFirstTurnIndex;
      });
    }
  }
  void closeKbd(){
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showAlertDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            CupertinoButton(
              child: Text(Locales.gotIt[Lang.l]),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showYesNoDialog(String message) async {
    final answer = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            CupertinoButton(
              child: Text(Locales.answerYes[Lang.l]),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            CupertinoButton(
              child: Text(Locales.answerNo[Lang.l]),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ), 
          ],
        );
      },
    );
    return answer ?? false;
  }

  void showPoints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => punkteTabelle,
      )
    );
  }

  void deleteLastEntry() {
    bool rowWasJustFilled = Spieler.filledFullRound();
    Spieler.deleteLastEntry(selectedPlayerName);
    if(rowWasJustFilled){
      _decrementCounter();
    }
  }

  void deleteEverything() {
    for(Teilnehmer t in Spieler.gruppe){
      t.punkte.clear();
      _counter = 0;
    }
    setState(() { dontEditNames = false;});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: closeKbd,
      //onDoubleTap: () => {},
      //onLongPress: () => {},
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(backgroundColor: Colors.amber, title: Text(widget.title),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children:[
              SizedBox(
              // Open settings
              width: 70,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => settingsPage),
                );
              },
              style: ButtonStyle(backgroundColor: Themes.sunflower),
              child: const Icon(Icons.settings),
            ),),
            ]),
            Row(children: [
              Container(
                margin: const EdgeInsets.all(7),
                alignment: Alignment.bottomRight,
                width: 30,
                child: const Icon(Icons.language),
              ),
              SizedBox(width: 111, child: buildselectLanguagesMenu(),),
              const Text("Gewinn: "),
              SizedBox(width: 111, child: buildpointsWinningSwitch(),),
            ],
            ),
            Row(
              children: [
                Container(
                  margin: edgeInsets,
                  width: 60,
                  child: Text(Locales.playedRounds[Lang.l]),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  width: 42,
                  child: Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  margin: edgeInsets,
                  //width: 120,
                  child: Text(
                    (whoseTurnIndex < Spieler.names.length)?
                    Locales.opener[Lang.l]
                    .format([
                      Spieler.names[whoseTurnIndex].truncate(10)
                    ]) : "< empty >"
                  ),
                ),
              ],
            ),
            //
            Container( 
              margin: edgeInsets,
              //height: 100,
              //width: 100,
              child: TextField(
                controller: namesFieldController,
                readOnly: dontEditNames,
                //onChanged Ereignis updated automatisch den angezeigten Text
                onSubmitted: (newText) => _finishEditingNames(newText),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: Locales.players[Lang.l],
                  isDense: true,
                ),
                //keyboardType: TextInputType.text,
              ),
            ),
            Row(
              children: <Widget>[
              Container( 
              margin: edgeInsets,
              //height: 100,
              width: 150,
              child: TextField(
                controller: numberFieldController,
                //onChanged Ereignis updated automatisch den angezeigten Text
                onChanged: (newText) {selectedPlayerPoints = int.tryParse(newText) ?? 0;},
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: Locales.points[Lang.l],
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
              ),
              SizedBox(
              // Whose turn
              width: 70,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: setOpener,
              style: ButtonStyle(backgroundColor: Themes.green),
              child: const Icon(Icons.chair),
            ),),
            const SizedBox(width:10),
            SizedBox(
                width: 70,
                height: buttonHeight,
                child: ElevatedButton(
                onPressed: deleteLastEntry,
                style: ButtonStyle(backgroundColor: Themes.pumpkin),
                child: const Icon(Icons.delete),
              ),),
            ],
            ),
            buildselectableNamesMenu(),
            SizedBox(
              width: 150,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: submitPoints,
              style: ButtonStyle(backgroundColor: Themes.sunflower),
              child: Text(Locales.submit[Lang.l]),
            ),),
            const SizedBox(height:20),
            SizedBox(
              width: 150,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: showPoints,
              style: ButtonStyle(backgroundColor: Themes.green),
              child: Text(Locales.results[Lang.l]),
            ),),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: deleteEverything,
              style: ButtonStyle(backgroundColor: Themes.pumpkin),
              child: Text(Locales.deleteAllResults[Lang.l]),
            ),),
            const SizedBox(height: 20),
            // Test Website Access
            ElevatedButton.icon(
              onPressed: _launchURL,
              icon: const Icon(Icons.favorite),
              label: const Text('Support me on Ko-fi', style: TextStyle(fontSize: 12.0)              ),
              style: ButtonStyle(backgroundColor: Themes.greenish),
            )
          ],
        ),
      ),
    ),
    );
  }

  _launchURL() async {
   final Uri url = Uri.parse('https://ko-fi.com/danielagrothe');
   if (!await launchUrl(url, webOnlyWindowName: "Web Title")) {
      _showAlertDialog(Locales.isOffline[Lang.l]);
   }
  }
}