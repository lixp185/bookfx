import 'package:bookfx/bookfx.dart';
import 'package:flutter/material.dart';


/// 自定义
class CustomWidget extends StatefulWidget {
  const CustomWidget({Key? key}) : super(key: key);

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  BookController bookController = BookController();

  List images = [
    'assets/aaa.webp',
    'assets/bbb.webp',
    'assets/ccc.webp',
    'assets/ddd.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: BookFx(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          pageCount: images.length,
          currentPage: (index) {
            return Image.asset(
              images[index],
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: double.infinity,

            );
          },
          lastCallBack: (index) {
            print('xxxxxx上一页  $index');
          },
          nextCallBack: (index) {
            print('next $index');
          },
          nextPage: (index) {
            return Image.asset(
              images[index],
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
            );
          },
          controller: bookController),
    );
  }
}
