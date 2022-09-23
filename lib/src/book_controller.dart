import 'package:flutter/material.dart';

class BookController extends ChangeNotifier {
  bool isNext = true;

  int pageIndex = 0; // 页码
  /// 上一页
  last() {
    isNext = false;
    notifyListeners();
  }

  /// 下一页
  next() {
    isNext = true;
    notifyListeners();
  }

  // 跳页
  goTo(int index) {
    pageIndex = index;
    notifyListeners();
  }
}
