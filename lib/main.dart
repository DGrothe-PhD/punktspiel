// ignore_for_file: prefer_adjacent_string_concatenation, non_constant_identifier_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:punktspiel/table.dart';
import 'package:punktspiel/settings.dart';
import 'package:punktspiel/calc.dart';
import 'package:punktspiel/locales.dart';
import 'package:punktspiel/styles.dart';

void main() {
  Spieler.settings();
  Lang.initLanguage();
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
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
  final now = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //Each editable field needs their controller.
  //Otherwise, stuff happens, such as that a name appears in a number field.
  final TextEditingController numberFieldController = TextEditingController();
  final TextEditingController namesFieldController = TextEditingController();
  final TextEditingController _addNameController = TextEditingController();
  final TextEditingController selectableNamesMenuController =
      TextEditingController();
  int currentPageIndex = 0;

  final SvgPicture kofiIcon = SvgPicture.asset(
    'assets/images/kofi_symbol.svg',
    width: 25.0,
    height: 25.0,
  );
  final SvgPicture githubIcon = SvgPicture.asset(
    'assets/images/github-mark.svg',
    width: 25.0,
    height: 25.0,
  );
  final EdgeInsets edgeInsets = const EdgeInsets.all(11);
  final double buttonHeight = 30;

  int selectedPlayerPoints = 0;
  int whoseTurnIndex = 0;
  int whoseFirstTurnIndex = 0;
  String selectedPlayerName = Spieler.names.first;

  bool _dontEditNames = false;
  bool _gamesStarted = false;

  @override
  void initState() {
    super.initState();
    if (Spieler.hasMembers) {
      namesFieldController.text = Spieler.names.join(", ");
      _gamesStarted = true;
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Widget buildSelectableNamesMenu() {
    if (!Spieler.names.contains(selectedPlayerName)) {
      selectedPlayerName = Spieler.names.isNotEmpty ? Spieler.names.first : "";
    }

    return DropdownButton<String>(
      key: ValueKey(Object.hashAll(Spieler.names)),
      isExpanded: true,
      padding: edgeInsets,
      value: selectedPlayerName,
      onChanged: (String? value) {
        setState(() {
          selectedPlayerName = value ?? "";
        });
      },
      items: Spieler.names.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget buildPointsWinningSwitch() {
    return DropdownButton<String>(
      key: ValueKey(Object.hashAll(Locales.pointsRule[Lang.l])),
      isExpanded: true,
      value: Locales.pointsRule[Lang.l][Spieler.leastPointsWinning ? 0 : 1],
      padding: const EdgeInsets.symmetric(horizontal: 3), // Adjust padding
      onChanged: (_dontEditNames || Spieler.hasWinningRuleSet) ? null :
        (String? value) {
          setState(() => Spieler.leastPointsWinning =
            (value == Locales.pointsRule[Lang.l].first));
        // We need that setState, otherwise the dropdown doesn't change.
      },
      //disabledHint: ,
      items: Locales.pointsRule[Lang.l]
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      //menuWidth: 200,
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
    if (_counter > 0) {
      setState(() {
        _counter--;
        whoseTurnIndex =
            (whoseFirstTurnIndex + _counter) % Spieler.names.length;
      });
    }
  }

  Future<void> submitPoints() async {
    // Validating names list
    if (!_dontEditNames) {
      var namesList = namesFieldController.text.split(",");
      if (namesList.length < 2) {
        bool onlyOnePlayer = await _showYesNoDialog(
            Locales.noColon[Lang.l].format([namesFieldController.text]));
        if (!onlyOnePlayer) {
          setState(() {
            numberFieldController.clear();
            selectedPlayerPoints = 0;
          });
          return;
        }
      }
      setState(() => _dontEditNames = true);
    }

    // Validating and submitting points
    if (Spieler.fillingTwice(selectedPlayerName)) {
      var empty = Spieler.whoIsEmpty();
      _showAlertDialog(
          "${Locales.noSecondEntry[Lang.l].format([selectedPlayerName])}\n" +
              "${Locales.hint[Lang.l]} ${empty.join(', ')}");
      return;
    }
    Spieler.addPoints(selectedPlayerName, selectedPlayerPoints);
    setState(() {
      numberFieldController.clear();
      selectedPlayerPoints = 0;
    });
    if (Spieler.filledFullRound()) {
      _incrementCounter();
    }
  }

  void _finishEditingNames(String newText) {
    List<String> names = newText
        .split(",")
        .map((x) => x.split(RegExp(r'\s+')).join(" ").trim())
        .toList()
        .where((x) => x != "")
        .toList();
    if (names.isNotEmpty) {
      if (names.toSet().length < names.length) {
        _showAlertDialog(Locales.foundDuplicateName[Lang.l]);
        return;
      }
      Spieler.names = names;
      selectedPlayerName = Spieler.names.first;
      setState(() => _gamesStarted = true);
    }
  }

  void setOpener() {
    if (!_dontEditNames) {
      setState(() {
        whoseFirstTurnIndex = Spieler.names.indexOf(selectedPlayerName);
        whoseTurnIndex = whoseFirstTurnIndex;
      });
    }
  }

  void closeKbd() {
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

  void togglePointsView() {
    setState(() {
      Lang.tableVisible = !Lang.tableVisible;
    });
  }

  void deleteLastEntry() {
    bool rowWasJustFilled = Spieler.filledFullRound();
    Spieler.deleteLastEntry(selectedPlayerName);
    if (rowWasJustFilled) {
      _decrementCounter();
    }
  }

  void deleteEverything() {
    for (Teilnehmer t in Spieler.gruppe) {
      t.punkte.clear();
      _counter = 0;
    }
    setState(() {
      _dontEditNames = false;
    });
  }

  Widget _TabbedContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 11),
          // Tab-Leiste oben
          Container(
            height: 42,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Themes.greenishColor, // deine Linie unten
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              tabs: [
                Tab(text: Locales.overviewTabTitle[Lang.l]),
                Tab(text: Locales.gameModeTabTitle[Lang.l]),
              ],
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black87,
              indicatorColor: Themes.greenishColor,
              indicator: BoxDecoration(
                  color: Themes.greenishColor,
                  borderRadius: const BorderRadius.all(Radius.circular(7))),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding:
                  const EdgeInsets.symmetric(vertical: 3), // Höhe reduzieren
              isScrollable: false,
            ),
          ),
          // Tab-Inhalt
          Expanded(
            child: TabBarView(
              children: [
                _HomeContent(),
                //
                _GameModeContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _getClearButton() {
    if (_addNameController.text.isEmpty) {
      return null;
    }
    return IconButton(
      onPressed: () => _addNameController.clear(),
      icon: const Icon(Icons.clear),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _GameModeContent() {
    return !_dontEditNames
        ? Column(
            children: [
              Container(
                margin: edgeInsets,
                height: 100,
                //width: 100,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _addNameController,
                    readOnly: _dontEditNames,
                    enabled: !_dontEditNames,
                    onTap: () {
                      setState(() => _gamesStarted = false);
                    },
                    onFieldSubmitted: (newText) {
                      final isValid = _formKey.currentState!.validate();
                      if (isValid) {
                        setState(() {
                          Spieler.addPlayer(newText);
                          _addNameController.clear();
                          namesFieldController.text = Spieler.names.join(", ");
                        });
                      }
                    },
                    validator: nameValidator,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Themes.greenishColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Themes.active)),
                      errorStyle: const TextStyle(color: Colors.red),
                      focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      labelText: Locales.players[Lang.l],
                      isDense: true,
                      suffixIcon: _getClearButton(),
                    ),
                  ),
                ),
              ),
              reorderPlayersView(),
              ExpansionTile(title: Text(Locales.furtherSettingsTitle[Lang.l]),
                //subtitle: Text('foo'),
                controlAffinity: ListTileControlAffinity.trailing,
                children: <Widget>[
                  buildGamesMenu(),
                  const Text("✍️ tbd")],
        ),
        const SizedBox(height: 64),
            ],
          )
        : const Text("⏳");
  }

  String? _selectedGame;

  Widget buildGamesMenu() {
    // TODO have in mind when translating to pick an index instead. Or step up to some Json handling.
    //! TODO implement #75
    _selectedGame = Spieler.game ?? (Spieler.games.isNotEmpty ? Spieler.games.keys.first : null);

    return DropdownButton<String>(
      key: ValueKey(Object.hashAll(Spieler.games.keys)),
      isExpanded: true,
      padding: edgeInsets,
      value: _selectedGame,
      onChanged: Spieler.games.isNotEmpty ? (String? value) {
        setState(() {
          //_selectedGame = value;
          Spieler.game = value;
        });
      } : null,
      items: Spieler.games.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  Widget reorderPlayersView() => Expanded(
    child: ReorderableListView(
      // Optional, für Hot Reload Stabilität
      key: const ValueKey('reorderable_list'), 
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          String item = Spieler.names[oldIndex];
          Spieler.movePlayer(item, newIndex);
          namesFieldController.text = Spieler.names.join(", ");
        });
      },
      children: [
        for (int index = 0; index < Spieler.names.length; index++)
          ListTile(
            key: ValueKey(index),
            title: Text(Spieler.names[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  String item = Spieler.names[index];
                  Spieler.removePlayer(item);
                  namesFieldController.text = Spieler.names.join(", ");
                });
              },
            ),
          ),
      ],
    ),
  );

  String? nameValidator(text) {
    if (text == null || text.trim().isEmpty) {
      return 'Can\'t be empty';
    }
    if (text.contains(',')) {
      return 'Hint: Commas are ignored.';
    }
    if (Spieler.names.contains(text.split(RegExp(r'\s+')).join(" ").trim())) {
      return 'This name is already there.';
    }
    return null;
  }

  Widget _HomeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            Container(
              margin: const EdgeInsets.all(7),
              alignment: Alignment.bottomRight,
              width: 30,
              child: SvgPicture.asset(
                'assets/images/dice.svg',
                width: 25.0,
                height: 25.0,
              ),
            ),
            Text(Locales.winFor[Lang.l]),
            const SizedBox(width: 20),
            SizedBox(
              width: 200,
              child: buildPointsWinningSwitch(),
            ),
          ],
        ), // Row for played rounds and whose turn it is
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
              child: Text((whoseTurnIndex < Spieler.names.length)
                  ? Locales.opener[Lang.l]
                      .format([Spieler.names[whoseTurnIndex].truncate(10)])
                  : "< empty >"),
            ),
          ],
        ),
        // Field for names
        Container(
          margin: edgeInsets,
          //height: 100,
          //width: 100,
          child: TextField(
            controller: namesFieldController,
            readOnly: _dontEditNames,
            enabled: !_dontEditNames,
            onTap: () {
              setState(() => _gamesStarted = false);
            },
            onSubmitted: (newText) => _finishEditingNames(newText),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Themes.greenishColor)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Themes.active)),
              labelText: Locales.players[Lang.l],
              isDense: true,
            ),
          ),
        ),
        // Number field row
        Row(
          children: <Widget>[
            Container(
              margin: edgeInsets,
              //height: 100,
              width: 150,
              // Number field to enter points
              child: TextField(
                enabled: _gamesStarted,
                controller: numberFieldController,
                onChanged: (newText) {
                  selectedPlayerPoints = int.tryParse(newText) ?? 0;
                },
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
            ElevatedButton(
              onPressed: setOpener,
              style: Themes.cardButtonStyle(Themes.green),
              child: const Icon(Icons.chair),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: deleteLastEntry,
              style: Themes.cardButtonStyle(Themes.pumpkin),
              child: const Icon(Icons.delete),
            ),
          ],
        ),
        buildSelectableNamesMenu(),
        ElevatedButton(
          onPressed: submitPoints,
          style: Themes.cardButtonStyle(
            Themes.sunflower,
            fixedSize: Themes.mediumButtonWidth,
          ),
          child: Text(Locales.submit[Lang.l]),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: deleteEverything,
          style: Themes.cardButtonStyle(Themes.pumpkin,
              fixedSize: Themes.mediumButtonWidth),
          child: Text(Locales.deleteAllResults[Lang.l]),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget myHomePage() {
    return Stack(children: <Widget>[
      Lang.tableVisible ? punkteTabelle : _TabbedContent(), // _HomeContent(),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.table_view),
            onPressed: togglePointsView,
            style: Themes.cardButtonStyle(Themes.green,
                fixedSize: Themes.mediumButtonWidth),
            label: Text("${Lang.tableVisible ? "Hide " : "Show "}Table"),
          ),
        ),
      )
    ]);
  }

  Widget aboutMePage() => Column(children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(5),
          child: Text(
              "A local app to add points when playing cards or similar games in a group.\n" +
                  "Designed for the fun of it and for learning!"),
        ),
        const SizedBox(height: 7),
        ElevatedButton.icon(
          icon: kofiIcon,
          onPressed: () {
            _launchKoFi();
          },
          style: Themes.cardButtonStyle(Themes.green,
              fixedSize: Themes.buttonSize),
          label: const Text("Support me"),
        ),
        const SizedBox(height: 7),
        ElevatedButton.icon(
          icon: githubIcon,
          onPressed: () {
            _launchGitHub();
          },
          style: Themes.cardButtonStyle(Themes.pumpkin,
              fixedSize: Themes.buttonSize),
          label: const Text("Open GitHub"),
        ),
      ]);

  Widget myHelpPage() {
    return const Text("tbd");
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage; // = myHomePage();
    switch (currentPageIndex) {
      case 0:
        currentPage = myHomePage();
        break;
      case 1:
        currentPage = settingsPage;
        break;
      case 2:
        currentPage = myHelpPage();
        break;
      case 3:
        currentPage = aboutMePage();
        break;
      default:
        currentPage = myHomePage();
        break;
    }

    Widget TheContent = GestureDetector(
      onTap: closeKbd,
      //onDoubleTap: () => {},
      //onLongPress: () => {},
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text(widget.title),
        ),
        bottomNavigationBar: NavigationBar(
          height: 50.0,
          backgroundColor: Themes.greenishColor,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          //Style and coloring
          indicatorColor: Themes.active,
          labelTextStyle: WidgetStateProperty.all<TextStyle>(
              TextStyle(color: Themes.darkgreen)),
          labelPadding: const EdgeInsets.all(5),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorShape: Themes.cardShape,
          //Functionality
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: Color.fromARGB(255, 16, 44, 31),
              ),
              selectedIcon: Icon(Icons.home_outlined,
                  color: Color.fromARGB(255, 80, 59, 57)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              selectedIcon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.help_rounded),
              selectedIcon: Icon(Icons.help_outline_rounded),
              label: 'Help',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_rounded),
              selectedIcon: Icon(Icons.info_outline_rounded),
              label: 'About Me',
            ),
          ],
        ),
        body: currentPage,
      ),
    );
    return TheContent;
  }

  //Stylings

  _launchKoFi() async {
    final Uri url = Uri.parse('https://ko-fi.com/danielagrothe');
    if (!await launchUrl(url, webOnlyWindowName: "Web Title")) {
      _showAlertDialog(Locales.isOffline[Lang.l]);
    }
  }

  _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/DGrothe-PhD/punktspiel/');
    if (!await launchUrl(url, webOnlyWindowName: "Project on GitHub")) {
      _showAlertDialog(Locales.isOffline[Lang.l]);
    }
  }
}
