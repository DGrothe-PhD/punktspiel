import 'package:flutter/material.dart';

class Themes{
  //Shapes
  static RoundedRectangleBorder cardShape = RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(7));
  static Stack cardboardCanvas = Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/images/texture.png',
        fit: BoxFit.cover,
      ),
      Container(
        color: Themes.greenishColor.withAlpha(175), // Background + Transparenz
      ),
    ],
  );

  static dynamic mediumButtonWidth = WidgetStateProperty.all<Size>(const Size.fromWidth(150.0));
  //Colors
  static Color greenishColor = const Color.fromARGB(255, 165, 206, 185);
  static const Color unselectedBackgroundColor = Color.fromARGB(20, 0, 0, 0);
  static dynamic greenish = WidgetStateProperty.all<Color>(greenishColor);

  static dynamic green = 
    WidgetStateProperty.all<Color>(const Color.fromARGB(255, 104, 158, 124));  
  static Color darkgreen = const Color.fromARGB(255, 16, 44, 31);

  static Color active = const Color.fromARGB(255, 231, 209, 146);
  static Color pumpkinColor = const Color.fromARGB(255, 230, 124, 75);
  static dynamic pumpkin = WidgetStateProperty.all<Color>(pumpkinColor);
  static dynamic sunflower = 
    WidgetStateProperty.all<Color>(const Color.fromARGB(255, 243, 198, 76));

  static ButtonStyle cardButtonStyle(WidgetStateProperty<Color> color, {WidgetStateProperty<Size?>? fixedSize}) {
    return ButtonStyle(
      backgroundColor: color,
      fixedSize: fixedSize,
      shape: WidgetStateProperty.all<OutlinedBorder>(Themes.cardShape),
    );
  }

  static WidgetStateProperty<Size?>? buttonSize = WidgetStateProperty.all<Size>(const Size.fromWidth(200.0));
}

class ShadowedShapeBorder extends ShapeBorder {
  final ShapeBorder shape;
  final List<BoxShadow> shadows;

  const ShadowedShapeBorder({
    required this.shape,
    this.shadows = const [],
  });

  @override
  EdgeInsetsGeometry get dimensions => shape.dimensions;

  @override
  ShapeBorder scale(double t) {
    return ShadowedShapeBorder(
      shape: shape.scale(t),
      shadows: shadows,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return shape.getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return shape.getInnerPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final path = shape.getOuterPath(rect, textDirection: textDirection);

    for (final shadow in shadows) {
      final paint = shadow.toPaint();
      final shifted = path.shift(shadow.offset);
      canvas.drawPath(shifted, paint);
    }

    // danach das eigentliche Shape malen (z. B. indicatorColor wird drübergelegt)
    shape.paint(canvas, rect, textDirection: textDirection);
  }
}