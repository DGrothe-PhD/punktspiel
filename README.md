# punktspiel

[![Build apk](https://github.com/DGrothe-PhD/punktspiel/actions/workflows/ci.yml/badge.svg)](https://github.com/DGrothe-PhD/punktspiel/actions/workflows/ci.yml)

A local app to add points when playing cards in a group.

Designed for the fun of it and for learning!

## Features
Entry field for player names, submit points, show results.

<img src="./doc/ExampleSubmitForm.png" alt="Submit Form" style="width:25%; height:auto;">&nbsp;&nbsp;<img src="./doc/ExampleResults.png" alt="Example Results" style="width:28%; height:auto;">

## Installation
* Android: Which APK to use, you find the CPU type of your phone for example [here](https://www.gsmarena.com/)
* Example: Octa-core 1.6 GHz Cortex-A53 &rarr; ARM64-v8a. Probably, with Android 7, you might need the apk such as app-armeabi-v7a-debug.apk.
* No phone for testing? No worries. On Windows, just open [this folder](build/windows/x64/runner/Release), there is a *.exe file for you.

## References

### Files
* Medium article: [Handling JSON files](https://medium.com/@dudhatkirtan/flutter-read-json-file-from-assets-guide-2024-a99f31d9c2a6)
* Importing assets: [Mediendateien importieren](https://www.flutter.de/artikel/flutter-assets-bilder-sound-verwenden)
* Building [windows version](https://stackoverflow.com/questions/57032406/flutter-desktop-embedding-how-to-build-exe-file#57042227)

### Widget types
<!--* Updatable tables (beta state?): [Dynamic table](https://pub.dev/packages/dynamic_table)-->
* Navigating:
  - MaterialApp vs. Scaffold: [fixing black screen issue](https://stackoverflow.com/questions/53723294/flutter-navigator-popcontext-returning-a-black-screen)

### Input fields
* Numbers: [Digits Only](https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter#49578197)
