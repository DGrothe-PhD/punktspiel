import 'package:flutter/material.dart';
class Themes{
  static Color greenishColor = const Color.fromARGB(255, 165, 206, 185);
  static Color active = const Color.fromARGB(255, 231, 209, 146);
  static dynamic greenish = 
    WidgetStateProperty.all<Color>(greenishColor);
  static dynamic pumpkin =
    WidgetStateProperty.all<Color>(const Color.fromARGB(255, 230, 124, 75));
  static dynamic green = 
    WidgetStateProperty.all<Color>(const Color.fromARGB(255, 104, 158, 124));
  static dynamic sunflower = 
    WidgetStateProperty.all<Color>(const Color.fromARGB(255, 243, 198, 76));
}