import 'package:flutter/material.dart';

class BookController extends ChangeNotifier {
  int nextType = 0;
  int currentIndex = 0; // 当前页
  int goToIndex = 0; // 跳转页

  /// 上一页
  void last() {
    nextType = -1;
    notifyListeners();
  }

  /// 下一页
  void next() {
    nextType = 1;
    notifyListeners();
  }

  /// 跳页
  void goTo(int index) {
    nextType = 0;
    goToIndex = index;
    notifyListeners();
  }
}
