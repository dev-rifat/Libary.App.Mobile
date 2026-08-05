/// Responsive sizing for any device (phone/tablet/desktop) via MediaQuery,
/// no ScreenUtil dependency.
///
/// Work process:
/// 1. Read current screen size from `MediaQuery.sizeOf(context)`.
/// 2. Classify [DeviceType] from `shortestSide` (orientation-independent):
///    mobile <600dp, tablet 600–905dp, desktop ≥905dp.
/// 3. For [w]/[h]/[sp]: divide current screen width/height by the design
///    reference size (390x844) to get a raw scale factor, then clamp it to
///    0.75–1.5 so tiny phones don't shrink below readable size and
///    tablets/desktop don't scale up proportionally to their much larger
///    width.
/// 4. For [responsive]: skip scaling entirely — just pick the value that
///    matches the detected [DeviceType] (e.g. different column count per
///    device), falling back to [responsive]'s `mobile` value when a
///    larger-device override isn't given.
///
/// Usage:
/// ```dart
/// Padding(
///   padding: context.insetsAll(16),
///   child: Text('Hi', style: TextStyle(fontSize: context.sp(14))),
/// );
/// final columns = context.responsive(mobile: 1, tablet: 2, desktop: 3);
/// if (context.isTablet) { /* two-column layout */ }
/// ```
///
/// Migration note: this coexists with `flutter_screenutil` (`.w`/`.h`/`.sp`
/// on `num`) since this extension lives on `BuildContext`, not `num` — no
/// naming collision. Migrate one file/feature at a time; ScreenUtil stays
/// until every call site is moved, then drop the package.
library;

import 'package:flutter/material.dart';

/// Design reference size (matches ScreenUtilInit's designSize in main.dart:
/// iPhone 13/14, 390x844) so values scale consistently on both paths.
const double _designWidth = 390;
const double _designHeight = 844;

/// shortestSide breakpoints, matching Material's phone/tablet/desktop split.
const double _tabletBreakpoint = 600;
const double _desktopBreakpoint = 905;

enum DeviceType { mobile, tablet, desktop }

/// Precomputed, clamped scale factors for one screen [Size] — [w]/[h]/[sp]
/// each do one multiply against these instead of re-deriving from scratch,
/// and the whole struct is cached per size (see [_ScaleCache]) so a frame
/// with hundreds of `context.w()`/`.h()`/`.sp()` calls only computes it once.
class _Scale {
  _Scale(Size size)
    : widthScale = _clamp(size.width / _designWidth),
      heightScale = _clamp(size.height / _designHeight),
      fontScale = _clamp(
        (size.width / _designWidth) < (size.height / _designHeight)
            ? size.width / _designWidth
            : size.height / _designHeight,
      );

  final double widthScale;
  final double heightScale;
  final double fontScale;

  static double _clamp(double scale) => scale.clamp(0.75, 1.5);
}

/// Caches the last computed [_Scale] by screen [Size] so repeated resizing
/// calls within (or across) a frame for the same size skip recomputation.
/// A single-entry cache is enough in practice — apps run at one screen size
/// at a time, with a brief mix only during a live resize/rotation.
class _ScaleCache {
  static Size? _lastSize;
  static _Scale? _lastScale;

  static _Scale of(Size size) {
    if (_lastSize == size) return _lastScale!;
    final scale = _Scale(size);

    _lastSize = size;
    _lastScale = scale;
    return scale;
  }
}

/// MediaQuery-based responsive sizing, without the ScreenUtil dependency.
/// Use for new code; existing .w/.h/.sp (ScreenUtil) calls stay as-is.
extension RHResponsive on BuildContext {
  Size get _screenSize => MediaQuery.sizeOf(this);

  _Scale get _scale => _ScaleCache.of(_screenSize);

  DeviceType get deviceType {
    final shortestSide = _screenSize.shortestSide;
    if (shortestSide >= _desktopBreakpoint) return DeviceType.desktop;
    if (shortestSide >= _tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  bool get isMobile => deviceType == DeviceType.mobile;

  bool get isTablet => deviceType == DeviceType.tablet;

  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Scale a width value from the design size to the current screen.
  double w(double value) => value * _scale.widthScale;

  /// Scale a height value from the design size to the current screen.
  double h(double value) => value * _scale.heightScale;

  /// Scale a font size from the design size to the current screen.
  double sp(double value) => value * _scale.fontScale;

  /// Auto-picks a value by detected device type. Falls back to [mobile]
  /// when [tablet]/[desktop] aren't given.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Scale a radius value — same basis as [w] (ScreenUtil's `.r` equivalent).
  double r(double value) => w(value);

  /// [BorderRadius.circular] built from a scaled [r] value.
  BorderRadius radius(double value) => BorderRadius.circular(r(value));

  /// [EdgeInsets.all] built from a scaled [w] value.
  EdgeInsets insetsAll(double value) => EdgeInsets.all(w(value));

  /// [EdgeInsets.symmetric] with scaled horizontal ([w]) / vertical ([h]).
  EdgeInsets insetsSymmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: w(horizontal), vertical: h(vertical));

  /// [EdgeInsets.only] with each side scaled via [w] (left/right) / [h]
  /// (top/bottom).
  EdgeInsets insetsOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: w(left),
    top: h(top),
    right: w(right),
    bottom: h(bottom),
  );

  /// Horizontal spacer box, width scaled via [w] (ScreenUtil's `SizedBox(width: x.w)`).
  SizedBox spacerW(double value) => SizedBox(width: w(value));

  /// Vertical spacer box, height scaled via [h] (ScreenUtil's `SizedBox(height: x.h)`).
  SizedBox spacerH(double value) => SizedBox(height: h(value));

  double get screenWidth => _screenSize.width;

  double get screenHeight => _screenSize.height;
}
