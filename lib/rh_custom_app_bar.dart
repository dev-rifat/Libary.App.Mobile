/// App bar with app-agnostic theming (no hardcoded app colors/fonts) and an
/// optional edge-to-edge mode that draws behind the status bar.
///
/// Work procedure:
/// 1. Pick a mode: default (standard [AppBar], safe-area respecting) or
///    [RHCustomAppBar.extendBehindStatusBar] (a plain [Row] inside an
///    [AnnotatedRegion], used when the screen body should show through/
///    behind the status bar, e.g. a hero image header).
/// 2. Leave [backgroundColor] null to inherit [Theme]'s app bar background;
///    pass a color only when this screen needs to differ from the theme.
/// 3. Leave [onLeadingPressed] null for standard back navigation
///    (pops via [Navigator] when possible); pass a callback only to
///    override that behavior (e.g. show a confirm dialog before leaving).
/// 4. Wire [preferredSize] into a [Scaffold.appBar] like any [AppBar] —
///    it already accounts for [bottom]'s height.
///
/// Usage — standard app bar:
/// ```dart
/// Scaffold(
///   appBar: RHCustomAppBar(title: 'SettinRH'),
///   body: ...,
/// );
/// ```
///
/// Usage — edge-to-edge header over a hero image:
/// ```dart
/// Scaffold(
///   extendBodyBehindAppBar: true,
///   appBar: RHCustomAppBar(
///     extendBehindStatusBar: true,
///     backgroundColor: Colors.transparent,
///     title: 'Profile',
///     actions: [IconButton(icon: Icon(Icons.share), onPressed: () {})],
///   ),
///   body: ...,
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:RH_ui_library/rh_responsive.dart';

class RHCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RHCustomAppBar({
    super.key,
    this.title,
    this.titleStyle,
    this.onLeadingPressed,
    this.leadingIcon,
    this.leadingWidth,
    this.actions,
    this.backgroundColor,
    this.centerTitle = false,
    this.showLeading = true,
    this.bottom,
    this.extendBehindStatusBar = false,
    this.fontSizeMid = 16,
  });

  /// App bar title text. Null renders no title.
  final String? title;

  /// Title text style. Defaults to [fontSizeMid].
  final TextStyle? titleStyle;

  /// Leading button tap handler. Null falls back to popping the current
  /// route via [Navigator] when possible.
  final VoidCallback? onLeadingPressed;

  /// Leading icon widget. Defaults to a back arrow.
  final Widget? leadingIcon;

  /// Width reserved for the leading slot. Also used as the gap when
  /// [showLeading] is false.
  final double? leadingWidth;

  /// Trailing action widgets, rendered after the title.
  final List<Widget>? actions;

  /// App bar background. Null inherits [Theme]'s app bar background,
  /// falling back to [ColorScheme.surface].
  final Color? backgroundColor;

  /// Centers [title] when [showLeading] is false (a leading widget forces
  /// left alignment).
  final bool centerTitle;

  /// Whether to render the leading (back) button/slot at all.
  final bool showLeading;

  /// Optional widget placed below the app bar (e.g. a [TabBar]); its
  /// height is folded into [preferredSize].
  final PreferredSizeWidget? bottom;

  /// When true, draws behind the status bar instead of below it — use with
  /// `Scaffold.extendBodyBehindAppBar: true`.
  final bool extendBehindStatusBar;

  /// Base font size for the title and leading icon (icon renders 4dp larger).
  final double fontSizeMid;

  TextStyle get _titleStyle => titleStyle ?? TextStyle(fontSize: fontSizeMid);

  void _popRoute(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildLeading(BuildContext context) {
    return IconButton(
      onPressed: onLeadingPressed ?? () => _popRoute(context),
      icon: leadingIcon ?? Icon(Icons.arrow_back_ios, size: fontSizeMid + 4),
    );
  }

  SystemUiOverlayStyle _overlayStyle(bool isDark) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (extendBehindStatusBar) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _overlayStyle(isDark),
        child: Container(
          color: bgColor,
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
          child: Row(
            children: [
              if (showLeading)
                _buildLeading(context)
              else
                SizedBox(width: leadingWidth ?? 0),

              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: _titleStyle,
                    textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  ),
                ),

              if (actions != null) ...actions!,
            ],
          ),
        ),
      );
    }

    return AppBar(
      elevation: 0,
      backgroundColor: bgColor,
      surfaceTintColor: bgColor,
      systemOverlayStyle: _overlayStyle(isDark),
      automaticallyImplyLeading: false,
      leadingWidth: showLeading ? leadingWidth : 0,
      leading: showLeading ? _buildLeading(context) : null,
      centerTitle: showLeading ? false : centerTitle,
      title: Text(title ?? '', style: _titleStyle),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
