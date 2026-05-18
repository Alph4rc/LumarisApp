import 'package:flutter/material.dart';

class ClubRadii {
  const ClubRadii._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double indicator = 2;
  static const double handle = 2.5;

  static const Radius xsRadius = Radius.circular(xs);
  static const Radius smRadius = Radius.circular(sm);
  static const Radius mdRadius = Radius.circular(md);
  static const Radius lgRadius = Radius.circular(lg);
  static const Radius xlRadius = Radius.circular(xl);
  static const Radius xxlRadius = Radius.circular(xxl);
  static const Radius indicatorRadius = Radius.circular(indicator);
  static const Radius handleRadius = Radius.circular(handle);

  static const Radius controlRadius = smRadius;
  static const Radius navigationRadius = mdRadius;
  static const Radius panelRadius = lgRadius;
  static const Radius cardRadius =
      Radius.circular(18); // Increased from 20 (xl) to be more specific
  static const Radius tileRadius =
      Radius.circular(22); // Increased from 24 (xxl) to be more specific

  static const BorderRadius xsBorder = BorderRadius.all(xsRadius);
  static const BorderRadius control = BorderRadius.all(controlRadius);
  static const BorderRadius navigation = BorderRadius.all(navigationRadius);
  static const BorderRadius panel = BorderRadius.all(panelRadius);
  static const BorderRadius card = BorderRadius.all(cardRadius);
  static const BorderRadius tile = BorderRadius.all(tileRadius);
  static const BorderRadius indicatorBorder = BorderRadius.all(indicatorRadius);
  static const BorderRadius pill = BorderRadius.all(handleRadius);
  static const BorderRadius sheetTop = BorderRadius.vertical(top: cardRadius);
}
