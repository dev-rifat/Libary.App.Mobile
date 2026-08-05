/// Frosted-glass floating bottom navigation bar, decoupled from any specific
/// app's bloc/state management, colors, or icon assets.
///
/// How to use:
/// 1. Track the selected tab index yourself (bloc/cubit/provider/setState —
///    this widget owns no state, it's a pure display + tap-forwarding
///    widget).
/// 2. Build one [RHGlassNavItem] per tab. Simple case: pass `icon` +
///    optional `selectedColor`/`unselectedColor` (or leave colors null to
///    use the bar's `iconSelectedColor`/`iconUnselectedColor` defaults) and
///    the bar renders + tints the SVG for you. Advanced case: pass
///    `iconBuilder` instead for full control over the icon widget.
/// 3. Pass `selectedIndex` (from step 1) and `onTap` (a callback that
///    updates that state) to [RHGlassBottomNavigationBar], alonRHide the
///    `items` list.
/// 4. Place it as your [Scaffold.bottomNavigationBar] (or anywhere in a
///    [Column]/[Stack]) — it sizes itself from [navBarHeight]/[navBarMargin]
///    and doesn't require a fixed-height parent.
/// 5. Optional: tweak blur/glass/border/circle-size/badge params — every
///    visual knob from the original design has a constructor default, so
///    only override what needs to change.
///
/// ```dart
/// Scaffold(
///   body: screens[selectedIndex],
///   bottomNavigationBar: RHGlassBottomNavigationBar(
///     selectedIndex: state.selectedIndex,
///     onTap: (i) => context.read<NavigationBloc>().add(NavigationTabChanged(i)),
///     iconSelectedColor: Colors.white,
///     iconUnselectedColor: Colors.grey,
///     items: [
///       RHGlassNavItem(
///         icon: SvgPicture.asset(Images.contactIcon),
///         activeSize: 36,
///         inactiveSize: 32,
///         badgeCount: unreadCount, // omit/null to hide the badge
///       ),
///       // ...more items, one per tab, same order as `screens`
///     ],
///   ),
/// );
/// ```
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import 'rh_responsive.dart';

/// One tab of [RHGlassBottomNavigationBar].
///
/// Simple case — pass any [icon] widget (`SvgPicture.asset(...)`,
/// `Image.asset(...)`, `Icon(...)`, whatever) plus optional
/// [selectedColor]/[unselectedColor] (or leave colors null to use the bar's
/// [RHGlassBottomNavigationBar.iconSelectedColor] /
/// [RHGlassBottomNavigationBar.iconUnselectedColor] defaults) — the bar
/// sizes + tints it for you via [ColorFiltered]/[SizedBox], same [icon]
/// widget reused for both selected/unselected states.
///
/// Advanced case — pass [iconBuilder] instead (gets `isSelected`) for full
/// control, e.g. swapping the whole icon widget by state. Overrides [icon]
/// entirely when set.
class RHGlassNavItem {
  const RHGlassNavItem({
    this.icon,
    this.iconBuilder,
    this.activeSize = 26.0,
    this.inactiveSize = 22.0,
    this.selectedColor,
    this.unselectedColor,
    this.badgeCount,
  }) : assert(
          icon != null || iconBuilder != null,
          'provide either icon or iconBuilder',
        );

  /// Any icon widget — sized + tinted automatically. Ignored when
  /// [iconBuilder] is set.
  final Widget? icon;

  /// Escape hatch: build the icon yourself. Overrides [icon] when set.
  final Widget Function(BuildContext context, bool isSelected)? iconBuilder;

  /// Icon size when this tab is selected, scaled via `context.sp`.
  final double activeSize;

  /// Icon size when this tab is unselected, scaled via `context.sp`.
  final double inactiveSize;

  /// Tint used when selected. Falls back to the bar's
  /// `iconSelectedColor` (or `Theme.colorScheme.onPrimary`) when null.
  final Color? selectedColor;

  /// Tint used when unselected. Falls back to the bar's
  /// `iconUnselectedColor` (or `Theme.unselectedWidgetColor`) when null.
  final Color? unselectedColor;

  /// Small counter badge shown top-right of this item when > 0 and not
  /// selected. Pass `null`/0 to hide.
  final int? badgeCount;
}

/// Frosted-glass floating bottom navigation bar.
///
/// Usage:
/// ```dart
/// RHGlassBottomNavigationBar(
///   selectedIndex: state.selectedIndex,
///   onTap: (i) => context.read<NavigationBloc>().add(NavigationTabChanged(i)),
///   iconSelectedColor: Colors.white,
///   iconUnselectedColor: Colors.grey,
///   items: [
///     RHGlassNavItem(icon: SvgPicture.asset(Images.contactIcon), activeSize: 36, inactiveSize: 32),
///     // ...more items
///   ],
/// );
/// ```
class RHGlassBottomNavigationBar extends StatefulWidget {
  const RHGlassBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.navBarHeight = 70.0,
    this.navBarMargin = 20.0,
    this.navBarRadius = 35.0,
    this.animationDuration = const Duration(milliseconds: 400),
    this.blurSigma = 2.0,
    this.glassOpacityStart = 0.08,
    this.glassOpacityEnd = 0.12,
    this.borderOpacity = 0.8,
    this.borderWidth = 2.0,
    this.selectedCircleSize = 56.0,
    this.unselectedCircleSize = 50.0,
    this.selectedColor,
    this.iconSelectedColor,
    this.iconUnselectedColor,
    this.badgeColor = Colors.red,
    this.badgeTextColor = Colors.white,
  }) : assert(
          selectedIndex >= 0 && selectedIndex < items.length,
          'selectedIndex must be within items range',
        );

  /// Tabs shown left-to-right, evenly spaced.
  final List<RHGlassNavItem> items;

  /// Index into [items] currently highlighted.
  final int selectedIndex;

  /// Called with the tapped tab's index.
  final ValueChanged<int> onTap;

  /// Bar height, scaled via `context.h`.
  final double navBarHeight;

  /// Space around the bar giving it a floating look, scaled via `context.w`.
  final double navBarMargin;

  /// Corner radius, scaled via `context.r`.
  final double navBarRadius;

  /// Duration of the selected-circle resize/color transition.
  final Duration animationDuration;

  /// Backdrop blur strength. Lower = crystal clear, higher = frosted.
  final double blurSigma;

  /// Glass gradient start opacity (top-left), light theme only.
  final double glassOpacityStart;

  /// Glass gradient end opacity (bottom-right), light theme only.
  final double glassOpacityEnd;

  /// Border opacity, light theme only (dark theme uses a fixed low opacity).
  final double borderOpacity;

  /// Border stroke width.
  final double borderWidth;

  /// Diameter of the selected tab's circle, scaled via `context.w`.
  final double selectedCircleSize;

  /// Diameter of an unselected tab's circle, scaled via `context.w`.
  final double unselectedCircleSize;

  /// Default icon tint when a tab is selected, used for items that don't set
  /// [RHGlassNavItem.selectedColor] and don't use [RHGlassNavItem.iconBuilder].
  /// Falls back to `Theme.of(context).colorScheme.onPrimary`.
  final Color? iconSelectedColor;

  /// Default icon tint when a tab is unselected, used for items that don't
  /// set [RHGlassNavItem.unselectedColor] and don't use
  /// [RHGlassNavItem.iconBuilder]. Falls back to
  /// `Theme.of(context).unselectedWidgetColor`.
  final Color? iconUnselectedColor;

  /// Background of the selected item's circle. Defaults to
  /// `Theme.of(context).colorScheme.primary`.
  final Color? selectedColor;

  /// Fill color of the unread-count badge.
  final Color badgeColor;

  /// Text color of the unread-count badge.
  final Color badgeTextColor;

  @override
  State<RHGlassBottomNavigationBar> createState() =>
      _RHGlassBottomNavigationBarState();
}

class _RHGlassBottomNavigationBarState extends State<RHGlassBottomNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _createControllers();
  }

  List<AnimationController> _createControllers() {
    return List.generate(widget.items.length, (index) {
      final controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        value: index == widget.selectedIndex ? 1.0 : 0.0,
      );
      return controller;
    });
  }

  @override
  void didUpdateWidget(covariant RHGlassBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      for (final controller in _controllers) {
        controller.dispose();
      }
      _controllers = _createControllers();
      return;
    }

    if (oldWidget.animationDuration != widget.animationDuration) {
      for (final controller in _controllers) {
        controller.duration = widget.animationDuration;
      }
    }

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controllers[oldWidget.selectedIndex].reverse();
      _controllers[widget.selectedIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.w(widget.navBarMargin)),
      height: context.h(widget.navBarHeight),
      decoration: _buildNavBarShadow(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(widget.navBarRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(
            decoration: _buildGlassDecoration(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                widget.items.length,
                (index) => _buildNavItemWidget(context, index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildNavBarShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(context.r(widget.navBarRadius)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
          blurRadius: 15,
          spreadRadius: -5,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.5),
          blurRadius: 10,
          spreadRadius: -8,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  BoxDecoration _buildGlassDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: widget.borderOpacity);
    final innerGlowColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.2);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glassColor.withValues(
            alpha: isDark ? 0.15 : widget.glassOpacityStart,
          ),
          glassColor.withValues(alpha: isDark ? 0.25 : widget.glassOpacityEnd),
        ],
      ),
      borderRadius: BorderRadius.circular(context.r(widget.navBarRadius)),
      border: Border.all(color: borderColor, width: widget.borderWidth),
      boxShadow: [
        BoxShadow(
          color: innerGlowColor,
          blurRadius: 10,
          spreadRadius: -5,
          offset: const Offset(0, -5),
        ),
      ],
    );
  }

  Widget _buildIcon(
      BuildContext context, RHGlassNavItem item, bool isSelected) {
    if (item.iconBuilder != null) return item.iconBuilder!(context, isSelected);

    final tint = isSelected
        ? (item.selectedColor ??
            widget.iconSelectedColor ??
            Theme.of(context).colorScheme.onPrimary)
        : (item.unselectedColor ??
            widget.iconUnselectedColor ??
            Theme.of(context).unselectedWidgetColor);
    final size = context.sp(isSelected ? item.activeSize : item.inactiveSize);

    return SizedBox(
      width: size,
      height: size,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
        child: FittedBox(fit: BoxFit.contain, child: item.icon!),
      ),
    );
  }

  Widget _buildNavItemWidget(BuildContext context, int index) {
    final isSelected = widget.selectedIndex == index;
    final item = widget.items[index];
    final badgeCount = item.badgeCount ?? 0;
    final selectedColor =
        widget.selectedColor ?? Theme.of(context).colorScheme.primary;
    final curved = CurvedAnimation(
      parent: _controllers[index],
      curve: Curves.easeInOutCubic,
    );

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final diameter = context.w(
              lerpDouble(
                widget.unselectedCircleSize,
                widget.selectedCircleSize,
                curved.value,
              )!,
            );
            return Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: Color.lerp(
                  selectedColor.withValues(alpha: 0),
                  selectedColor,
                  curved.value,
                ),
                shape: BoxShape.circle,
              ),
              child: child,
            );
          },
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIcon(context, item, isSelected),
                if (badgeCount > 0 && !isSelected)
                  Positioned(
                    right: 8,
                    top: 10,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: TextStyle(
                            fontSize: context.sp(8),
                            fontWeight: FontWeight.w700,
                            color: widget.badgeTextColor,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [RHGlassBottomNavigationBar] + [Scaffold] combo that owns the selected-tab
/// state itself — pass `screens`/`items` and it wires `selectedIndex`/`onTap`
/// for you. Use [RHGlassBottomNavigationBar] directly instead when the
/// selected tab must be driven by external state (bloc/cubit/route).
///
/// How to use:
/// 1. Build your tab screens as normal widgets — no navigation wiring
///    needed inside them, this widget handles tab switching.
/// 2. Build one [RHGlassNavItem] per screen, same order as `screens`
///    (`icon` widget + optional colors/badge — see [RHGlassNavItem] docs).
/// 3. Pass both lists to [RHGlassBottomNavigationScreen] — lengths must
///    match (asserted). Use it as the screen's root widget (e.g. return it
///    directly from your route/page builder).
/// 4. Optional: `initialIndex` to start on a tab other than 0.
/// 5. Optional: same visual knobs as [RHGlassBottomNavigationBar]
///    (`navBarHeight`, `blurSigma`, `selectedColor`, `iconSelectedColor`,
///    `badgeColor`, etc.) — forwarded straight through.
/// 6. Need the selected tab driven by a bloc/route instead of local state
///    (e.g. deep-linking to a tab)? Use [RHGlassBottomNavigationBar] +
///    [Scaffold] yourself rather than this widget.
///
/// ```dart
/// RHGlassBottomNavigationScreen(
///   screens: [ContactScreen(), OrRHcreen(), MonitorScreen()],
///   items: [
///     RHGlassNavItem(icon: SvgPicture.asset(Images.contactIcon), activeSize: 36, inactiveSize: 32),
///     RHGlassNavItem(icon: SvgPicture.asset(Images.orgIcon), activeSize: 55, inactiveSize: 55),
///     RHGlassNavItem(icon: SvgPicture.asset(Images.monitorIcon), activeSize: 26, inactiveSize: 26),
///   ],
/// );
/// ```
class RHGlassBottomNavigationScreen extends StatefulWidget {
  const RHGlassBottomNavigationScreen({
    super.key,
    required this.screens,
    required this.items,
    this.initialIndex = 0,
    this.navBarHeight = 70.0,
    this.navBarMargin = 20.0,
    this.navBarRadius = 35.0,
    this.animationDuration = const Duration(milliseconds: 400),
    this.blurSigma = 2.0,
    this.glassOpacityStart = 0.08,
    this.glassOpacityEnd = 0.12,
    this.borderOpacity = 0.8,
    this.borderWidth = 2.0,
    this.selectedCircleSize = 56.0,
    this.unselectedCircleSize = 50.0,
    this.selectedColor,
    this.iconSelectedColor,
    this.iconUnselectedColor,
    this.badgeColor = Colors.red,
    this.badgeTextColor = Colors.white,
  }) : assert(
          screens.length == items.length,
          'screens and items count should be equal',
        );

  /// One screen per tab, same order as [items]. Kept alive across tab
  /// switches via [IndexedStack].
  final List<Widget> screens;

  /// One [RHGlassNavItem] per tab, same order as [screens].
  final List<RHGlassNavItem> items;

  /// Tab shown on first build.
  final int initialIndex;

  // Forwarded verbatim to RHGlassBottomNavigationBar — see there for docs.
  final double navBarHeight;
  final double navBarMargin;
  final double navBarRadius;
  final Duration animationDuration;
  final double blurSigma;
  final double glassOpacityStart;
  final double glassOpacityEnd;
  final double borderOpacity;
  final double borderWidth;
  final double selectedCircleSize;
  final double unselectedCircleSize;
  final Color? selectedColor;
  final Color? iconSelectedColor;
  final Color? iconUnselectedColor;
  final Color badgeColor;
  final Color badgeTextColor;

  @override
  State<RHGlassBottomNavigationScreen> createState() =>
      _RHGlassBottomNavigationScreenState();
}

class _RHGlassBottomNavigationScreenState
    extends State<RHGlassBottomNavigationScreen> {
  late int _selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: widget.screens),
      bottomNavigationBar: RHGlassBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: widget.items,
        navBarHeight: widget.navBarHeight,
        navBarMargin: widget.navBarMargin,
        navBarRadius: widget.navBarRadius,
        animationDuration: widget.animationDuration,
        blurSigma: widget.blurSigma,
        glassOpacityStart: widget.glassOpacityStart,
        glassOpacityEnd: widget.glassOpacityEnd,
        borderOpacity: widget.borderOpacity,
        borderWidth: widget.borderWidth,
        selectedCircleSize: widget.selectedCircleSize,
        unselectedCircleSize: widget.unselectedCircleSize,
        selectedColor: widget.selectedColor,
        iconSelectedColor: widget.iconSelectedColor,
        iconUnselectedColor: widget.iconUnselectedColor,
        badgeColor: widget.badgeColor,
        badgeTextColor: widget.badgeTextColor,
      ),
    );
  }
}
