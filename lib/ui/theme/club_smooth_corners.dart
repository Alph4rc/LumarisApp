import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

const double clubCornerSmoothness = 0.8;
const double clubCompactCornerSmoothness = 0.6;
const double clubSmallCornerThreshold = 12;

class ClubSmoothCorners {
  const ClubSmoothCorners._();

  static SmoothRectangleBorder shape(
    BorderRadiusGeometry borderRadius, {
    BorderSide side = BorderSide.none,
    double? smoothness,
  }) {
    return SmoothRectangleBorder(
      borderRadius: borderRadius,
      side: side,
      smoothness: smoothness ?? effectiveSmoothness(borderRadius, side: side),
    );
  }

  static BorderRadius resolve(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  ) {
    return borderRadius.resolve(Directionality.of(context));
  }

  static SmoothClipRRect clip({
    Key? key,
    required BorderRadius borderRadius,
    BorderSide side = BorderSide.none,
    double? smoothness,
    required Widget child,
  }) {
    return SmoothClipRRect(
      key: key,
      borderRadius: borderRadius,
      side: side,
      smoothness: smoothness ?? effectiveSmoothness(borderRadius, side: side),
      child: child,
    );
  }

  static double effectiveSmoothness(
    BorderRadiusGeometry borderRadius, {
    BorderSide side = BorderSide.none,
  }) {
    if (_hasVisibleBorder(side) || _isCompactRadius(borderRadius)) {
      return clubCompactCornerSmoothness;
    }

    return clubCornerSmoothness;
  }

  static bool _hasVisibleBorder(BorderSide side) {
    return side.style != BorderStyle.none && side.width > 0;
  }

  static bool _isCompactRadius(BorderRadiusGeometry borderRadius) {
    final BorderRadius resolved = borderRadius.resolve(TextDirection.ltr);
    final List<Radius> radii = <Radius>[
      resolved.topLeft,
      resolved.topRight,
      resolved.bottomLeft,
      resolved.bottomRight,
    ];

    return radii.any((Radius radius) {
      final double shortestAxis = radius.x < radius.y ? radius.x : radius.y;
      return shortestAxis > 0 && shortestAxis <= clubSmallCornerThreshold;
    });
  }
}
