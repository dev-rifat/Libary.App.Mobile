/// Shimmer loading placeholders, theme-aware with no app-specific color
/// dependency — callers can override [baseColor]/[highlightColor] per
/// widget, otherwise falls back to [Theme]'s brightness-appropriate greys.
///
/// Work procedure:
/// 1. Build the real content's skeleton first — [RHShimmerBox]/
///    [RHShimmerCircle] in the same layout (rows/columns) the loaded
///    content will use, so there's no layout shift once data arrives.
/// 2. Wrap that skeleton in one [RHShimmerLoading], not one per box — a
///    single sweep animates all children together.
/// 3. Drive [RHShimmerLoading.enabled] from the screen's loading state;
///    flip it off (or swap in the real widget tree) once data loads.
///
/// Usage — list item skeleton:
/// ```dart
/// RHShimmerLoading(
///   enabled: isLoading,
///   child: Row(
///     children: [
///       const RHShimmerCircle(size: 40),
///       const SizedBox(width: 12),
///       Expanded(
///         child: Column(
///           crossAxisAlignment: CrossAxisAlignment.start,
///           children: const [
///             RHShimmerBox(width: double.infinity, height: 14),
///             SizedBox(height: 8),
///             RHShimmerBox(width: 120, height: 14),
///           ],
///         ),
///       ),
///     ],
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:RH_ui_library/rh_responsive.dart';

/// Wraps [child] in a shimmer sweep while [enabled] is true; otherwise
/// renders [child] unchanged (e.g. once real content has loaded).
class RHShimmerLoading extends StatelessWidget {
  const RHShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  });

  /// Content the shimmer sweep animates over.
  final Widget child;

  /// When false, [child] renders as-is with no shimmer effect.
  final bool enabled;

  /// Base (resting) color of the sweep. Defaults to a theme-appropriate grey.
  final Color? baseColor;

  /// Highlight color the sweep passes through. Defaults to a theme-appropriate grey.
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBase = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final defaultHighlight = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBase,
      highlightColor: highlightColor ?? defaultHighlight,
      child: child,
    );
  }
}

/// Rectangular shimmer placeholder (e.g. for text lines, image blocks).
class RHShimmerBox extends StatelessWidget {
  const RHShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
  });

  /// Box width. Null lets the parent constrain it.
  final double? width;

  /// Box height. Null lets the parent constrain it.
  final double? height;

  /// Corner rounding. Defaults to an 8dp radius scaled via [RHResponsive.r].
  final BorderRadius? borderRadius;

  /// Fill color. Defaults to a theme-appropriate grey.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? (isDark ? Colors.grey[850] : Colors.grey[300]),
        borderRadius: borderRadius ?? BorderRadius.circular(context.r(8)),
      ),
    );
  }
}

/// Circular shimmer placeholder (e.g. for avatars).
class RHShimmerCircle extends StatelessWidget {
  const RHShimmerCircle({super.key, required this.size, this.color});

  /// Diameter of the circle.
  final double size;

  /// Fill color. Defaults to a theme-appropriate grey.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? (isDark ? Colors.grey[850] : Colors.grey[300]),
        shape: BoxShape.circle,
      ),
    );
  }
}
