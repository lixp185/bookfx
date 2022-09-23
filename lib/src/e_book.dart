import 'dart:async';

import 'package:flutter/material.dart';

import '../bookfx.dart';

/// 作者： lixp
/// 创建时间： 2022/9/14 13:44
/// 类介绍：txt电子书模拟手势翻页
class EBook extends StatefulWidget {
  // 书籍宽度
  final double maxWith;

  // 书籍高度
  final double maxHeight;

  // 书籍内容
  final String data;

  final double fontSize;

  //书籍边距
  final EdgeInsetsGeometry padding;
  final EBookController? eBookController;

  const EBook(
      {Key? key,
      required this.maxWith,
      required this.data,
      required this.maxHeight,
      this.fontSize = 16.0,
      this.padding = const EdgeInsetsDirectional.all(15),
      this.eBookController})
      : super(key: key);

  @override
  State<EBook> createState() => _EBookState();
}

class _EBookState extends State<EBook> {
  BookController controller = BookController();
  String data = """""";
  double textHeight = 10;
  double fontSize = 26;

  /// 获取文字高度
  double calculateTextHeight(
    String value,
    double fontSize,
  ) {
    TextPainter painter = TextPainter(
        locale: WidgetsBinding.instance.window.locale,
        textDirection: TextDirection.ltr,
        maxLines: 1000,
        text: TextSpan(
            text: value,
            style: TextStyle(
              // fontWeight: fontWeight,
              fontSize: fontSize,
            )));
    painter.layout(maxWidth: widget.maxWith - widget.padding.horizontal);

    return painter.size.height;
  }

  int currentStartPos = 0; // 当前页起始文字位置角标
  int nextStartPos = 0; // 下一页起始文字位置角标
  double maxTextHeight = 0;
  bool isOver = false;

  @override
  void initState() {
    super.initState();

    /// 文本区域高度 \r\n 计算有误 ... 高度有误
    data = widget.data.replaceAll('\r\n', '\n');
    fontSize = widget.fontSize;
    textHeight = calculateTextHeight('疯', fontSize);

    /// 文本最大高度 648
    maxTextHeight =
        ((widget.maxHeight - widget.padding.vertical) ~/ textHeight) *
            textHeight;
    // nextPage();
    // print("textHeight :$textHeight");
    // print("maxTextHeight :$maxTextHeight");
    // //  todo  文字高度有误
    // String aa = data.substring(40226, 40474);
    // String aa2 = data.substring(35319, 35548);
    //
    // double h = calculateTextHeight(aa, fontSize);
    // double h2 = calculateTextHeight(aa2, fontSize);
    // print(" test heigh  $h");
    // print(" test heigh  $h2");
    // print(" test   ${data[665]}");

    widget.eBookController?.addListener(() {
      /// 改变字号
      fontSize = widget.eBookController?.fontSize ?? 18;
      textHeight = calculateTextHeight('疯', fontSize);

      /// 文本最大高度 648
      maxTextHeight = (widget.maxHeight ~/ textHeight) * textHeight;
      isOver = false;

      /// 获取书籍所有页码
      loadPages().then((value) {
        print("字号$fontSize");
        setState(() {});
      });
    });

    /// 获取书籍所有页码
    loadPages();
  }

  @override
  void dispose() {
    widget.eBookController?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build book");
    return isOver
        ? BookFx(
            size: Size(MediaQuery.of(context).size.width, widget.maxHeight),
            pageCount: allPages.length,
            bColor: Colors.yellow.shade800,
            nextCallBack: (index) {
              // nextPage();
            },
            lastCallBack: (index) {
              if (index == 0) {
                return;
              }
              setState(() {});
            },
            nextPage: (index) {
              /// 下一页
              return Container(
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
                        style: TextStyle(
                            fontSize: fontSize,
                            // height: 1.5,
                            color: const Color(0xff333333)),
                      ),
                      Positioned(
                        child: Text("$index"),
                        bottom: 0,
                      )
                    ],
                  ));
            },
            currentPage: (int index) {
              /// 当前页 index 页码
              return Container(
                  padding: widget.padding,
                  width: double.infinity,
                  height: double.infinity,
                  // padding: EdgeInsetsDirectional.all(20),
                  color: Colors.yellow,
                  child: Stack(
                    children: [
                      Text(
                        data.isNotEmpty
                            ? data.substring(
                                allPages[index], allPages[index + 1])
                            : "",
                        maxLines: maxTextHeight ~/ textHeight,
                        style: TextStyle(
                            fontSize: fontSize,
                            // height: 1.5,
                            color: const Color(0xff333333)),
                      ),
                      // Text("$index"),
                    ],
                  ));
            },
            controller: controller,
          )
        : const Center(
            child: Text(
              "加载中...",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          );
  }

  List allPages = [];

  int binarySearch(List<int> nums, int target) {
    int left = 0;
    int right = nums.length - 1; // 全文

    while (left <= right) {
      int mid = (right + left) ~/ 2;
      if (nums[mid] == target) {
        print("查找 $mid");
        return mid;
      } else if (nums[mid] < target) {
        left = mid + 1;
      } else if (nums[mid] > target) {
        right = mid - 1;
      } // 注意
    }
    return -1;
  }

  /// 每页最多1000字计算
  Future loadPages() async {
    allPages.clear();
    print("开始${DateTime.now()}");
    return await Future(() {
      int num = 0;
      int index = 0;
      allPages.add(index);
      int left = index;
      int right = 1000;
      while (true) {
        num++;
        if (right >= data.length) {
          right = data.length;
          print("结尾");
          if (calculateTextHeight(data.substring(left, right), fontSize) <=
              maxTextHeight) {
            allPages.add(left);
            print("结束");
            print("allPages ${allPages.toString()}");

            print("结束${DateTime.now()}");
            print("结束循环次数$num");
            setState(() {
              isOver = true;
            });
            return;
          }
        }
        int mid = (left + right) ~/ 2;
        if (calculateTextHeight(data.substring(index, mid), fontSize) ==
            maxTextHeight) {
          for (int i = 0; i < 100; i++) {
            num++;
            if (calculateTextHeight(data.substring(index, mid + i), fontSize) >
                maxTextHeight) {
              index = mid + i - 1;

              left = index;
              right = index + 1000;
              // print("查找 $index");
              // print("查找right $right");
              if (index < data.length - 3 &&
                  data.substring(index, index + 3).startsWith(''
                      '\n')) {
                index += 2;
              }
              allPages.add(index);

              break;
            }
          }
        } else if (calculateTextHeight(data.substring(index, mid), fontSize) <
            maxTextHeight) {
          left = mid + 1;
        } else if (calculateTextHeight(data.substring(index, mid), fontSize) >
            maxTextHeight) {
          right = mid - 1;
        }
      }
    });
  }

// 更改页码数据
//   void nextPage() {
//     /// 下一页
//     for (int i = nextStartPos; i < data.length; i += 20) {
//       if (i >= data.length - 1) {
//         return;
//       }
//       if (calculateTextHeight(data.substring(nextStartPos, i), fontSize) >
//           maxTextHeight) {
//         /// 大于最大行数 去掉\r 回车 不然导致计算高度有误差
//         for (int j = i; j > 0; j--) {
//           if (calculateTextHeight(data.substring(nextStartPos, j), fontSize) >
//                   maxTextHeight &&
//               calculateTextHeight(
//                       data.substring(nextStartPos, j - 1), fontSize) <=
//                   maxTextHeight) {
//             currentStartPos = nextStartPos;
//             nextStartPos = j - 1;
//             print("current next $currentStartPos");
//             print("nextStartPos next  $nextStartPos");
//             return;
//           }
//         }
//       }
//     }
//   }

// recountPage() {
//   /// 重新计算当前页角标
//   for (int i = currentStartPos; i < data.length; i += 20) {
//     if (i >= data.length - 1) {
//       return;
//     }
//     if (calculateTextHeight(data.substring(currentStartPos, i), fontSize) >
//         maxTextHeight) {
//       /// 大于最大行数 去掉\r 回车 不然导致计算高度有误差
//       for (int j = i; j > 0; j--) {
//         if (calculateTextHeight(
//                     data.substring(currentStartPos, j), fontSize) >
//                 maxTextHeight &&
//             calculateTextHeight(
//                     data.substring(currentStartPos, j - 1), fontSize) <=
//                 maxTextHeight) {
//           nextStartPos = j - 1;
//           return;
//         }
//       }
//     }
//   }
// }

  /// 因为上一页
// lastPage() {
//   /// 上一页 前面为 \n
//   for (int i = currentStartPos - 20; i < data.length; i -= 20) {
//     if (i <= 0) {
//       nextStartPos = currentStartPos;
//       currentStartPos = 0;
//       return;
//     }
//     double h =
//         calculateTextHeight(data.substring(i, currentStartPos), fontSize);
//     if (h > maxTextHeight) {
//       for (int j = i; j < currentStartPos; j++) {
//         // 若当前
//         if (calculateTextHeight(
//                     data.substring(j, currentStartPos), fontSize) >
//                 maxTextHeight &&
//             calculateTextHeight(
//                     data.substring(j + 1, currentStartPos), fontSize) <=
//                 maxTextHeight) {
//           nextStartPos = currentStartPos;
//           currentStartPos = j + 1;
//
//           print("current $currentStartPos");
//           print("nextStartPos $nextStartPos");
//
//           return;
//         }
//       }
//     }
//   }
// }
}
