import 'package:flutter/material.dart';

class TextUtil {
  /// 获取文字高度
  static double calculateTextHeight(String value, double fontSize,
      {required double fontHeight, required double maxWidth, required EdgeInsetsGeometry padding}) {
    TextPainter painter = TextPainter(
        locale: WidgetsBinding.instance.window.locale,
        textDirection: TextDirection.ltr,
        maxLines: 1000,
        strutStyle: StrutStyle(forceStrutHeight: true, fontSize: fontSize, height: fontHeight),
        text: TextSpan(
          text: value,
          style: TextStyle(
            height: fontHeight,
            fontSize: fontSize,
          ),
        ),
        textAlign: TextAlign.center);
    painter.layout(maxWidth: maxWidth - padding.horizontal);
    return painter.size.height;
  }

  /// 获取最大行文字字数
  static int calculateTextMaxTextPos(String value, double fontSize,
      {required double fontHeight, required double maxWidth, required EdgeInsetsGeometry padding, int maxLines = 3}) {
    final TextPainter painter = TextPainter(
        locale: WidgetsBinding.instance.window.locale,
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        strutStyle: StrutStyle(forceStrutHeight: true, fontSize: fontSize, height: fontHeight),
        text: TextSpan(
          text: value,
          style: TextStyle(
            height: fontHeight,
            fontSize: fontSize,
          ),
        ),
        textAlign: TextAlign.center);
    painter.layout(maxWidth: maxWidth - padding.horizontal);
    final didExceedMaxLines = painter.didExceedMaxLines;
    // print('是否超出最大行$didExceedMaxLines');
    if (didExceedMaxLines) {
      final position = painter.getPositionForOffset(Offset(
        painter.width,
        painter.height,
      ));
      /// 如果下一页开始处于段落开始，+2避免首行换行空行展示
      if (value.substring(position.offset).startsWith('\n')) {
        return position.offset + 2;
      }
      return position.offset;
    }
    return 0;
  }
}
