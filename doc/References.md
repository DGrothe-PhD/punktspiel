## References

### Files
* Medium article: [Handling JSON files](https://medium.com/@dudhatkirtan/flutter-read-json-file-from-assets-guide-2024-a99f31d9c2a6)
* Importing assets: [Mediendateien importieren](https://www.flutter.de/artikel/flutter-assets-bilder-sound-verwenden)
* Building [windows version](https://stackoverflow.com/questions/57032406/flutter-desktop-embedding-how-to-build-exe-file#57042227)

### Widget types
<!--* Updatable tables (beta state?): [Dynamic table](https://pub.dev/packages/dynamic_table)-->
* Navigating:
  - MaterialApp vs. Scaffold: [fixing black screen issue](https://stackoverflow.com/questions/53723294/flutter-navigator-popcontext-returning-a-black-screen)
  - Swipe gestures https://pub.dev/packages/swipe_to
    `//import 'package:swipe_to/swipe_to.dart';`
    ```flutter
    child: SwipeTo(
      onRightSwipe: (details) => {Navigator.pop(context, true)},
      child: Padding/Column(…))
    ```
  - Set and lock screen rotation [for both Stateless and StatefulWidget](https://stackoverflow.com/a/50322184/17677104)
  - Grids and how to fill a list (iteration) https://docs.flutter.dev/cookbook/lists/grid-lists

### Input fields
* Numbers: [Digits Only](https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter#49578197)

### Miscellaneous Dart tips
* Nested loops: [OuterLoop Label](https://stackoverflow.com/questions/70300104/how-to-break-out-of-nested-loops-in-dart)

### Web view
* In-app web view: https://inappwebview.dev/docs/intro/ 
* Call an open API and fetch data before building a widget: [Medium article](https://medium.com/@ssdharmawansa97/async-await-in-flutter-handling-asynchronous-code-like-a-pro-497da0fad8fe)

### Building process
* View an APK's manifest file: https://stackoverflow.com/a/4191807/17677104 and https://apktool.org/docs/install
* Main Android manifest file is at android > app > src > main > AndroidManifest.xml. Ref.: https://stackoverflow.com/a/60095312/17677104
