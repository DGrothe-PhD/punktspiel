import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './table.dart';
import './calc.dart';

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
  //final List<Teilnehmer> gruppe = [];
  final numberFieldController = TextEditingController();
  final namesFieldController = TextEditingController();
  final selectableNamesMenuController = TextEditingController();
  int myPoints = 0;
  String myName = Spieler.names.first;

Widget buildselectableNamesMenu(){
  return DropdownMenu<String>(
    key: ValueKey(Object.hashAll(Spieler.names)),
    requestFocusOnTap: true,
    enableSearch: true,
    controller: selectableNamesMenuController,
    initialSelection: Spieler.names.first,
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
    Spieler.addPoints(myName, myPoints);
  }

  void showPoints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => punkteTabelle,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
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
            const Text(
              'Gespielte Runden:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container( 
              margin: const EdgeInsets.all(12),
              //height: 100,
              //width: 100,
              child: TextField(
                controller: namesFieldController,
                //onChanged Ereignis updated automatisch den angezeigten Text
                onChanged: (newText) {
                  List<String> names = newText.split(",")
                    .where((x) => x != "").toList();
                  if(names.length > 1) {
                    Spieler.names = names;
                    myName = Spieler.names.first;
                    // Rebuild widget! Show the names, hopefully!
                    setState(() => {});
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Teilnehmer:',
                  isDense: true,
                ),
                //keyboardType: TextInputType.text,
              ),
            ),
            Container( 
              margin: const EdgeInsets.all(12),
              //height: 100,
              //width: 100,
              child: TextField(
                controller: numberFieldController,
                //onChanged Ereignis updated automatisch den angezeigten Text
                onChanged: (newText) {myPoints = int.tryParse(newText) ?? 0;},
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Punkte:',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
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
              child: const Text("Eintragen"),
            ),),
            const SizedBox(height:20),
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
              onPressed: showPoints,
              style: ButtonStyle(
                padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>((Set<WidgetState> states) {
                return const EdgeInsets.all(7);
              },),
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 87, 228, 141)
                ),
              ),
              child: const Text("Tabelle"),
            ),),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Neue Runde',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}