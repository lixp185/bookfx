import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'book_controller.dart';

/// 作者： lixp
/// 创建时间： 2022/8/1 16:05
/// 类介绍：模拟书籍翻页效果
class BookFx extends StatefulWidget {
  /// 翻页时长
  final Duration? duration;

  /// 书籍区域
  final Size size;

  /// 一般情况页面布局是固定的 变化的是布局当中的内容
  /// 不过若是页面之间有布局不同时，须同时更新布局
  /// 当前页布局
  /// [index] 当前页码
  final Widget Function(int index) currentPage;

  /// 下一页布局
  /// [index] 下一页页码
  final Widget Function(int index) nextPage;

  /// 背面色值
  final Color? bColor;

  /// 书籍页数
  final int pageCount;

  /// 下一页回调
  final Function(int index)? nextCallBack;

  /// 上一页回调
  final Function(int index)? lastCallBack;

  final BookController? controller;

  const BookFx({
    Key? key,
    this.duration,
    required this.size,
    required this.currentPage,
    required this.nextPage,
    this.bColor,
    this.pageCount = 10000,
    this.nextCallBack,
    this.lastCallBack,
    required this.controller,
  }) : super(key: key);

  @override
  _BookFxState createState() => _BookFxState();
}

class _BookFxState extends State<BookFx> with SingleTickerProviderStateMixin {
  late Size size = widget.size;
  late Offset downPos;
  Point<double> currentA = const Point(0, 0);
  late final AnimationController _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 800))
    ..addListener(() {
      if (isNext) {
        /// 翻页
        _p.value = PaperPoint(
            Point(currentA.x - (currentA.x + size.width) * _controller.value,
                currentA.y + (size.height - currentA.y) * _controller.value),
            size);
      } else {
        /// 不翻页 回到原始位置
        _p.value = PaperPoint(
            Point(
              currentA.x + (size.width - currentA.x) * _controller.value,
              currentA.y + (size.height - currentA.y) * _controller.value,
            ),
            size);
      }
    })
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isNext) {
          setState(() {
            currentIndex++;
            widget.nextCallBack?.call(currentIndex);
          });
        }
        isAnimation = false;
      }
      if (status == AnimationStatus.dismissed) {
        //起点停止
        // print("起点停止");
      }
    });

  @override
  void initState() {
    super.initState();
    // build完毕初始化首页
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _p.value = PaperPoint(Point(size.width, size.height), size);
    });
    widget.controller?.addListener(() {
      if (widget.controller?.isNext == true) {
        /// 下一页
      } else {
        /// 上一页
        if (currentIndex == 0) {
          return;
        }
        isAnimation = true;
        currentA = Point(-200, size.height - 100);
        currentIndex--;
        isNext = false;
        _controller.forward(
          from: 0,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isNext = true; // 是否翻页到下一页
  bool isAnimation = false; // 是否正在执行翻页
  // 控制点类
  final ValueNotifier<PaperPoint> _p =
      ValueNotifier(PaperPoint(const Point(0, 0), const Size(0, 0)));

  // 当前页码
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: GestureDetector(
        child: Stack(
          children: [
            currentIndex == widget.pageCount - 1
                ? const SizedBox()
                // 下一页
                : widget.nextPage(currentIndex + 1),
            // // 当前页
            ClipPath(
              child: widget.currentPage(currentIndex),
              clipper: CurrentPaperClipPath(_p),
            ),
            CustomPaint(
              size: size,
              painter: _BookPainter(
                _p,
                widget.bColor,
              ),
            ),

            // Positioned(
            //     bottom: 0,
            //     child: ElevatedButton(onPressed: () {}, child: Text("上一页")))
          ],
        ),
        onPanDown: (d) {
          // if (isAnimation) {
          //   return;
          // }
          // if (currentIndex == widget.pageCount - 1) {
          //   // ToastUtil.show("最后一页了");
          //   return;
          // }
          // isNext = false;
          downPos = d.localPosition;
          // _p.value = PaperPoint(Point(down.dx, down.dy), size);
        },
        onPanUpdate: currentIndex == widget.pageCount - 1
            ? null
            : (d) {
                if (isAnimation) {
                  return;
                }
                var move = d.localPosition;

                // 临界值取消更新
                if (move.dx >= size.width ||
                    move.dx < 0 ||
                    move.dy >= size.height ||
                    move.dy < 0) {
                  return;
                }
                if (downPos.dx < size.width / 2) {
                  return;
                }
                if (downPos.dy > size.height / 3 &&
                    downPos.dy < size.height * 2 / 3) {
                  // 横向翻页
                  currentA = Point(move.dx, size.height - 1);
                  _p.value = PaperPoint(Point(move.dx, size.height - 1), size);
                } else {
                  // 右下角翻页
                  currentA = Point(move.dx, move.dy);
                  _p.value = PaperPoint(Point(move.dx, move.dy), size);
                }
                // currentA = Point(move.dx, size.height - 1);
                // _p.value = PaperPoint(Point(move.dx, size.height - 1), size);

                if ((size.width - move.dx) / size.width > 1 / 3) {
                  isNext = true;
                } else {
                  isNext = false;
                }
              },
        onPanEnd: currentIndex == widget.pageCount - 1
            ? null
            : (d) {
                if (isAnimation) {
                  return;
                }
                if (downPos.dx < size.width / 2) {
                  if (currentIndex == 0) {
                    widget.lastCallBack?.call(currentIndex);
                    return;
                  }
                  widget.lastCallBack?.call(currentIndex);
                  isAnimation = true;
                  currentA = Point(-200, size.height - 100);
                  currentIndex--;
                  isNext = false;
                  _controller.forward(
                    from: 0,
                  );
                  return;
                }
                isAnimation = true;
                _controller.forward(
                  from: 0,
                );
              },
      ),
    );
  }
}

/// 当前页区域
class CurrentPaperClipPath extends CustomClipper<Path> {
  ValueNotifier<PaperPoint> p;

  CurrentPaperClipPath(
    this.p,
  ) : super(reclip: p);

  @override
  Path getClip(Size size) {
    ///书籍区域
    Path mPath = Path();
    mPath.addRect(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height));

    Path mPathA = Path();
    if (p.value.a != p.value.f && p.value.a.x > -size.width) {
      debugPrint("当前页 ${p.value.a}  ${p.value.f}");
      mPathA.moveTo(p.value.c.x, p.value.c.y);
      mPathA.quadraticBezierTo(
          p.value.e.x, p.value.e.y, p.value.b.x, p.value.b.y);
      mPathA.lineTo(p.value.a.x, p.value.a.y);
      mPathA.lineTo(p.value.k.x, p.value.k.y);
      mPathA.quadraticBezierTo(
          p.value.h.x, p.value.h.y, p.value.j.x, p.value.j.y);
      mPathA.lineTo(p.value.f.x, p.value.f.y);
      mPathA.close();
      Path mPathC =
          Path.combine(PathOperation.reverseDifference, mPathA, mPath);
      return mPathC;
    }

    return mPath;
  }

  @override
  bool shouldReclip(covariant CurrentPaperClipPath oldClipper) {
    return p != oldClipper.p;
  }
}

class _BookPainter extends CustomPainter {
  ValueNotifier<PaperPoint> p;
  final Color? bColor;

  _BookPainter(this.p, this.bColor) : super(repaint: p);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    canvas.restore();

    Path mPathAB = Path();

    ///书籍区域
    Path mPath = Path();
    mPath.addRect(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height));

    /// A区域 下一页可见区域+当前页不可见区域  af重合 不需要绘制A区域
    if (p.value.a != p.value.f) {
      if (p.value.a.y == p.value.f.y) {
        // canvas.drawPath(mPath, paint..color = Colors.yellow);
        /// 翻页完毕
      } else {
        mPathAB.moveTo(p.value.c.x, p.value.c.y);
        mPathAB.quadraticBezierTo(
            p.value.e.x, p.value.e.y, p.value.b.x, p.value.b.y);
        mPathAB.lineTo(p.value.a.x, p.value.a.y);
        mPathAB.lineTo(p.value.k.x, p.value.k.y);
        mPathAB.quadraticBezierTo(
            p.value.h.x, p.value.h.y, p.value.j.x, p.value.j.y);
        mPathAB.lineTo(p.value.f.x, p.value.f.y);

        mPathAB.close();
        Path mPath1 = Path();
        mPath1.moveTo(p.value.d.x, p.value.d.y);
        mPath1.lineTo(p.value.a.x, p.value.a.y);
        mPath1.lineTo(p.value.i.x, p.value.i.y);
        mPath1.close();

        /// C区域 当前页可见区域 与A区域重新生成新路径
        // Path mPathC =
        //     Path.combine(PathOperation.reverseDifference, mPathAB, mPath);

        // canvas.drawPath(mPathC, paint..color = Colors.red);
        // canvas.drawPath(mPathAB, paint..color = Colors.yellow);

        /// B区域 当前页不可见区域
        if (!p.value.b.x.isNaN) {
          Path pyy1 = Path();
          Path pyy2 = Path();
          Path mPathB = Path.combine(PathOperation.intersect, mPathAB, mPath1);
          // 已知a坐标点在一条直线上，求距离该坐标点为10并和该直线相交的的坐标点。
          double m1 = (p.value.a.x - p.value.p.x);
          double n1 = (p.value.a.y - p.value.p.y);

          pyy1.moveTo(p.value.c.x - m1, p.value.c.y);
          pyy1.quadraticBezierTo(p.value.e.x - m1, p.value.e.y - n1,
              p.value.b.x - m1, p.value.b.y - n1);

          // pyy1.lineTo(twoPoint.x, twoPoint.y);

          pyy1.lineTo(p.value.p.x, p.value.p.y);
          pyy1.lineTo(p.value.k.x, p.value.k.y);
          pyy1.lineTo(p.value.f.x, p.value.f.y);
          pyy1.close();

          double mE1 = (p.value.a.x - p.value.p2.x);
          double nE1 = (p.value.a.y - p.value.p2.y); // 负数
          debugPrint("p1x = $m1");
          debugPrint("p1y = $n1");
          debugPrint("p2x = $mE1");
          debugPrint("p2y = $nE1");

          var twoPoint = PaperPoint.toTwoPoint(
              Point(p.value.b.x - m1, p.value.b.y - n1),
              p.value.p,
              p.value.p2,
              Point(p.value.k.x - mE1, p.value.k.y - nE1));
          pyy2.moveTo(p.value.j.x, (p.value.j.y - nE1));
          pyy2.quadraticBezierTo(p.value.i.x - mE1, p.value.i.y - nE1,
              p.value.k.x - mE1, p.value.k.y - nE1);
          // pyy2.lineTo(twoPoint.x, twoPoint.y);
          // pyy2.lineTo(p.value.a.x, p.value.a.y);
          pyy2.lineTo(p.value.p2.x, p.value.p2.y);
          pyy2.lineTo(p.value.b.x, p.value.b.y);
          pyy2.lineTo(p.value.f.x, p.value.f.y);

          pyy2.close();

          Path pd = Path();
          pd.moveTo(p.value.a.x, p.value.a.y);
          pd.lineTo(twoPoint.x, twoPoint.y);
          pd.lineTo(p.value.p2.x, p.value.p2.y);
          pd.close();
          Paint pdPaint = Paint();
          canvas.drawPath(
              pd,
              pdPaint
                ..shader = ui.Gradient.linear(
                  Offset(p.value.a.x, p.value.a.y),
                  Offset(p.value.p2.x, p.value.p2.y),
                  [Colors.black12, Colors.transparent],
                )
                ..style = PaintingStyle.fill);
          Paint psPaint = Paint();
          Path ps = Path();
          ps.moveTo(p.value.a.x, p.value.a.y);
          ps.lineTo(twoPoint.x, twoPoint.y);
          ps.lineTo(p.value.p.x, p.value.p.y);
          ps.close();

          canvas.drawPath(
              ps,
              psPaint
                ..shader = ui.Gradient.linear(
                    Offset(p.value.a.x, p.value.a.y),
                    Offset(p.value.p.x, p.value.p.y),
                    [Colors.black12, Colors.transparent])
                ..style = PaintingStyle.fill);
          // canvas.drawPath(
          //     Path.combine(PathOperation.reverseDifference, mPathAB, pyy2),
          //     paint
          //       ..color = Colors.green
          //       ..style = PaintingStyle.stroke);
          // //
          // canvas.drawPath(
          //     Path.combine(PathOperation.reverseDifference, mPathAB, pyy1),
          //     paint
          //       ..color = Colors.red
          //       ..style = PaintingStyle.stroke);

          // canvas.drawPath(
          //     pyy2,
          //     paint
          //       ..color = Colors.red
          //       ..style = PaintingStyle.fill);
          // canvas.drawPath(
          //     mPathAB,
          //     paint
          //       ..color = Colors.black
          //       ..style = PaintingStyle.stroke);

          Path startYY =
              Path.combine(PathOperation.reverseDifference, mPathAB, pyy1);
          Path endYY =
              Path.combine(PathOperation.reverseDifference, mPathAB, pyy2);

          canvas.drawPath(
              mPathB, paint..color = bColor ?? Colors.grey.shade400);

          Paint paint2 = Paint();
          // 上左

          canvas.drawPath(
              startYY,
              paint2
                ..style = PaintingStyle.fill
                ..shader = ui.Gradient.linear(
                    Offset(p.value.a.x, p.value.a.y),
                    Offset(p.value.p.x, p.value.p.y),
                    [Colors.black12, Colors.transparent]));

          //上右
          canvas.drawPath(
              endYY,
              paint2
                ..style = PaintingStyle.fill
                ..shader = ui.Gradient.linear(
                    Offset(p.value.a.x, p.value.a.y),
                    Offset(p.value.p2.x, p.value.p2.y),
                    [Colors.black12, Colors.transparent]));

          // 右下
          Path pr = Path();
          pr.moveTo(p.value.c.x, p.value.c.y);
          pr.lineTo(p.value.j.x, p.value.j.y);
          pr.lineTo(p.value.h.x, p.value.h.y);
          pr.lineTo(p.value.e.x, p.value.e.y);
          pr.close();

          Path p1 = Path.combine(PathOperation.intersect, pr, mPathAB);
          Path p2 = Path.combine(PathOperation.difference, p1, mPathB);

          Offset u = Offset(
              PaperPoint.toTwoPoint(p.value.a, p.value.f, p.value.d, p.value.i)
                  .x,
              PaperPoint.toTwoPoint(p.value.a, p.value.f, p.value.d, p.value.i)
                  .y);
          canvas.drawPath(
              p2,
              paint
                ..style = PaintingStyle.fill
                ..shader = ui.Gradient.linear(
                    u,
                    Offset(p.value.g.x, p.value.g.y),
                    [Colors.black26, Colors.transparent]));

          // canvas.drawLine(o1, o2, paint);

        }
      }
    } else {
      // canvas.drawPath(mPath, paint..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant _BookPainter oldDelegate) {
    return oldDelegate.p != p;
  }

  Path drawText(String s, Canvas canvas, Size size) {
    var textPainter = TextPainter(
        text: TextSpan(
            text: s,
            style: TextStyle(
              fontSize: 20,
              foreground: Paint()
                ..style = PaintingStyle.fill
                ..strokeWidth = 1,
            )),
        textAlign: TextAlign.left,
        maxLines: 100,
        ellipsis: "...",
        textDirection: TextDirection.ltr);
    textPainter.layout();
    var size2 = textPainter.size;
    textPainter.paint(
      canvas,
      Offset(-size2.width / 2, -size2.height / 2),
    );

    Path path = Path();
    path.addRect(Rect.fromCenter(
        center: Offset.zero, width: size2.width, height: size2.height));
    return path;
  }
}

class PaperPoint {
  //手指拉拽点 已知
  Point<double> a;

  // c区域影深
  final double elevationC;

  //右下角的点 已知
  late Point<double> f;

  late Point<double> p;
  late Point<double> p2;

  //
  // //贝塞尔点(e为控制点)
  late Point<double> b, c, d, e;

  // //贝塞尔点(h为控制点)
  late Point<double> h, i, j, k;

  //eh实际为af中垂线，g为ah和af的交点
  late Point<double> g;

  late Size size;

  late double ahK;
  late double ahB;

  PaperPoint(
    this.a,
    this.size, {
    this.elevationC = 10,
  }) {
    //每个点的计算公式
    // f = Point(size.width / 2, size.height / 2);
    f = Point(size.width, size.height);
    debugPrint("af  ${a.y}  ${f.y}");
    // if (a.y == f.y) {
    //   print("xiangdeng l");
    //   return;
    // }
    g = Point((a.x + f.x) / 2, (a.y + f.y) / 2);
    e = Point(g.x - (pow(f.y - g.y, 2) / (f.x - g.x)), f.y);
    double cx = e.x - (f.x - e.x) / 2;
    debugPrint("g  $g e $e");
    if (a.x > 0) {
      if (cx <= 0) {
        //   // 临界点
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
    }

    c = Point(cx, f.y);
    debugPrint("cccccc$c");
    h = Point(f.x, g.y - (pow((f - g).x, 2) / (f.y - g.y)));

    j = Point(f.x, h.y - (f.y - h.y) / 2);

    double k1 = towPointKb(c, j);
    double b1 = towPointKb(c, j, isK: false);

    double k2 = towPointKb(a, e);
    double b2 = towPointKb(a, e, isK: false);

    double k3 = towPointKb(a, h);

    double b3 = towPointKb(a, h, isK: false);

    ahK = towPointKb(a, h);
    ahB = towPointKb(a, h, isK: false);
    b = Point((b2 - b1) / (k1 - k2), (b2 - b1) / (k1 - k2) * k1 + b1);
    k = Point((b3 - b1) / (k1 - k3), (b3 - b1) / (k1 - k3) * k1 + b1);
    d = Point(((c.x + b.x) / 2 + e.x) / 2, ((c.y + b.y) / 2 + e.y) / 2);

    i = Point(((j.x + k.x) / 2 + h.x) / 2, ((j.y + k.y) / 2 + h.y) / 2);

    p = toP(a, ahK, ahB, elevationC);
    p2 = toP(a, towPointKb(a, e), towPointKb(a, e, isK: false), elevationC);
  }

  Point<double> toP(Point<double> p, double k, double b, double jl) {
    double x = 0.0;
    double y = 0.0;

    if (k > 0 || a.y >= h.y) {
      x = a.x - sqrt(jl * jl / (1 + (k * k)));
      y = a.y - sqrt(jl * jl / (1 + (k * k))) * k;
    } else {
      x = a.x + sqrt(jl * jl / (1 + (k * k)));
      y = a.y + sqrt(jl * jl / (1 + (k * k))) * k;
    }

    return Point<double>(x, y);
  }

  /// 两点求直线方程
  static double towPointKb(Point<double> p1, Point<double> p2,
      {bool isK = true}) {
    /// 求得两点斜率
    double k = 0;
    double b = 0;
    // 防止除数 = 0 出现的计算错误 a e x轴重合
    if (p1.x == p2.x) {
      k = (p1.y - p2.y) / (p1.x - p2.x - 1);
    } else {
      k = (p1.y - p2.y) / (p1.x - p2.x);
    }
    b = p1.y - k * p1.x;
    if (isK) {
      return k;
    } else {
      return b;
    }
  }

  static Point<double> toTwoPoint(
      Point<double> a, Point<double> b, Point<double> m, Point<double> n) {
    double k1 = towPointKb(a, b);
    double b1 = towPointKb(a, b, isK: false);

    double k2 = towPointKb(m, n);
    double b2 = towPointKb(m, n, isK: false);

    return Point((b2 - b1) / (k1 - k2), (b2 - b1) / (k1 - k2) * k1 + b1);
  }
}
