// ignore_for_file: prefer_adjacent_string_concatenation, non_constant_identifier_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// Screens
import 'package:punktspiel/screens/help_screen.dart';
import 'package:punktspiel/screens/settings_screen.dart';
import 'package:punktspiel/screens/table_screen.dart';

import 'package:punktspiel/widgets/points_entry_row.dart';
// Utils
import 'package:punktspiel/utils/listenables.dart';

// Backend and styles
import 'package:punktspiel/calc.dart';
import 'package:punktspiel/models/games.dart';

// Legacy translation
import 'package:punktspiel/locales.dart';

// State of the art translation
import 'package:punktspiel/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:punktspiel/styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MyHomePage(title: 'Punktspiel'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
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
  final ValueNotifier<int> whoseTurnIndex = ValueNotifier(0);//check
  final ValueNotifier<int> whoseFirstTurnIndex = ValueNotifier(0);//check
  final ValueNotifier<String> selectedPlayerName = ValueNotifier(Spieler.names.first);

  final ValueNotifier<bool> _dontEditNames = ValueNotifier(false);//check
  final ValueNotifier<bool> _gamesStarted = ValueNotifier(false);
  final ValueNotifier<bool> _tableVisible = ValueNotifier(false);
  final Features _features = Features();

  @override
  void initState() {
    super.initState();
    if (Spieler.hasMembers) {
      namesFieldController.text = Spieler.names.join(", ");
      _gamesStarted.value = true;
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

   Widget buildSelectableNamesMenu() {
    if (!Spieler.playerNames.value.contains(selectedPlayerName.value)) {
      //firstOrNull can be done from dart >= 3.0.0
      selectedPlayerName.value = Spieler.playerNames.value.isNotEmpty 
      ? Spieler.playerNames.value.first : "";
    }

    return ValueListenableBuilder2(
      first: selectedPlayerName,
      second: Spieler.playerNames,
      builder: (context, theName, theMembers, _) {
        return DropdownButton<String>(
          key: const ValueKey('playerNameDropDown'),
          isExpanded: true,
          padding: edgeInsets,
          value: theName,
          onChanged: (String? value) {
            selectedPlayerName.value = value ?? "";
          },
          items: theMembers.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        );
      }
    );
  }

//no ValueListenableBuilder here, it's changing every few hours in most use cases.
  Widget buildPointsWinningSwitch() {
    return ValueListenableBuilder3(
        first: _dontEditNames,
        second: Spieler.hasWinningRuleSet,
        third: Spieler.leastPointsWinning,
        builder: (context, dontEdit, hasRuleSet, lPW, _) {
          return PopupMenuButton<String>(
            key: const ValueKey('winningRuleDropDown'),
            padding:
                const EdgeInsets.symmetric(horizontal: 3), // Adjust padding
            onSelected:
                (dontEdit || hasRuleSet)
                    ? null
                    : (value) {
                        Spieler.updateLeastPointsWinning(value == Locales.pointsRule[Lang.l].first);
                      },
            //disabledHint: ,
            itemBuilder: (context) => Locales.pointsRule[Lang.l]
                .map((rule) =>
                    PopupMenuItem<String>(value: rule, child: Text(rule)))
                .toList(),
            child: Text(
                Locales.pointsRule[Lang.l][lPW ? 0 : 1]),
            //menuWidth: 200,
          );
    });
  }

  _MyHomePageState();
  TableExampleApp punkteTabelle = const TableExampleApp();
  SettingsPage settingsPage = SettingsPage();
  HelpScreen helpPage = const HelpScreen();

  final ValueNotifier<int> _counter = ValueNotifier(0);

  void _incrementCounter() {
    _counter.value++;
    whoseTurnIndex.value = (whoseFirstTurnIndex.value + _counter.value) % Spieler.playerNames.value.length;
  }

  void _decrementCounter() {
    if (_counter.value > 0) {
      _counter.value--;
      whoseTurnIndex.value = (whoseFirstTurnIndex.value + _counter.value) % Spieler.playerNames.value.length;
    }
  }

  Future<void> submitPoints() async {
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    // Validating names list
    if (!_dontEditNames.value) {
      var namesList = namesFieldController.text.split(",");
      if (namesList.length < 2) {
        bool onlyOnePlayer = await _showYesNoDialog(
            Locales.noColon[Lang.l].format([namesFieldController.text]));
        if (!onlyOnePlayer) {
          numberFieldController.clear();
          selectedPlayerPoints = 0;
          return;
        }
      }
      _dontEditNames.value = true;
    }

    // Validating and submitting points
    if (Spieler.fillingTwice(selectedPlayerName.value)) {
      var empty = Spieler.whoIsEmpty();
      _showAlertDialog(
          "${s.noSecondEntry(selectedPlayerName.value)}\n${s.hintPointsMissing(empty.join(', '))}");
      return;
    }
    Spieler.addPoints(selectedPlayerName.value, selectedPlayerPoints);
    messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
      SnackBar(
        content: Text(s.pointSubmitFeedback(selectedPlayerName.value, selectedPlayerPoints)),
         // Locales.submitFeedback[Lang.l].format([selectedPlayerName.value, selectedPlayerPoints])),
        backgroundColor: const Color.fromARGB(255, 68, 146, 72),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
        duration: const Duration(seconds: 2),
      ),
    );

    numberFieldController.clear();
    selectedPlayerPoints = 0;

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
      Spieler.updateNames(names);
      selectedPlayerName.value = Spieler.playerNames.value.first;
      _gamesStarted.value = true;
    }
  }

  void setOpener() {
    whoseFirstTurnIndex.value = Spieler.playerNames.value.indexOf(selectedPlayerName.value);
    whoseTurnIndex.value = whoseFirstTurnIndex.value;
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
    _tableVisible.value = !_tableVisible.value;
  }

  void deleteLastEntry() {
    bool rowWasJustFilled = Spieler.filledFullRound();
    Spieler.deleteLastEntry(selectedPlayerName.value);
    if (rowWasJustFilled) {
      _decrementCounter();
    }
  }

  Future<void> deleteEverything() async {
    final confirmedDelete = await _showYesNoDialog("Are you sure?");
    if (confirmedDelete) {
      for (Teilnehmer t in Spieler.gruppe) {
        t.punkte.clear();
        _counter.value = 0;
      }
      _dontEditNames.value = false;
    }
  }

  Widget _TabbedContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 11),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Themes.unselectedBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Themes.greenishColor,
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
                  const EdgeInsets.symmetric(vertical: 3), // reduce height
              isScrollable: false,
            ),
          ),
          // Tab content
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

  final _formKey = GlobalKey<FormState>();

  Widget _GameModeContent() {
    return Column(
            children: [
              Container(
                margin: edgeInsets,
                height: 100,
                //width: 100,
                child: Form(
                  key: _formKey,
                  child: ValueListenableBuilder(
                    valueListenable: _dontEditNames, 
                    builder: (context, dontEdit, _) {
                  return TextFormField(
                    controller: _addNameController,
                    readOnly: dontEdit,
                    enabled: !dontEdit,
                    onTap: () => _gamesStarted.value = false,
                    //only if we need it.
                    //onTapOutside: (_) => closeKbd(),
                    onFieldSubmitted: (newText) {
                      final isValid =
                          _formKey.currentState?.validate() ?? false;
                      if (isValid) {
                        Spieler.addNewPlayer(newText);
                        _addNameController.clear();
                        namesFieldController.text = Spieler.playerNames.value.join(", ");
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _addNameController.clear(),
                        tooltip: Locales.clearNameField[Lang.l],
                      ),
                    ),
                    
                  );},),
                ),
              ),
              const SizedBox(height: 5),
              _reorderPlayersView(),
              //const Expanded(child: Text("")),//Flexible space.
              ValueListenableBuilder<bool>(
                valueListenable: _dontEditNames,
                builder: (context, dontEdit, _) {
                  if(dontEdit){return const Text("⏳");}
                  return ExpansionTile(
                    title: Text(Locales.furtherSettingsTitle[Lang.l]),
                    //subtitle: Text('foo'),
                    controlAffinity: ListTileControlAffinity.trailing,
                    children: <Widget>[buildGamesMenu(), const Text("✍️ tbd")],
                  );
                }
              ),
              const SizedBox(
                  height:
                      64), //! TODO consider moving this up when stuff happens.
            ],
          );
        //: const Text("⏳");
  }

  String? _selectedGame;

  Widget buildGamesMenu() {
    _selectedGame = Spieler.game ??
        (_features.games.isNotEmpty ? _features.games.keys.first : null);
    
    return DropdownButton<String>(
      key: const ValueKey('gameDropDown'),
      isExpanded: true,
      padding: edgeInsets,
      value: _selectedGame != null && _features.games.keys.contains(_selectedGame)
        ? _selectedGame : null,
      onChanged: _features.games.isNotEmpty
          ? (String? value) {
              setState(() {
                //_selectedGame = value;
                Spieler.game = value;
              });
            }
          : null,
      items: _features.games.keys.map<DropdownMenuItem<String>>((String value) {
        final game = _features.games.lookup(value);
        return DropdownMenuItem<String>(
          value: value,
          child: Text(game?.localName ?? game?.name ?? "unnamed" ),
        );
      }).toList(),
    );
  }

  Widget _reorderPlayersView() => Expanded(
        child: Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder(
              valueListenable: Spieler.playerNames,
              builder: (context, theMembers, _) {
                return ReorderableListView(
                  shrinkWrap: true,
                  // Optional, für Hot Reload Stabilität
                  key: const ValueKey('reorderable_list'),
                  onReorder: (int oldIndex, int newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    String item = theMembers[oldIndex];
                    Spieler.movePlayer(item, newIndex);
                    //Now we have updated things in the background - them to the UI, not the old state.
                    namesFieldController.text = Spieler.playerNames.value.join(", ");
                  },
                  children: [
                    for (int index = 0; index < theMembers.length; index++)
                      ListTile(
                        key: ValueKey(index),
                        title: Text(theMembers[index]),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              final messenger = ScaffoldMessenger.of(context);
                              final removedIndex = index;
                              final String removedName = theMembers[index];
                              Teilnehmer? removedPlayer;

                              // Optimistic approach: remove that item and insert on undo.
                              removedPlayer = Spieler.removePlayer(removedName);
                              namesFieldController.text = Spieler.playerNames.value.join(", ");

                              // Closing other snack bars to keep clean
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(Locales.deletePlayer[Lang.l].format([removedName]),),
                                  //duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: Locales.undo[Lang.l],
                                    onPressed: () {
                                      if (!mounted) return;
                                        // Reinsert
                                      Spieler.insertPlayer(
                                        removedPlayer ?? Teilnehmer(name: removedName),
                                        removedIndex);
                                      namesFieldController.text = Spieler.playerNames.value.join(", ");
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                );
              }),
        ),
      );

  String? nameValidator(text) {
    if (text == null || text.trim().isEmpty) {
      return Locales.cantBeEmpty[Lang.l];
    }
    if (text.contains(',')) {
      return Locales.commasIgnored[Lang.l];
    }
    if (Spieler.names.contains(text.split(RegExp(r'\s+')).join(" ").trim())) {
      return Locales.foundDuplicateName[Lang.l];
    }
    return null;
  }
  //! ### setState tangled up
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
              child: ValueListenableBuilder(
                valueListenable: _counter,
                builder: (context, numberOfGames, _) {
                  return Text(
                    '$numberOfGames',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                },
              ),
            ),
            Container(
              margin: edgeInsets,
              child: ValueListenableBuilder2(
                first: whoseTurnIndex,
                second: Spieler.playerNames,
                builder: (context, whoseTurn, theMembers, _) {
                  return Text((whoseTurn < theMembers.length)
                    ? Locales.opener[Lang.l]
                        .format([theMembers[whoseTurn].truncate(10)])
                    : "< empty >");
                },
              ),
            ),
          ],
        ),
        // Field for names
        Container(
          margin: edgeInsets,
          child: ValueListenableBuilder2<bool, TextEditingValue>(
            first: _dontEditNames,
            second: namesFieldController,
            builder: (context, dontEdit, textEntry, _) {
              return TextField(
                controller: namesFieldController,//this.
                readOnly: dontEdit,// && !_weAreDebugging,
                enabled: !dontEdit,// || _weAreDebugging,
                onTap: () => _gamesStarted.value = false,
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
              );
            },
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
              child: ValueListenableBuilder<bool>(
                valueListenable: _gamesStarted,
                builder: (context, gamesRunning, _) {
                  return PointsEntryRow(
                    controller: numberFieldController,
                    enabled: gamesRunning,
                    onChanged: (newText) {
                      selectedPlayerPoints = int.tryParse(newText) ?? 0;
                    },
                  );
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _dontEditNames,
              builder: (context, dontEdit, _) {
                return ElevatedButton(
                  onPressed: dontEdit ? null : setOpener,
                  style: Themes.cardButtonStyle(
                    WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey; // disabled-Farbe
                        }
                        return Themes.greenColor; // aktive Farbe
                      },
                    ),
                  ),
                  child: const Icon(Icons.chair),
                );
              },
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ElevatedButton(
          onPressed: submitPoints,
          style: Themes.cardButtonStyle(
            WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.yellow.shade300;
              }
              return Themes.sunflowerColor;
            }),
            fixedSize: WidgetStateProperty.all<Size>(const Size.fromWidth(117.0)),
          ),
          child: Text(Locales.submit[Lang.l]),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: deleteEverything,
          style: Themes.cardButtonStyle(Themes.pumpkin,
              fixedSize: WidgetStateProperty.all<Size>(const Size.fromWidth(135.0)),
          ),
          child: Text(Locales.deleteAllResults[Lang.l]),
        ),
        ],),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget myHomePage() {
    return Stack(children: <Widget>[
      ValueListenableBuilder(
        valueListenable: _tableVisible,
        builder: (context, isVisible, _) {
          if (isVisible) {
            return punkteTabelle;
          }
            return _TabbedContent();
      }),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.table_view),
            onPressed: togglePointsView,
            style: Themes.cardButtonStyle(Themes.green,
              fixedSize: Themes.mediumButtonWidth),
            label: ValueListenableBuilder(
              valueListenable: _tableVisible,
              builder: (context, isVisible, _){
                  return Text(isVisible ? Locales.hideTable[Lang.l] : Locales.showTable[Lang.l]);
              }
            ),
          ),
        ),
      )
    ]);
  }

  Widget aboutMePage() => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: Themes.cardboardAppBar(Locales.aboutTitle[Lang.l]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(17),
        child: Column(children: <Widget>[
          const Text(
                "A local app to add points when playing cards or similar games in a group.\n" +
                    "Designed for the fun of it and for learning!"),
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
        ]),
      ));

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
        currentPage = const HelpScreen();
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
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/texture.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: NavigationBar(
            height: 50.0,
            backgroundColor: Themes.greenishColor.withAlpha(175),
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            //Style and coloring
            indicatorColor: Themes.active,
            indicatorShape: ShadowedShapeBorder(
              shape: Themes.cardShape,
              shadows: [
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(2, 3),
                ),
                BoxShadow(
                  color: Themes.active,
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            // wide screens with fewer pixels don't show the labels.
            //labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
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
