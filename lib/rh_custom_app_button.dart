/// Full-width (by default) pill/rounded button with optional prefix/suffix
/// widgets, or a fully custom [widget] in place of the text row.
///
/// Work procedure:
/// 1. Set [text] and [onPressed]; leave everything else at its default
///    (blue fill, white text, 48dp tall, fully rounded) for a standard CTA.
/// 2. Add [prefixWidget]/[suffixWidget] (e.g. an icon) to flank the text —
///    both are optional and independent.
/// 3. Pass [widget] instead of [text] only when the button's content isn't
///    a simple text row (e.g. a loading spinner) — it replaces the whole
///    content area.
///
/// Usage:
/// ```dart
/// RHCustomAppButton(
///   text: 'Sign in',
///   onPressed: () => submit(),
/// );
/// ```
library;

import 'package:flutter/material.dart';

class RHCustomAppButton extends StatelessWidget {
  /// Button label. Ignored when [widget] is set.
  final String text;

  /// Fill color. Defaults to blue.
  final Color buttonColor;

  /// [text] color, used when [btnTextStyle] is null. Defaults to white.
  final Color buttonTextColor;

  /// Border color. Defaults to transparent (no visible border).
  final Color btnBorderColor;

  /// Corner radius. Defaults to 30 (fully rounded at the default height).
  /// Ignored when [borderRadius] is set.
  final double buttonRadius;

  /// Per-corner radius override, takes precedence over [buttonRadius] when set.
  final BorderRadius? borderRadius;

  /// Button height. Defaults to 48.
  final double buttonHeight;

  /// Button width. Defaults to the screen width.
  final double? buttonWidth;

  /// Replaces the default text row entirely when set (e.g. a loading
  /// spinner in place of the label).
  final Widget? widget;

  /// Widget shown before [text].
  final Widget? prefixWidget;

  /// Widget shown after [text].
  final Widget? suffixWidget;

  /// Border stroke width. Defaults to 1.
  final double borderWidth;

  /// Tap handler. No-op (button still renders, but is inert) when null.
  final Function? onPressed;

  /// Style for [text]. Defaults to [buttonTextColor] at 18sp.
  final TextStyle? btnTextStyle;

  const RHCustomAppButton(
      {super.key,
      this.text = "",
      this.widget,
      this.btnBorderColor = Colors.transparent,
      this.borderWidth = 1.0,
      this.buttonHeight = 48,
      this.buttonWidth,
      this.prefixWidget,
      this.suffixWidget,
      this.btnTextStyle,
      this.buttonColor = Colors.blue,
      this.buttonTextColor = Colors.white,
      this.onPressed,
      this.buttonRadius = 30,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///Button click action
      onTap: () => onPressed == null ? null : onPressed!(),
      child: Container(
        height: buttonHeight,
        width: buttonWidth ?? MediaQuery.of(context).size.width,

        ///Button style
        decoration: _buttonStyle(),
        child: Center(
          child: widget ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Prefix widget
                  prefixWidget ?? Container(),
                  _spacer(),
                  Text(
                    text,
                    textAlign: TextAlign.center,

                    ///Button text style
                    style: _textStyle(),
                  ),
                  _spacer(),

                  /// Suffix widget
                  suffixWidget ?? Container()
                ],
              ),
        ),
      ),
    );
  }

  _buttonStyle() {
    return BoxDecoration(
        border: Border.all(width: borderWidth, color: btnBorderColor),
        color: buttonColor,
        borderRadius: borderRadius ?? BorderRadius.circular(buttonRadius));
  }

  _textStyle() {
    return btnTextStyle ?? TextStyle(color: buttonTextColor, fontSize: 18);
  }

  _spacer() {
    return const SizedBox(
      width: 12,
    );
  }
}
