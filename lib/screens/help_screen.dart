import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:punktspiel/locales.dart';
import 'package:punktspiel/styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : true,
      appBar: Themes.cardboardAppBar(Locales.helpTitle[Lang.l]),
      body: SingleChildScrollView(
        child: helpScreenContent(),
      )
    );
  }

  static const String _cssHelpStyle = 
  """
  html { font-size: 11px;}
  h1{font-size: 2.5rem;}
  h2{font-size:1.875rem;}
  p{}
  """;
  //&ldquo;Game mode&rdquo;

  Widget helpScreenContent(){
    return Html(
      data: """<style>$_cssHelpStyle</style>
      <h1>How to use this app</h1>
      <h2>Start a game</h2>
      <p>Type in some names or tap on <b>Game mode</b> to add or remove one or organize their seats.</p>
      <p>On <b>Game mode</b>, you'll also find <b>More settings</b>, where you can choose a game or enter a miscellaneous game.
      This presets the points rule, so that for example rummy defines the one with the least points will be in the lead.</p>
      <p>Next, choose a player who will start, and denote the player as the one who starts by tapping the seat button.</p>
      <p>Submitting points is as easy as tapping on the Points: field, typing something in (a number keypad will appear) and then hit <b>Submit</b>.
      There are also buttons to delete the last number you submitted, or to delete it all</p>"""
    );
  }
}
