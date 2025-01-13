import 'package:flutter/material.dart';

class AppCardStyle {
  static CardTheme cardTheme = CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(
        color: Color(0x80BDBDBD),
        width: 1,
      ),
    ),
    elevation: 0,
  );
}
