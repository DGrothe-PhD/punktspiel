import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:punktspiel/preferences/mysharedpreferences.dart';

/// Inherited widget: liefert den aktuellen Skalierungsfaktor.
class FontScale extends InheritedWidget {
  final double scale;

  const FontScale({
    super.key,
    required this.scale,
    required super.child,
  });

  static double of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<FontScale>();
    return widget?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(FontScale oldWidget) => oldWidget.scale != scale;
}

/// Flexible Provider: zeigt optional einen kleinen Slider (Kontrolle)
/// und umhüllt den [child] mit [FontScale].
///
/// Verwende z.B.:
///   FontScaleProvider(
///     initialScale: 1.0,
///     minScale: 0.8,
///     maxScale: 1.6,
///     divisions: 8,
///     showControl: true,
///     child: /* dein skalierter Bereich */,
///   )
class FontScaleProvider extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final int divisions;
  final double initialScale;
  final bool showControl;
  final ValueChanged<double>? onChanged;

  const FontScaleProvider({
    super.key,
    required this.child,
    this.minScale = 0.8,
    this.maxScale = 1.6,
    this.divisions = 8,
    this.initialScale = 1.0,
    this.showControl = true,
    this.onChanged,
  });

  @override
  State<FontScaleProvider> createState() => _FontScaleProviderState();
}

final ValueNotifier<double?> widgetScale = ValueNotifier(null);

class _FontScaleProviderState extends State<FontScaleProvider> {
  //static double? _scale;
  
  void getTextScale() async {
    // There's just one text scale for the whole app.
    final value = await MySharedPreferences.getTextScale();
    widgetScale.value = value?.clamp(widget.minScale, widget.maxScale) ?? 1.0;
  }

  @override
  void initState() {
    super.initState();
    getTextScale();
    //_scale = widget.initialScale.clamp(widget.minScale, widget.maxScale);
  }

  // ? Es updated noch nicht, liest aber den Wert ausm Speicher korrekt aus.
  // ? "Baut zu früh", oder holt Lasagne ausm Ofen bevor er lief.
  // ? Sollte wohl so alalong
  // ? static final ValueNotifier<bool> leastPointsWinning = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    getTextScale();
    final control = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.text_fields, size: 18),
              const SizedBox(width: 8),
              const Text('Textgröße'), //TODO localize
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: widgetScale,
                builder: (context, scale, _) =>
                    Text('${((scale ?? 1.0) * 100).round()}%'),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widgetScale,
            builder: (context, scale, _) => Slider.adaptive(
              value: widgetScale.value ?? 1.0,
              min: widget.minScale,
              max: widget.maxScale,
              divisions: widget.divisions,
              label: '${((widgetScale.value ?? 1.0) * 100).round()}%',
              onChanged: (v) {
                widgetScale.value = v;
                MySharedPreferences.saveTextScale(widgetScale.value ?? 1.0);
              },
            ),
          ),
        ],
      ),
    );

    // Wickle child zuerst in FontScale, zusätzlich die (optionale) Steuerung
    Widget body = ValueListenableBuilder(
        valueListenable: widgetScale,
        builder: (context, scale, _) => FontScale(
              scale: scale ?? 1.0,
              child: widget.child,
    ));

    if (!widget.showControl) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        control,
        body,
      ],
    );
  }
}

/// Hilfsfunktion: skaliert eine vorhandene TextStyle (falls fontSize gesetzt).
TextStyle scaledTextStyle(TextStyle base, BuildContext context) {
  final scale = FontScale.of(context);
  final fs = base.fontSize;
  if (fs == null) return base;
  return base.copyWith(fontSize: fs * scale);
}