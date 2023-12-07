import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bookfx.dart';
import 'utils/text.dart';

/// 作者： lixp
/// 创建时间： 2022/9/14 13:44
/// 类介绍：txt电子书模拟手势翻页
class EBook extends StatefulWidget {
  // 书籍宽度
  final double maxWidth;

  // 书籍高度
  final double maxHeight;

  // 书籍内容
  final String data;

  // 字号
  final double fontSize;

  // 段落间距
  final double fontHeight;

  //书籍边距
  final EdgeInsetsGeometry padding;
  final EBookController? eBookController;
  final BookController bookController;
  final Duration? duration;

  const EBook(
      {Key? key,
      required this.maxWidth,
      required this.data,
      required this.maxHeight,
      this.fontSize = 16.0,
      this.padding = const EdgeInsetsDirectional.all(20),
      this.eBookController,
      required this.bookController,
      this.fontHeight = 1.4,
      this.duration})
      : super(key: key);

  @override
  State<EBook> createState() => _EBookState();
}

class _EBookState extends State<EBook> {
  String data = """""";
  double textHeight = 10;
  int currentStartPos = 0; // 当前页起始文字位置角标
  int nextStartPos = 0; // 下一页起始文字位置角标
  double maxTextHeight = 0; // 文字区域最大高度
  bool isOver = false;

  int maxLine = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// 文本区域高度 \r\n 计算有误 ... 高度有误
      data = widget.data.replaceAll('\r\n', '\n');
      /// 单行文字高度
      textHeight = TextUtil.calculateTextHeight('发发发...', widget.fontSize,
          fontHeight: widget.fontHeight,
          maxWidth: widget.maxWidth,
          padding: widget.padding);

      /// 最大行
      maxLine = (widget.maxHeight - widget.padding.vertical) ~/ textHeight;

      /// 文本最大高度 648
      maxTextHeight = (widget.maxHeight - widget.padding.vertical) ~/ textHeight * textHeight;
      /// 获取书籍所有页码
      loadPages();
    });
  }

  @override
  void dispose() {
    // widget.eBookController?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOver
        ? BookFx(
            size: Size(MediaQuery.of(context).size.width, widget.maxHeight),
            pageCount: allPages.length - 1,
            currentBgColor: Colors.yellow.shade800,
            nextCallBack: (index) {
              debugPrint('下一页  $index');
            },
            lastCallBack: (index) {
              debugPrint('上一页  $index');
            },
            duration: widget.duration,
            nextPage: (index) {
              /// 下一页
              return index >= allPages.length - 1
                  ? const SizedBox()
                  : Stack(
                      children: [
                        Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: widget.padding,
                            color: Colors.yellow,
                            child: Stack(
                              children: [
                                Text(
                                  data.isNotEmpty
                                      ? data.substring(
                                          allPages[index], allPages[index + 1])
                                      : "",
                                  maxLines: maxTextHeight ~/ textHeight,
                                  strutStyle: StrutStyle(
                                    forceStrutHeight: true,
                                    height: widget.fontHeight,
                                    fontSize: widget.fontSize,
                                  ),
                                  style: TextStyle(
                                      height: widget.fontHeight,
                                      fontSize: widget.fontSize,
                                      color: const Color(0xff333333)),
                                ),
                              ],
                            )),
                        Positioned(
                          child: Text("${index + 1}/${allPages.length - 1}"),
                          bottom: 5,
                          right: 20,
                        )
                      ],
                    );
            },
            currentPage: (int index) {
              print('当前哦index $index ${allPages[index]} == ${data.substring(allPages[index], allPages[index + 1])}');

              /// 当前页 index 页码
              return Stack(
                children: [
                  Container(
                    padding: widget.padding,
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.yellow,
                    child: Text(
                      data.isNotEmpty
                          ? data.substring(allPages[index], allPages[index + 1])
                          : "",
                      maxLines: maxTextHeight ~/ textHeight,
                      strutStyle: StrutStyle(
                        forceStrutHeight: true,
                        height: widget.fontHeight,
                        fontSize: widget.fontSize,
                      ),
                      style: TextStyle(
                          fontSize: widget.fontSize,
                          height: widget.fontHeight,
                          color: const Color(0xff333333)),
                    ),
                  ),
                  Positioned(
                    child: Text("${index + 1}/${allPages.length - 1}"),
                    bottom: 5,
                    right: 20,
                  )
                ],
              );
            },
            controller: widget.bookController,
          )
        : const CupertinoActivityIndicator();
  }

  List<int> allPages = [];
  Future loadPages() async {
    allPages.clear();
    DateTime.now();
    debugPrint("开始${DateTime.now()}");
    var request = TaskRequest(data, widget.fontSize, widget.fontHeight,
        widget.maxWidth, widget.padding, maxTextHeight);

    return await Future(() {
      List<int> allPages = [];
      int index = 0;
      allPages.add(index);
      int left = index;
      int right = 1000;
      while (true) {
        if (right >= request.data.length - 1) {
          right = request.data.length - 1;
        }
        int i = TextUtil.calculateTextMaxTextPos(
            request.data.substring(left, right), request.fontSize,
            fontHeight: request.fontHeight,
            maxWidth: request.maxWidth,
            maxLines: maxLine,
            padding: request.padding);
        index = index + (i == 0 ? right - left : i);
        left = index;
        allPages.add(index);
        debugPrint("index == $index  right $right   i === $i");
        if (right == request.data.length - 1 &&
            index >= request.data.length - 1) {
          TaskResult result = TaskResult(cost: 200, result: allPages);
          setState(() {
            this.allPages.addAll(result.result);
            isOver = true;
          });
          return result;
        }
        right = index + 1000;
      }
    });
  }

}

class TaskRequest {
  final String data;
  final double fontSize;
  final double fontHeight;
  final double maxWidth;
  final double maxTextHeight;
  final EdgeInsetsGeometry padding;

  TaskRequest(
    this.data,
    this.fontSize,
    this.fontHeight,
    this.maxWidth,
    this.padding,
    this.maxTextHeight,
  );
}

class TaskResult {
  final int cost;
  final List<int> result;

  TaskResult({required this.cost, required this.result});
}
