import 'package:bookfx/src/model/paper_point.dart';
import 'package:flutter/widgets.dart';

/// 当前页区域
class CurrentPaperClipPath extends CustomClipper<Path> {
  final ValueNotifier<PaperPoint> p;
  final bool isNext;

  const CurrentPaperClipPath(this.p, this.isNext) : super(reclip: p);

  @override
  Path getClip(Size size) {
    Path mPath = Path();
    mPath.addRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
    );
    Path mPathA = Path();
    // 翻页
    if (p.value.a != p.value.f && p.value.a.x > -size.width) {
      mPathA.moveTo(p.value.c.x, p.value.c.y);
      mPathA.quadraticBezierTo(
        p.value.e.x,
        p.value.e.y,
        p.value.b.x,
        p.value.b.y,
      );
      mPathA.lineTo(p.value.a.x, p.value.a.y);
      mPathA.lineTo(p.value.k.x, p.value.k.y);
      mPathA.quadraticBezierTo(
        p.value.h.x,
        p.value.h.y,
        p.value.j.x,
        p.value.j.y,
      );
      mPathA.lineTo(p.value.f.x, p.value.f.y);
      mPathA.close();
      Path mPathC = Path.combine(
        PathOperation.reverseDifference,
        mPathA,
        mPath,
      );
      return mPathC;
    }
    return isNext ? Path() : mPath;
  }

  @override
  bool shouldReclip(covariant CurrentPaperClipPath oldClipper) =>
      p != oldClipper.p;
}
