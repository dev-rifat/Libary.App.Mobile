/// Small standalone helpers (color parsing, text formatting) with no
/// app-specific dependency — grouped under one [RHHelper] namespace instead
/// of scattering single-purpose classes. Every input accepts null, and
/// output shape (opacity, letter count, fallback text/color) is
/// customizable per call.
///
/// Usage:
/// ```dart
/// RHHelper.colorFromHex('#149365');                          // → Color
/// RHHelper.colorFromHex(null);                                // → fallback grey
/// RHHelper.colorFromHex('#149365', fallback: Colors.grey, opacity: 0.5);
///
/// RHHelper.initials('John Doe');                              // → 'JD'
/// RHHelper.initials('John Ronald Doe', letterCount: 3);       // → 'JRD'
/// RHHelper.initials(null, fallback: '?');                     // → '?'
///
/// RHHelper.capitalizeFirstLetter('hello');                    // → 'Hello'
/// RHHelper.capitalizeFirstLetter('hELLO', lowercaseRest: false); // → 'HELLO'
/// ```
library;

import 'package:flutter/material.dart';

/// Namespace for small, dependency-free helpers used across widgets.
class RHHelper {
  RHHelper._();

  static const Color _defaultFallbackColor = Color(0xFF9E9E9E);
  static const String _defaultInitialsFallback = 'ER';

  /// Parses a hex color string (with or without leading `#`) to a [Color].
  ///
  /// Returns [fallback] (default: a neutral grey) if [colorHex] is null,
  /// empty, or cannot be parsed. When [opacity] is set (0.0–1.0), it's
  /// applied to the resolved color (parsed or fallback) via
  /// [Color.withValues].
  static Color colorFromHex(String? colorHex, {Color? fallback, double? opacity}) {
    final resolvedFallback = fallback ?? _defaultFallbackColor;
    Color color;
    try {
      if (colorHex == null || colorHex.isEmpty) {
        color = resolvedFallback;
      } else {
        final hex = colorHex.replaceAll('#', '');
        color = Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {
      color = resolvedFallback;
    }
    return opacity != null ? color.withValues(alpha: opacity) : color;
  }

  /// Returns up to [letterCount] initials (default 2) built from the first
  /// letter of the first [letterCount] words in [fullName], uppercased
  /// unless [uppercase] is false (e.g. `'John Doe'` → `'JD'`).
  ///
  /// Returns [fallback] (default `'ER'`) when [fullName] is null, empty, or
  /// blank.
  static String initials(
    String? fullName, {
    int letterCount = 2,
    bool uppercase = true,
    String fallback = _defaultInitialsFallback,
  }) {
    final trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;

    final words = trimmed.split(RegExp(r'\s+'));
    final picked = letterCount >= words.length
        ? words
        : [...words.take(letterCount - 1), words.last];

    final result = picked
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .join();

    return uppercase ? result.toUpperCase() : result;
  }

  /// Adjusts the casing of [input]'s first letter and (optionally) the
  /// rest of the string.
  ///
  /// - [uppercaseFirst] (default true): uppercase the first letter.
  /// - [lowercaseRest] (default true): lowercase everything after the
  ///   first letter; set false to leave the rest untouched.
  ///
  /// Returns [fallback] (default `''`) when [input] is null or empty.
  static String capitalizeFirstLetter(
    String? input, {
    bool uppercaseFirst = true,
    bool lowercaseRest = true,
    String fallback = '',
  }) {
    if (input == null || input.isEmpty) return fallback;

    final first = uppercaseFirst ? input[0].toUpperCase() : input[0];
    final rest = input.substring(1);

    return first + (lowercaseRest ? rest.toLowerCase() : rest);
  }
}
