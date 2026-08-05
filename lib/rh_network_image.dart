/// Single cached-network-image widget covering any shape — circle, square,
/// rounded rectangle, plain rectangle — via one [shape] switch, with every
/// visual knob (size, border, fit, radius, loading/error content) nullable
/// and overridable per instance. No app-specific color/string/CDN dependency:
/// callers pass a ready-to-load [imageUrl]; unset knobs fall back to
/// [Theme]-derived defaults.
///
/// Work procedure:
/// 1. Resolve the final image URL yourself (signing, CDN domain, etc. is
///    app-specific and out of scope here) and pass it as [imageUrl].
/// 2. Pick [shape]: [RHImageShape.circle] for avatars (sized by [radius]),
///    or [RHImageShape.rectangle] for everything else (sized by
///    [width]/[height] or [aspectRatio], rounded via [borderRadius]).
/// 3. Leave [borderColor]/[borderWidth] null for no ring/outline; set both
///    for an avatar ring or an outlined thumbnail.
/// 4. Leave [placeholder]/[errorWidget] null for sane defaults (a spinner,
///    and an icon + [errorText] on failure); override either independently.
///
/// Usage — circular avatar:
/// ```dart
/// RHNetworkImage(
///   imageUrl: user.avatarUrl,
///   shape: RHImageShape.circle,
///   radius: 24,
///   borderColor: Colors.white,
///   borderWidth: 2,
/// );
/// ```
///
/// Usage — rounded-rectangle thumbnail:
/// ```dart
/// RHNetworkImage(
///   imageUrl: book.coverUrl,
///   height: 160,
///   borderRadius: BorderRadius.circular(12),
/// );
/// ```
///
/// Usage — square thumbnail, custom error state:
/// ```dart
/// RHNetworkImage(
///   imageUrl: product.imageUrl,
///   width: 100,
///   height: 100,
///   errorWidget: const Icon(Icons.broken_image),
/// );
/// ```
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shape [RHNetworkImage] renders as.
enum RHImageShape {
  /// Rectangle — square, rounded-rectangle, or plain, depending on
  /// [RHNetworkImage.width]/[RHNetworkImage.height]/[RHNetworkImage.borderRadius].
  rectangle,

  /// Circle, sized by [RHNetworkImage.radius].
  circle,
}

/// Cached network image supporting any shape/size/border via nullable,
/// per-instance overrides. See library doc above for usage.
class RHNetworkImage extends StatelessWidget {
  const RHNetworkImage({
    super.key,
    required this.imageUrl,
    this.shape = RHImageShape.circle,
    this.width,
    this.height,
    this.aspectRatio,
    this.radius,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.padding,
    this.placeholder,
    this.errorWidget,
    this.errorText,
    this.errorTextStyle,
    this.errorTextColor,
    this.errorBgColor,
  });

  /// Image URL to load.
  final String imageUrl;

  /// [RHImageShape.rectangle] (default) or [RHImageShape.circle].
  final RHImageShape shape;

  /// Rectangle width. Ignored for [RHImageShape.circle]. Null + no
  /// [aspectRatio] lets the parent constrain it.
  final double? width;

  /// Rectangle height. Ignored for [RHImageShape.circle]. Defaults to 200
  /// when neither [aspectRatio] nor an explicit [height] is given.
  final double? height;

  /// Wraps the rectangle in an [AspectRatio] when set (e.g. `16 / 9`).
  /// Ignored for [RHImageShape.circle].
  final double? aspectRatio;

  /// Circle radius (image only, excluding any ring border). Ignored for
  /// [RHImageShape.rectangle]. Defaults to 40.
  final double? radius;

  /// Corner rounding for [RHImageShape.rectangle]. Defaults to a 4dp
  /// radius. Ignored for [RHImageShape.circle] (always fully round).
  final BorderRadius? borderRadius;

  /// How the image fills its bounds. Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Ring (circle) or outline (rectangle) color. Null renders no
  /// border/ring.
  final Color? borderColor;

  /// Ring/outline stroke width. Ignored if [borderColor] is null. Defaults
  /// to 2 for circle, 1 for rectangle.
  final double? borderWidth;

  /// Fill color behind the image while loading (rectangle only). Defaults
  /// to [ColorScheme.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Inner padding (rectangle only).
  final EdgeInsetsGeometry? padding;

  /// Widget shown while loading. Defaults to a centered spinner.
  final Widget? placeholder;

  /// Widget shown on load failure. Takes precedence over [errorText].
  final Widget? errorWidget;

  /// Text shown in the default error state, ignored when [errorWidget] is set.
  final String? errorText;

  /// Style for [errorText].
  final TextStyle? errorTextStyle;

  /// Color of [errorText] and the default error icon. Ignored when
  /// [errorTextStyle] sets its own color. Defaults to [ColorScheme.error].
  final Color? errorTextColor;

  /// Background color behind the default error state.
  final Color? errorBgColor;

  @override
  Widget build(BuildContext context) {
    return shape == RHImageShape.circle
        ? _buildCircle(context)
        : _buildRectangle(context);
  }

  Widget _buildCircle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedRadius = radius ?? 40.0;
    final resolvedBorderWidth = borderWidth ?? 2.0;

    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? const CupertinoActivityIndicator(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorContent(context, resolvedRadius * 2),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
    );

    if (borderColor == null) {
      return CircleAvatar(
        radius: resolvedRadius,
        backgroundColor: colors.surface,
        child: ClipOval(child: image),
      );
    }

    return CircleAvatar(
      radius: resolvedRadius + resolvedBorderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: resolvedRadius,
        backgroundColor: colors.surface,
        child: ClipOval(child: image),
      ),
    );
  }

  Widget _buildRectangle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedHeight = height ?? (aspectRatio == null ? 200.0 : null);
    final resolvedRadius = borderRadius ?? BorderRadius.circular(4);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: resolvedHeight,
      fit: fit,
      placeholder: (context, url) => Container(
        color: backgroundColor ?? colors.surfaceContainerHighest,
        child: Center(child: placeholder ?? const CupertinoActivityIndicator()),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorContent(context, null),
      imageBuilder: (context, imageProvider) => Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: resolvedRadius,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth ?? 1.0)
              : null,
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
    );

    image = ClipRRect(borderRadius: resolvedRadius, child: image);

    return aspectRatio != null
        ? AspectRatio(aspectRatio: aspectRatio!, child: image)
        : image;
  }

  Widget _buildErrorContent(BuildContext context, double? size) {
    final colors = Theme.of(context).colorScheme;
    final resolvedColor = errorTextColor ?? colors.error;

    return Container(
      width: size,
      height: size,
      color: errorBgColor ?? colors.errorContainer,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            errorText ?? 'Image not available',
            style:
                errorTextStyle ?? TextStyle(color: resolvedColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
