import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;

  static const EdgeInsets screen = EdgeInsets.all(x4);
  static const EdgeInsets card = EdgeInsets.all(x4);
}

abstract final class AppRadius {
  static const double card = 16;
  static const double search = 15;
  static const double field = 13;
  static const double button = 13;
  static const double sheet = 24;
}
