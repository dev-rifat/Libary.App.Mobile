/// Pill-shaped status badge (e.g. "Active"/"Pending") with an optional
/// leading dot/icon.
///
/// Work procedure:
/// 1. Set [statusText] and pick a look via [statusBgColor] (solid fill) or
///    [statusOpacityColor] (same color at 10% opacity, for a subtler badge)
///    — not both.
/// 2. Leave [prefixIcon]/[prefixWidget] null for a plain text pill, or set
///    one to prefix a status dot/icon (defaults to a green circle).
/// 3. Sizing ([btnHeight]/[btnWidth]/[borderRadius]/[textPadding]) all have
///    sane defaults — override only for a specific layout's constraints.
///
/// Usage:
/// ```dart
/// RHCustomStatusBtn(
///   statusText: 'Active',
///   statusOpacityColor: Colors.green,
///   prefixIconColor: Colors.green,
/// );
/// ```
library;

import 'package:flutter/material.dart';

class RHCustomStatusBtn extends StatelessWidget {
  /// Badge label.
  final String statusText;

  /// Border color. Defaults to transparent (no visible border).
  final Color borderColor;

  /// Solid background color. Takes precedence over [statusOpacityColor].
  final Color? statusBgColor;

  /// Background color rendered at 10% opacity; ignored if [statusBgColor]
  /// is set.
  final Color? statusOpacityColor;

  /// Style for [statusText]. Defaults to grey, 12sp.
  final TextStyle? textStyle;

  /// Corner radius. Defaults to 8.
  final double? borderRadius;

  /// Border stroke width. Defaults to 0 (no border).
  final double? borderWidth;

  /// Badge height. Defaults to 32.
  final double btnHeight;

  /// Inner content padding. Defaults to 12 horizontal / 4 vertical.
  final EdgeInsets ?textPadding;

  /// Badge width. Null sizes to content.
  final double? btnWidth;

  /// Size of [prefixIcon]. Defaults to 6.
  final double? prefixIconSize;

  /// Leading status icon (e.g. a dot). Defaults to [Icons.circle] when
  /// [prefixWidget] is also null.
  final IconData? prefixIcon;

  /// Leading widget, overrides [prefixIcon] entirely when set.
  final Widget? prefixWidget;

  /// Trailing widget, rendered after the text.
  final Widget? suffixWidget;

  /// Color of [prefixIcon]. Defaults to green.
  final Color? prefixIconColor;

  /// Color of [statusText]. Defaults to grey.
  final Color? textColor;

  const RHCustomStatusBtn(
      {super.key,
      this.statusText = "",
      this.statusBgColor,
      this.statusOpacityColor,
      this.borderRadius,
      this.prefixIcon,
      this.btnHeight = 32,
      this.suffixWidget,
      this.prefixIconSize,
      this.prefixWidget,
      this.textPadding,
      this.btnWidth,
      this.prefixIconColor,
      this.textStyle,
      this.borderWidth,
      this.textColor,
      this.borderColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: btnHeight,
      width: btnWidth,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          color: statusBgColor ??
              statusOpacityColor?.withOpacity(0.1) ??
              Colors.white,
          border: Border.all(width: borderWidth ?? 0, color: borderColor)),
      child: Padding(
        padding: textPadding?? const EdgeInsets.only(bottom: 4,top: 4,left: 12,right: 12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          direction: Axis.vertical,
          children: [
            prefixWidget != null
                ? prefixWidget!
                : prefixIcon != null
                ? _statusLayout()
                : Container(
              width: 0,
            ),
            _spacer(),
            Center(
              child: Text(
                statusText,
                style: textStyle ??
                    TextStyle(color: textColor ?? Colors.grey, fontSize: 12),
              ),
            ),
            suffixWidget ?? Container(),
          ],
        ),
      ),
    );
  }

  _spacer() {
    return prefixIcon != null
        ? const SizedBox(
      width: 12,
    )
        : const SizedBox(
      height: 0,
      width: 0,
    );
  }

  _statusLayout() {
    return Center(
      child: Icon(
        prefixIcon ?? Icons.circle,
        color: prefixIconColor ?? Colors.green,
        size: prefixIconSize ?? 6,
      ),
    );
  }
}
