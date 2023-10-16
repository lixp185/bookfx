import 'dart:math';
import 'dart:ui' as ui;

import 'package:bookfx/src/model/paper_point.dart';
import 'package:bookfx/src/utils/page_math.dart';
import 'package:flutter/material.dart';

class BookPainter extends CustomPainter {
  ValueNotifier<PaperPoint> p;
  final Color? bColor;

  BookPainter(this.p, this.bColor) : super(repaint: p);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.restore();

    Path mPath = Path();
    mPath.addRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
    );

    /// af重合时不需要绘制
    if (p.value.a == p.value.f || p.value.a.y == p.value.f.y) return;

    /// AB合并的区域
    Path mPathAB = Path();
    mPathAB.moveTo(p.value.c.x, p.value.c.y);
    mPathAB.quadraticBezierTo(
      p.value.e.x,
      p.value.e.y,
      p.value.b.x,
      p.value.b.y,
    );
    mPathAB.lineTo(p.value.a.x, p.value.a.y);
    mPathAB.lineTo(p.value.k.x, p.value.k.y);
    mPathAB.quadraticBezierTo(
      p.value.h.x,
      p.value.h.y,
      p.value.j.x,
      p.value.j.y,
    );
    mPathAB.lineTo(p.value.f.x, p.value.f.y);
    mPathAB.close();

    /// B区域 当前页不可见区域
    /// B区域的三角形，用于分离AB区域
    Path triangleB = Path();
    triangleB.moveTo(p.value.d.x, p.value.d.y);
    triangleB.lineTo(p.value.a.x, p.value.a.y);
    triangleB.lineTo(p.value.i.x, p.value.i.y);
    triangleB.close();

    // A区域左侧阴影
    Path aShadowLeft = Path();
    double xP1Delta = p.value.a.x - p.value.p1.x;
    double yP1Delta = p.value.a.y - p.value.p1.y;

    aShadowLeft.moveTo(p.value.c.x - xP1Delta, p.value.c.y);
    aShadowLeft.quadraticBezierTo(
      p.value.e.x - xP1Delta,
      p.value.e.y - yP1Delta,
      p.value.b.x - xP1Delta,
      p.value.b.y - yP1Delta,
    );
    aShadowLeft.lineTo(p.value.p1.x, p.value.p1.y);
    aShadowLeft.lineTo(p.value.k.x, p.value.k.y);
    aShadowLeft.lineTo(p.value.f.x, p.value.f.y);
    aShadowLeft.close();

    // A区域右侧阴影
    Path aShadowRight = Path();
    double xP2Delta = (p.value.a.x - p.value.p2.x);
    double yP2Delta = (p.value.a.y - p.value.p2.y);
    aShadowRight.moveTo(p.value.j.x, p.value.j.y - yP2Delta);
    aShadowRight.quadraticBezierTo(
      p.value.i.x - xP2Delta,
      p.value.i.y - yP2Delta,
      p.value.k.x - xP2Delta,
      p.value.k.y - yP2Delta,
    );
    aShadowRight.lineTo(p.value.p2.x, p.value.p2.y);
    aShadowRight.lineTo(p.value.b.x, p.value.b.y);
    aShadowRight.lineTo(p.value.f.x, p.value.f.y);
    aShadowRight.close();

    Paint aShadowPaint = Paint();
    Path combineShadowLeft = Path.combine(
      PathOperation.reverseDifference,
      mPathAB,
      aShadowLeft,
    );
    Path combineShadowRight = Path.combine(
      PathOperation.reverseDifference,
      mPathAB,
      aShadowRight,
    );
    canvas.drawPath(
      combineShadowLeft,
      aShadowPaint
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          Offset(p.value.a.x, p.value.a.y),
          Offset(p.value.p1.x, p.value.p1.y),
          [Colors.black12, Colors.transparent],
        ),
    );
    canvas.drawPath(
      combineShadowRight,
      aShadowPaint
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          Offset(p.value.a.x, p.value.a.y),
          Offset(p.value.p2.x, p.value.p2.y),
          [Colors.black12, Colors.transparent],
        ),
    );

    // A区域左右阴影绘制完后，会在a点缺口处形成一个三角形，需要用p1点和p2点的连线来填充
    Point<double> crossPoint = calculateIntersectionOfTwoLines(
      Point(p.value.b.x - xP1Delta, p.value.b.y - yP1Delta),
      p.value.p1,
      p.value.p2,
      Point(p.value.k.x - xP2Delta, p.value.k.y - yP2Delta),
    );

    Path crossShadowLeft = Path();
    crossShadowLeft.moveTo(p.value.a.x, p.value.a.y);
    crossShadowLeft.lineTo(crossPoint.x, crossPoint.y);
    crossShadowLeft.lineTo(p.value.p1.x, p.value.p1.y);
    crossShadowLeft.close();
    canvas.drawPath(
      crossShadowLeft,
      aShadowPaint
        ..shader = ui.Gradient.linear(
          Offset(p.value.a.x, p.value.a.y),
          Offset(p.value.p1.x, p.value.p1.y),
          [Colors.black12, Colors.transparent],
        )
        ..style = PaintingStyle.fill,
    );

    Path crossShadowRight = Path();
    crossShadowRight.moveTo(p.value.a.x, p.value.a.y);
    crossShadowRight.lineTo(crossPoint.x, crossPoint.y);
    crossShadowRight.lineTo(p.value.p2.x, p.value.p2.y);
    crossShadowRight.close();
    canvas.drawPath(
      crossShadowRight,
      aShadowPaint
        ..shader = ui.Gradient.linear(
          Offset(p.value.a.x, p.value.a.y),
          Offset(p.value.p2.x, p.value.p2.y),
          [Colors.black12, Colors.transparent],
        )
        ..style = PaintingStyle.fill,
    );

    Paint cShadowPaint = Paint()..style = PaintingStyle.fill;
    Path mPathB = Path.combine(
      PathOperation.intersect,
      mPathAB,
      triangleB,
    );
    canvas.drawPath(
      mPathB,
      cShadowPaint..color = bColor ?? Colors.grey.shade400,
    );

    Path bShadow = Path();
    bShadow.moveTo(p.value.c.x, p.value.c.y);
    bShadow.lineTo(p.value.j.x, p.value.j.y);
    bShadow.lineTo(p.value.h.x, p.value.h.y);
    bShadow.lineTo(p.value.e.x, p.value.e.y);
    bShadow.close();

    Path combineToBC = Path.combine(
      PathOperation.intersect,
      bShadow,
      mPathAB,
    );
    Path combineToC = Path.combine(
      PathOperation.difference,
      combineToBC,
      mPathB,
    );

    Offset u = Offset(
      calculateIntersectionOfTwoLines(
        p.value.a,
        p.value.f,
        p.value.d,
        p.value.i,
      ).x,
      calculateIntersectionOfTwoLines(
        p.value.a,
        p.value.f,
        p.value.d,
        p.value.i,
      ).y,
    );
    canvas.drawPath(
      combineToC,
      cShadowPaint
        ..shader = ui.Gradient.linear(
          u,
          Offset(p.value.g.x, p.value.g.y),
          [Colors.black26, Colors.transparent],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant BookPainter oldDelegate) => oldDelegate.p != p;
}
