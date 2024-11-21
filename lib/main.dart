import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './table.dart';
import './calc.dart';
import './locales.dart';

void main() {
  Spieler.settings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //final TableExampleApp punkteTabelle = const TableExampleApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punktspiel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Punktspiel'),
      /*routes: {
        "punktestand" : (context) => punkteTabelle
      },*/
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
  //Each editable field needs their controller.
  //Otherwise, stuff happens, such as that a name appears in a number field.
  final numberFieldController = TextEditingController();
  final namesFieldController = TextEditingController();
  final selectableNamesMenuController = TextEditingController();
  final selectLanguageController = TextEditingController();
  final EdgeInsets edgeInsets = const EdgeInsets.all(12);

  int myPoints = 0;
  int whoseTurnIndex = 0;
  int whoseFirstTurnIndex = 0;
  double? buttonHeight = 30;
  String selectedPlayerName = Spieler.names.first;

  bool dontEditNames = false;

  Widget buildselectableNamesMenu(){
    var dropdown = DropdownButton<String>(
      key: ValueKey(Object.hashAll(Spieler.names)),
      isExpanded: true,
      value: selectedPlayerName,
      onChanged: (String? value){
        setState((){
          selectedPlayerName = value ?? "";
        });
        
      },
      items: Spieler.names.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
    );
    return Container(
      margin: edgeInsets,
      //padding: edgeInsets,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      width: double.infinity,
      //child: dropdown,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color.fromARGB(255, 249, 208, 83), // background color for the dropdown items
          buttonTheme: ButtonTheme.of(context).copyWith(
          alignedDropdown: true,  //If false (the default), then the dropdown's menu will be wider than its button.
        )),
        child: dropdown
      )
    );
  }

  Widget buildselectLanguagesMenu({bool wellBehaving = true}){
    if(wellBehaving){
      return DropdownMenu<String>(
      key: ValueKey(Object.hashAll(Lang.availableLanguages)),
      requestFocusOnTap: true,
      enableSearch: true,
      controller: selectLanguageController,
      initialSelection: Lang.availableLanguages.first,
      expandedInsets: edgeInsets,
      onSelected: (String? value){
        setState(() => Lang.setLanguage(value ?? "EN"));
      },
      dropdownMenuEntries: Lang.availableLanguages.map<DropdownMenuEntry<String>>(
        (String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
      width: 100,
      );
    }
    else{
      return const SizedBox(width: 50, child: Text(" [tbd]"));
    }
  }

  _MyHomePageState();
  TableExampleApp punkteTabelle = const TableExampleApp();
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
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

  void submitPoints() {
    if(!dontEditNames){
      setState(() => dontEditNames = true);
    }
    if (!Spieler.fillingTwice(selectedPlayerName)) {
      Spieler.addPoints(selectedPlayerName, myPoints);
      if(Spieler.filledFullRound()){
        _incrementCounter();
      }
    }
    else{
      var empty = Spieler.whoIsEmpty();
      _showAlertDialog(
        "${Locales.noSecondEntry[Lang.l].format([selectedPlayerName])}\n${Locales.hint[Lang.l]} ${empty.join(', ')}"
      );
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        //Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Container(
                  margin: edgeInsets,
                  width: 60,
                  child: Text(Locales.playedRounds[Lang.l]),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  width: 20,
                  child: Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Container(
                  margin: edgeInsets,
                  width: 80,
                  child: Text(Locales.opener[Lang.l]
                    .format([Spieler.names[whoseTurnIndex].truncate(10)]
                    )),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  width: 30,
                  child: const Icon(Icons.language),
                ),
                SizedBox(
                  width: 111,
                  child: buildselectLanguagesMenu(),
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
                onChanged: (newText) {
                  List<String> names = newText.split(",")
                    .where((x) => x != "").toList();
                  if(names.length > 1) {
                    Spieler.names = names.map((x)=> x.trim()).toList();
                    selectedPlayerName = Spieler.names.first;
                    setState(() => {});
                  }
                },
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
                onChanged: (newText) {myPoints = int.tryParse(newText) ?? 0;},
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
              width: 80,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: setOpener,
              style: ButtonStyle(
                padding: 
                WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                  (Set<WidgetState> states) {
                return const EdgeInsets.all(7);
              },),
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 87, 228, 141)
                ),
              ),
              child: const Icon(Icons.chair),
            ),),
            const SizedBox(width:10),
            SizedBox(
                width: 80,
                height: buttonHeight,
                child: ElevatedButton(
                onPressed: deleteLastEntry,
                style: ButtonStyle(
                  padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                    (Set<WidgetState> states) {
                  return const EdgeInsets.all(7);
                  },),
                  backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 230, 124, 75)
                  ),
                ),
                child: const Icon(Icons.delete),
              //Text(Locales.deleteLastEntry[l]),
              ),),
            ],
            ),
            buildselectableNamesMenu(),
            SizedBox(
              width: 150,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: submitPoints,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 243, 198, 76)
                ),
              ),
              child: 
              //const Icon(Icons.check_box),
              Text(Locales.submit[Lang.l]),
            ),),
            const SizedBox(height:20),
            SizedBox(
              width: 150,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: showPoints,
              style: ButtonStyle(
                padding: 
                WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                  (Set<WidgetState> states) {
                return const EdgeInsets.all(7);
              },),
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 87, 228, 141)
                ),
              ),
              child: Text(Locales.results[Lang.l]),
            ),),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: buttonHeight,
              child: ElevatedButton(
              onPressed: deleteEverything,
              style: ButtonStyle(
                padding: 
                WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                  (Set<WidgetState> states) {
                return const EdgeInsets.all(7);
              },),
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 230, 124, 75)
                ),
              ),
              child: Text(Locales.deleteAllResults[Lang.l]),
            ),),
          ],
        ),
      ),
    ),
    );
  }
}