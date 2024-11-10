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
  String myName = Spieler.names.first;
  bool dontEditNames = false;

Widget buildselectableNamesMenu(){
  return DropdownMenu<String>(
    key: ValueKey(Object.hashAll(Spieler.names)),
    requestFocusOnTap: true,
    enableSearch: true,
    controller: selectableNamesMenuController,
    initialSelection: Spieler.names.first,
    expandedInsets: edgeInsets,
    onSelected: (String? value){
      myName = value ?? "";
    },
    dropdownMenuEntries: Spieler.names.map<DropdownMenuEntry<String>>(
      (String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    width: 250,
    //height: 50,
  );}

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
    });
  }

  void submitPoints() {
    if(!dontEditNames){
      setState(() => dontEditNames = true);
    }
    if (!Spieler.fillingTwice(myName)) {
      Spieler.addPoints(myName, myPoints);
      //SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    else{
      var empty = Spieler.whoIsEmpty();
      _showAlertDialog(
        "${Locales.noSecondEntry[Lang.l].format([myName])}\n${Locales.hint[Lang.l]} ${empty.join(', ')}"
      );
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
    Spieler.deleteLastEntry(myName);
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
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
                  width: 100,
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
                  alignment: Alignment.bottomRight,
                  width: 42,
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
                    myName = Spieler.names.first;
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
                width: 80,
                height: 50,
                child: ElevatedButton(
                onPressed: deleteLastEntry,
                style: ButtonStyle(
                  padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                    (Set<WidgetState> states) {
                  return const EdgeInsets.all(7);
                  },),
                  backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 87, 228, 141)
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
              height: 50,
              child: ElevatedButton(
              onPressed: submitPoints,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 204, 166, 61)
                ),
              ),
              child: 
              //const Icon(Icons.check_box),
              Text(Locales.submit[Lang.l]),
            ),),
            const SizedBox(height:20),
            SizedBox(
              width: 150,
              height: 50,
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
              height: 50,
              child: ElevatedButton(
              onPressed: deleteEverything,
              style: ButtonStyle(
                padding: 
                WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                  (Set<WidgetState> states) {
                return const EdgeInsets.all(7);
              },),
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 204, 75, 11)
                ),
              ),
              child: Text(Locales.deleteAllResults[Lang.l]),
            ),),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: Locales.nextRound[Lang.l],
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ),
    );
  }
}