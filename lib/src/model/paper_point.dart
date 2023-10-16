import 'dart:math';
import 'dart:ui';

import 'package:bookfx/src/model/line.dart';
import 'package:bookfx/src/utils/paper_math.dart';

class PaperPoint {
  // 手指拉拽点
  Point<double> a;

  // c区域影深
  final double elevationC;

  // 右下角的点
  late Point<double> f;

  late Point<double> p1;
  late Point<double> p2;

  // 贝塞尔点(e为控制点)
  late Point<double> b, c, d, e;

  // 贝塞尔点(h为控制点)
  late Point<double> h, i, j, k;

  // eh实际为af中垂线
  // g为ah和af的交点
  late Point<double> g;

  late Size size;

  late double ahSlope;
  late double ahIntercept;

  PaperPoint(
    this.a,
    this.size, {
    this.elevationC = 10,
  }) {
    f = Point(size.width, size.height);
    g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
    e = Point(g.x - (pow(f.y - g.y, 2) / (f.x - g.x)), f.y);
    var cx = e.x - (f.x - e.x) / 2;
    // 模拟页面左侧存在书封
    if (a.x > 0 && cx <= 0) {
      double fc = f.x - cx;
      double fa = f.x - a.x;
      double bb1 = size.width * fa / fc;
      double fd1 = f.y - a.y;
      double fd = bb1 * fd1 / fa;
      a = Point(f.x - bb1, f.y - fd);
      g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
      e = Point(g.x - (pow((f - g).y, 2) / (f - g).x), f.y);

      cx = 0;
    }

    c = Point(cx, f.y);
    h = Point(f.x, g.y - (pow((f - g).x, 2) / (f.y - g.y)));
    j = Point(f.x, h.y - (f.y - h.y) / 2);

    Line ah = calculateLineEquation(a, h);
    ahSlope = ah.slope;
    ahIntercept = ah.intercept;

    b = calculateIntersectionOfTwoLines(c, j, a, e);
    k = calculateIntersectionOfTwoLines(c, j, a, h);

    final tp = Point((c.x + b.x) / 2, (c.y + b.y) / 2);
    final to = Point((j.x + k.x) / 2, (j.y + k.y) / 2);
    d = Point((tp.x + e.x) / 2, (tp.y + e.y) / 2);
    i = Point((to.x + h.x) / 2, (to.y + h.y) / 2);

    Line ae = calculateLineEquation(a, e);
    p1 = projectPointToLine(ah, elevationC);
    p2 = projectPointToLine(ae, elevationC);
  }
}
