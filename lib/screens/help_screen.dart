import 'package:flutter/material.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:punktspiel/locales.dart';
import 'package:punktspiel/styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: Themes.cardboardAppBar(Locales.helpTitle[Lang.l]),
        body: SingleChildScrollView(
          child: helpScreenContent(),
        ));
  }

  //&ldquo;Game mode&rdquo;
  static const TextStyle styleH1 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle styleH2 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Widget helpScreenContent() {
    return Container(
        padding: const EdgeInsets.all(17),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 14),
            children: [
            //  TextSpan(
            //    text: 'How to use this app\n\n',
             //   style: styleH1,
            //  ),
              TextSpan(
                text: 'Start a game\n\n',
                style: styleH2,
              ),
              TextSpan(
                children: [
                  TextSpan(text: 'Type in some names or tap on '),
                  TextSpan(
                      text: 'Game mode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ' to add or remove one or organize their seats.\n\n'),
                ],
              ),
              TextSpan(
                children: [
                  TextSpan(text: 'On '),
                  TextSpan(
                      text: 'Game mode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ', you\'ll also find '),
                  TextSpan(
                      text: 'More settings',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          ", where you can choose a game or enter a miscellaneous game. This presets the points rule,"
                          " so that for example rummy defines the one with the least points will be in the lead.\n\n"),
                ],
              ),
              TextSpan(
                text:
                    'Next, choose a player who will start, and denote the player as the one who starts by tapping the seat button.\n\n',
              ),
              TextSpan(
                children: [
                  TextSpan(
                      text:
                          "Submitting points is as easy as tapping on the Points: field, "
                          "typing something in (a number keypad will appear) and then hit "),
                  TextSpan(
                      text: 'Submit',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          '. There are also buttons to delete the last number you submitted, or to delete it all.\n\n'),
                ],
              ),
            ],
          ),
        ));
    /* Html(
      data: """<style>$_cssHelpStyle</style>
      <h1>How to use this app</h1>
      <h2>Start a game</h2>
      <p>Type in some names or tap on <b>Game mode</b> to add or remove one or organize their seats.</p>
      <p>On <b>Game mode</b>, you'll also find <b>More settings</b>, where you can choose a game or enter a miscellaneous game.
      This presets the points rule, so that for example rummy defines the one with the least points will be in the lead.</p>
      <p>Next, choose a player who will start, and denote the player as the one who starts by tapping the seat button.</p>
      <p>Submitting points is as easy as tapping on the Points: field, typing something in (a number keypad will appear) and then hit <b>Submit</b>.
      There are also buttons to delete the last number you submitted, or to delete it all</p>"""
    );*/
  }
}
