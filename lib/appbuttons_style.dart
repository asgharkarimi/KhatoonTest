import 'package:flutter/material.dart';

class AppButtonStyle {
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.green, // Background color
    foregroundColor: Colors.white, // Text color
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Button padding
    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Text style
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
  );
}