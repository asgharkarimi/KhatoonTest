import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class ThreeDigitInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is empty, return it as-is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If the cleaned text is empty, return an empty value
    if (cleanedText.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse the cleaned text as an integer
    int value = int.parse(cleanedText);

    // Format the number with commas (English Locale)
    final formatter = NumberFormat("#,###", 'en_US'); // Use 'en_US' for English
    String formattedValue = formatter.format(value);


    // Calculate the new cursor position
    int newCursorPosition = newValue.selection.baseOffset;

    // Adjust the cursor position based on the difference between the old and new text lengths
    int offsetDifference = formattedValue.length - newValue.text.length;
    newCursorPosition += offsetDifference;

    // Ensure the cursor position is within bounds
    newCursorPosition = newCursorPosition.clamp(0, formattedValue.length);

    // Return the formatted value with the updated cursor position
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}