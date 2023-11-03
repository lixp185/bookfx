import 'dart:math';

class Line {
  final Point<double> a;
  final Point<double> b;
  final double slope;
  final double intercept;

  const Line(this.a, this.b, this.slope, this.intercept);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line &&
          runtimeType == other.runtimeType &&
          a == other.a &&
          b == other.b &&
          slope == other.slope &&
          intercept == other.intercept;

  @override
  int get hashCode =>
      a.hashCode ^ b.hashCode ^ slope.hashCode ^ intercept.hashCode;

  @override
  String toString() {
    return 'Line{a: $a, b: $b, slope: $slope, intercept: $intercept}';
  }
}
