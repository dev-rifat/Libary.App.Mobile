/// Password field with a built-in obscure/reveal toggle (eye icon). For a
/// plain text field, use [RHCustomInputField] instead.
///
/// Work procedure:
/// 1. Pass [controller]; the obscure/reveal toggle and its icon swap are
///    handled internally — no extra state needed on the caller's side.
/// 2. Leave [suffixVisibleIcon]/[suffixHideIcon] null for the default
///    Cupertino eye/eye-slash icons; override only for a different icon set.
/// 3. Pass [suffixWidget] instead to replace the toggle entirely (loses the
///    built-in obscure/reveal behavior — handle visibility yourself).
///
/// Usage:
/// ```dart
/// RHPasswordInputField(
///   controller: passwordController,
///   hitText: 'Password',
///   prefixIcon: const Icon(Icons.lock_outline),
///   validator: (v) => (v == null || v.length < 8) ? 'Min 8 characters' : null,
/// );
/// ```
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RHPasswordInputField extends StatefulWidget {
  /// Text controller for the field's value.
  final TextEditingController controller;

  /// Floating label text.
  final String? hitText;

  /// Overrides the built-in obscure/reveal toggle entirely when set.
  final Widget? suffixWidget;

  /// Icon shown when the password is visible (tapping hides it). Defaults
  /// to [CupertinoIcons.eye].
  final IconData? suffixVisibleIcon;

  /// Icon shown when the password is hidden (tapping reveals it). Defaults
  /// to [CupertinoIcons.eye_slash].
  final IconData? suffixHideIcon;

  /// Border corner radius. Defaults to 12.
  final double? corneRadius;

  /// Leading icon widget.
  final Widget? prefixIcon;

  /// Text cursor color. Defaults to a dark grey.
  final Color? cursorColor;

  /// Full decoration override — bypasses this widget's border/fill/label
  /// styling (and the built-in toggle icon) entirely when set.
  final InputDecoration? inputDecoration;

  /// Style for the floating label and hint text.
  final TextStyle? hintStyle;

  /// Form field validator, used when wrapped in a [Form].
  final String? Function(String?)? validator;

  /// Called on every text change.
  final void Function(String)? onChanged; // Added onChange callback

  /// Keyboard type. Prefer [textInputType]; kept for backward compatibility.
  final TextInputType? keyboardType;

  /// Keyboard type, takes precedence over [keyboardType] when both are set.
  /// Defaults to [TextInputType.visiblePassword].
  final TextInputType? textInputType;

  /// Style for the entered text itself (not the label/hint).
  final TextStyle? inputTextStyle;

  /// Fill color. Null renders an unfilled (outline-only) field.
  final Color? fillColor;

  /// Border color for all border states (default/focused/enabled).
  /// Defaults to grey.
  final Color? borderColor;

  const RHPasswordInputField(
      {super.key,
        required this.controller,
        this.corneRadius,
        this.cursorColor,
        this.hintStyle,
        this.prefixIcon,
        this.suffixHideIcon,
        this.inputDecoration,
        this.suffixVisibleIcon,
        this.keyboardType,
        this.textInputType,
        this.inputTextStyle,
        this.fillColor,
        this.borderColor,
        this.hitText,
        this.onChanged,
        this.suffixWidget,
        this.validator});
  @override
  State<RHPasswordInputField> createState() => _RHCustomInputFieldState();
}

class _RHCustomInputFieldState extends State<RHPasswordInputField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    final focusedCtx = FocusManager.instance.primaryFocus?.context;
    Future.delayed(const Duration(milliseconds: 200))
        .then((value) => Scrollable.ensureVisible(
      focusedCtx ?? context,
      duration: const Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    ));

    /// Widget according to style
    return widget.prefixIcon == null
        ? TextFormField(
        validator: widget.validator,
        keyboardType: widget.textInputType ?? widget.keyboardType ?? TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        controller: widget.controller,
        obscureText: obscureText,
        cursorColor: widget.cursorColor?? const Color(0xFF3B3B3B),
        style: widget.inputTextStyle,
        onChanged: widget.onChanged,
        decoration: widget.inputDecoration ?? _inputStyleForSuffix())
        : TextFormField(
        validator: widget.validator,
        keyboardType: widget.textInputType ?? widget.keyboardType ?? TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        obscureText: obscureText,
        cursorColor: widget.cursorColor?? const Color(0xFF3B3B3B),
        style: widget.inputTextStyle,
        controller: widget.controller,
        onChanged: widget.onChanged,
        decoration:
        widget.inputDecoration ?? _inputStyleForSuffixAndPrefix());
  }

  _inputStyleForSuffix() {
    return InputDecoration(
      labelText: widget.hitText ?? "Enter input here",
      labelStyle: widget.hintStyle ?? const TextStyle(),
      filled: widget.fillColor != null,
      fillColor: widget.fillColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
          borderSide: BorderSide(width: 1, color: widget.borderColor ?? Colors.grey)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
      ),
      suffixIcon: widget.suffixWidget ?? (_showPasswordIconLayout()),
      hintStyle: widget.hintStyle ?? const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
          borderRadius: BorderRadius.circular(widget.corneRadius ?? 12)),
    );
  }

  _inputStyleForSuffixAndPrefix() {
    return InputDecoration(
      labelText: widget.hitText ?? "Enter input here",
      labelStyle: widget.hintStyle ?? const TextStyle(),
      filled: widget.fillColor != null,
      fillColor: widget.fillColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
          borderSide: BorderSide(width: 1, color: widget.borderColor ?? Colors.grey)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
      ),
      suffixIcon: widget.suffixWidget ?? (_showPasswordIconLayout()),
      prefixIcon: widget.prefixIcon,
      hintStyle: widget.hintStyle ?? const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
          borderRadius: BorderRadius.circular(widget.corneRadius ?? 12)),
    );
  }

  _showPasswordIconLayout() {
    return IconButton(
      icon: Icon(
        obscureText
            ? widget.suffixHideIcon ?? CupertinoIcons.eye_slash
            : widget.suffixVisibleIcon ?? CupertinoIcons.eye,
      ),
      onPressed: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
    );
  }
}