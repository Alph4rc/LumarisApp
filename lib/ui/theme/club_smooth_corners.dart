import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

const double clubCornerSmoothness = 0.6;

class ClubSmoothCorners {
  const ClubSmoothCorners._();

  static SmoothRectangleBorder shape(
    BorderRadiusGeometry borderRadius, {
    BorderSide side = BorderSide.none,
    double smoothness = clubCornerSmoothness,
  }) {
    return SmoothRectangleBorder(
      borderRadius: borderRadius,
      side: side,
      smoothness: smoothness,
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
    double smoothness = clubCornerSmoothness,
    required Widget child,
  }) {
    return SmoothClipRRect(
      key: key,
      borderRadius: borderRadius,
      side: side,
      smoothness: smoothness,
      child: child,
    );
  }
}
