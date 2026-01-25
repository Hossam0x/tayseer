import 'package:flutter/material.dart';

/// Keyboard Helper Utilities
///
/// Provides utilities for managing keyboard visibility
class KeyboardHelper {
  /// Hide the keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Show the keyboard for a specific focus node
  static void showKeyboard(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Check if keyboard is currently visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
}
