import 'package:flutter/material.dart';

/// Colors ported 1:1 from the original HTML's :root CSS variables.
class AppColors {
  AppColors._();

  static const bg = Color(0xFF0A0D14);
  static const surface = Color(0xFF111520);
  static const surface2 = Color(0xFF161B2A);
  static const surface3 = Color(0xFF1C2235);
  static const border = Color(0x1F63B3ED); // rgba(99,179,237,0.12)
  static const border2 = Color(0x3863B3ED); // rgba(99,179,237,0.22)
  static const accent = Color(0xFF54A0FF);
  static const accent2 = Color(0xFF5F27CD);
  static const accent3 = Color(0xFF00D2D3);
  static const text = Color(0xFFE8EAF6);
  static const text2 = Color(0xFF8892B0);
  static const text3 = Color(0xFF4A5568);
  static const success = Color(0xFF26DE81);
  static const warning = Color(0xFFFED330);
  static const danger = Color(0xFFFC5C65);
  static const flutterBlue = Color(0xFF54C5F8);
  static const flutterBlue2 = Color(0xFF01579B);

  static const radius = 12.0;
  static const radius2 = 8.0;

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  static const titleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [text, flutterBlue, accent2],
    stops: [0.0, 0.5, 1.0],
  );
}
