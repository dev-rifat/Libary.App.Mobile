/// Centered splash-screen logo/asset, rendered from an SVG asset path.
///
/// Work procedure:
/// 1. Pass the SVG asset path as [imgUrl] (declared in your app's
///    pubspec.yaml assets, not this library's).
/// 2. Leave [width]/[height] null for the 150x150 default; override for a
///    different logo size.
/// 3. Place it as a [Scaffold.body] (or inside one) — it centers itself.
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: RHCustomSplash(imgUrl: 'assets/logo.svg'),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RHCustomSplash extends StatelessWidget {
  /// SVG asset path to render.
  final String imgUrl;

  /// Render height. Defaults to 150.
  final double? height;

  /// Render width. Defaults to 150.
  final double? width;

  const RHCustomSplash(
      {super.key, required this.imgUrl, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            height: height ?? 150,
            width: width ?? 150,
            child: SvgPicture.asset(imgUrl)));
  }
}