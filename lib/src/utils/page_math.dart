import 'dart:math';

import 'package:bookfx/src/model/line.dart';

// 求直线方程
Line calculateLineEquation(Point<double> p1, Point<double> p2) {
  double slope = 0;
  double intercept = 0;
  if (p1.x == p2.x) {
    if (p1.y == p2.y) {
      // 两点重合, 无法求出直线方程
      slope = double.nan;
    } else {
      // 垂直线, 斜率为正无穷或负无穷
      slope = p1.y > p2.y ? double.infinity : double.negativeInfinity;
    }
  } else {
    slope = (p1.y - p2.y) / (p1.x - p2.x);
  }
  if (slope.isNaN || slope.isInfinite) {
    // 无法求截距
    intercept = double.nan;
  } else {
    intercept = p1.y - slope * p1.x;
  }
  return Line(p1, p2, slope, intercept);
}

Point<double> calculateIntersectionOfTwoLines(
  Point<double> a,
  Point<double> b,
  Point<double> m,
  Point<double> n,
) {
  Line line1 = calculateLineEquation(a, b);
  Line line2 = calculateLineEquation(m, n);

  return Point(
    (line2.intercept - line1.intercept) / (line1.slope - line2.slope),
    (line2.intercept - line1.intercept) /
            (line1.slope - line2.slope) *
            line1.slope +
        line1.intercept,
  );
}

Point<double> projectPointToLine(
  Point<double> p1,
  Point<double> p2,
  double slope,
  double distance,
) {
  double x = 0.0;
  double y = 0.0;

  if (slope > 0 || p1.y >= p2.y) {
    x = p1.x - sqrt(distance * distance / (1 + (slope * slope)));
    y = p1.y - sqrt(distance * distance / (1 + (slope * slope))) * slope;
  } else {
    x = p1.x + sqrt(distance * distance / (1 + (slope * slope)));
    y = p1.y + sqrt(distance * distance / (1 + (slope * slope))) * slope;
  }

  return Point(x, y);
}
