import 'package:flutter/material.dart';

class EBookController extends ChangeNotifier {
  // 文字大小
  double fontSize = 18.0;

  changFontSize(double fontSize) {
    this.fontSize = fontSize;
    notifyListeners();
  }



  
}
