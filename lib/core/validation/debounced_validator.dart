import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debounced validator for real-time form validation
/// Story 1.1: Create Account with Email and Password
///
/// Delays validation execution to avoid excessive calls during user input.
/// Useful for expensive validation operations or API calls.
///
/// Example:
/// ```dart
/// final debouncer = DebouncedValidator();
///
/// // In form field onChanged callback
/// onChanged: (value) {
///   debouncer.run(() {
///     // This will only execute after user stops typing for 300ms
///     validateEmail(value);
///   });
/// }
///
/// // Don't forget to dispose
/// @override
/// void dispose() {
///   debouncer.dispose();
///   super.dispose();
/// }
/// ```
class DebouncedValidator {
  Timer? _debounce;

  /// Runs the given action after a delay.
  ///
  /// If called multiple times rapidly, only the last call's action will execute.
  /// Previous pending timers are cancelled.
  ///
  /// Parameters:
  /// - [action]: The callback to execute after delay
  /// - [delay]: Duration to wait before execution (default: 300ms)
  ///
  /// Example:
  /// ```dart
  /// validator.run(() {
  ///   print('This runs after 300ms of inactivity');
  /// });
  /// ```
  void run(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    // Cancel any existing timer
    _debounce?.cancel();

    // Start new timer
    _debounce = Timer(delay, action);
  }

  /// Cancels any pending timer.
  ///
  /// Should be called in the widget's dispose() method to prevent
  /// memory leaks and callbacks executing after widget disposal.
  ///
  /// Safe to call multiple times.
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
  }
}
