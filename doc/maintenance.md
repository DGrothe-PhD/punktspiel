<details><summary><h1>Thema 1: Windows Buildfehler</h1></summary>

Launching lib\main.dart on Windows in debug mode...
CMake Error: Error: generator : Visual Studio 17 2022
Does not match the generator used previously: Visual Studio 16 2019
Either remove the CMakeCache.txt file and CMakeFiles directory or choose a different binary directory.
Error: Unable to generate build files

Exited (1).

Wie behebe ich das am einfachsten?

<pre>Remove-Item -Recurse -Force .\build\windows\CMakeCache.txt, .\build\windows\CMakeFiles\
flutter clean
// ich habe eingeschoben weil sich alles geringelt hat
flutter pub get
// dann 
flutter run -d windows</pre>
</details>

<details><summary><h1>Topic 2: Turn off Copilot in VSCode</h1></summary>

Open the Command Palette (Ctrl+Shift+P or Cmd+Shift+P) and select "Preferences: Open Settings (JSON)".<br>
Right there in ".vscode/settings.json" of repository root folder, we do:
```
* JSON text data
{
    "java.compile.nullAnalysis.mode": "automatic",
    "java.configuration.updateBuildConfiguration": "interactive",
    "github.copilot.enable": {
        "*": false
    },
    "github.copilot.editor.enableAutoCompletions": false,
    "github.copilot.editor.enableCodeActions": false,
    "github.copilot.nextEditSuggestions.enabled": false,
    "github.copilot.renameSuggestions.triggerAutomatically": false,
    "chat.commandCenter.enabled": false,
    "chat.agent.enabled": false,
}
```
