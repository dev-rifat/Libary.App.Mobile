/// General-purpose bordered text field. For password entry with an
/// obscure/reveal toggle, use [RHPasswordInputField] instead.
///
/// Work procedure:
/// 1. Pass [controller] and, for validated forms, [validator] — wrap in a
///    [Form] as usual.
/// 2. Leave [textInputType] null for plain text; set it (e.g.
///    `TextInputType.emailAddress`) to change the keyboard layout.
/// 3. Add [prefixIcon]/[suffixIcon] as needed — both, either, or neither
///    are supported and each swaps in the right decoration automatically.
/// 4. Leave [inputDecoration] null to use this widget's border/fill/label
///    styling (via [corneRadius]/[borderColor]/[fillColor]/[hintStyle]);
///    pass a full [InputDecoration] only to bypass it entirely.
///
/// Usage:
/// ```dart
/// RHCustomInputField(
///   controller: emailController,
///   hitText: 'Email',
///   prefixIcon: const Icon(Icons.email_outlined),
///   textInputType: TextInputType.emailAddress,
///   validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
/// );
/// ```
library;

import 'package:flutter/material.dart';

class RHCustomInputField extends StatefulWidget {
  /// Text controller for the field's value.
  final TextEditingController controller;

  /// Floating label text.
  final String? hitText;

  /// Trailing icon widget (e.g. a clear/visibility button).
  final Widget? suffixIcon;

  /// Border corner radius. Defaults to 12.
  final double? corneRadius;

  /// Leading icon widget.
  final Widget? prefixIcon;

  /// Text cursor color. Defaults to a dark grey.
  final Color ?cursorColor;

  /// Style for the floating label and hint text.
  final TextStyle? hintStyle;

  /// Full decoration override — bypasses this widget's border/fill/label
  /// styling entirely when set.
  final InputDecoration? inputDecoration;

  /// Form field validator, used when wrapped in a [Form].
  final String? Function(String?)? validator;

  /// Called on every text change.
  final void Function(String)? onChanged; // Added onChange callback

  /// Keyboard type. Prefer [textInputType]; kept for backward compatibility.
  final TextInputType? keyboardType;

  /// Keyboard type, takes precedence over [keyboardType] when both are set.
  final TextInputType? textInputType;

  /// Style for the entered text itself (not the label/hint).
  final TextStyle? inputTextStyle;

  /// Fill color. Null renders an unfilled (outline-only) field.
  final Color? fillColor;

  /// Border color for all border states (default/focused/enabled).
  /// Defaults to grey.
  final Color? borderColor;

  const RHCustomInputField({
    super.key,
    required this.controller,
    this.corneRadius,
    this.hintStyle,
    this.cursorColor,
    this.prefixIcon,
    this.keyboardType,
    this.textInputType,
    this.inputTextStyle,
    this.fillColor,
    this.borderColor,
    this.suffixIcon,
    this.inputDecoration,
    this.hitText,
    this.validator,
    this.onChanged, // Added onChange callback
  });

  @override
  State<RHCustomInputField> createState() => _RHCustomInputFieldState();
}

class _RHCustomInputFieldState extends State<RHCustomInputField> {
  @override
  Widget build(BuildContext context) {
    final focusedCtx = FocusManager.instance.primaryFocus?.context;
    Future.delayed(const Duration(milliseconds: 200)).then((value) =>
        Scrollable.ensureVisible(
          focusedCtx ?? context,
          duration: const Duration(milliseconds: 100),
          curve: Curves.bounceInOut,
        ));

    return widget.prefixIcon != null && widget.suffixIcon != null
        ? _buildTextFormField(_inputStyleForPrefixAndPrefix())
        : widget.prefixIcon != null
        ? _buildTextFormField(_inputStyleForPrefix())
        : widget.suffixIcon != null
        ? _buildTextFormField(_inputStyleForSuffix())
        : _buildTextFormField(_inputStyle());
  }

  TextFormField _buildTextFormField(InputDecoration decoration) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType ?? widget.keyboardType ?? TextInputType.text,
      textInputAction: TextInputAction.done,
      cursorColor:widget. cursorColor ?? const Color(0xFF3B3B3B),
      style: widget.inputTextStyle,
      validator: widget.validator,
      onChanged: widget.onChanged, // Call onChange callback
      decoration: widget.inputDecoration ?? decoration,
    );
  }

  InputDecoration _inputStyle() {
    return InputDecoration(
      labelText: widget.hitText,
      labelStyle: widget.hintStyle,
      filled: widget.fillColor != null,
      fillColor: widget.fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
        borderSide: BorderSide(width: 1, color: widget.borderColor ?? Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(widget.corneRadius ?? 12),
      ),
      hintStyle: widget.hintStyle ?? const TextStyle(color: Colors.grey),
    );
  }

  InputDecoration _inputStyleForPrefix() {
    return _inputStyle().copyWith(
      prefixIcon: widget.prefixIcon,
    );
  }

  InputDecoration _inputStyleForSuffix() {
    return _inputStyle().copyWith(
      suffixIcon: widget.suffixIcon,
    );
  }

  InputDecoration _inputStyleForPrefixAndPrefix() {
    return _inputStyle().copyWith(
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
    );
  }
}