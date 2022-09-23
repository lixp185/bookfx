import 'package:flutter/material.dart';

class TextUtil {
  /// 获取文字高度
  static double calculateTextHeight({
    double maxWidth = double.infinity,
    double minWidth = 0,
    String value = "",
    double fontSize = 16,
  }) {
    TextPainter painter = TextPainter(
        locale: WidgetsBinding.instance.window.locale,
        textDirection: TextDirection.ltr,
        maxLines: 100,
        text: TextSpan(
            text: value,
            style: TextStyle(
              // fontWeight: fontWeight,
              fontSize: fontSize,
            )));
    painter.layout(maxWidth: maxWidth, minWidth: minWidth);
    return painter.height;
  }
}
