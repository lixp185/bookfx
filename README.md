## 模拟纸质书籍翻页效果
    本项目主要模拟了我们在看书籍时的翻页动作，并支持了电子书直接预览。
    如果你阅读文本电子书，可以直接使用EBook组件，如果你用来阅读其他例如插画等不需要计算字数的内容，请使用BookFx组件。



## 目前支持的功能

1、支持直接读取txt文件文本阅读，调整字号，模拟翻页。

2、支持自定义当前页、下一页、指定页面的Widget布局内容。

3、支持手势横向滑动翻页，优化了手势控制区域，支持返回上一页。

4、支持翻页动画自定义设置。

5、支持跳到指定页。


## 使用：

 导入：
```dart
 import 'package:bookfx/bookfx.dart';

```
如果你想用在书籍需要计算文字的场景，可以使用EBook，如果你想用在其他场景，例如插画，可以使用BookFx，自定义布局。

## 效果 
**电子书：**

![image](https://github.com/lixp185/bookfx/blob/master/sl1.gif )

**插画：**

![image](https://github.com/lixp185/bookfx/blob/master/sl2.gif )

### 示例代码：
电子书：
```dart
EBook(
    maxWith: MediaQuery.of(context).size.width,
    eBookController: eBookController,
    bookController: bookController,
    data: data,
    fontSize: eBookController.fontSize,
    padding: const EdgeInsetsDirectional.all(15),
    maxHeight:600),
```
插画：
```dart
 BookFx(
     size: Size(MediaQuery.of(context).size.width, 600),
     pageCount: images.length,
     currentPage: (index) {
       return Image.asset(
         images[index],
         fit: BoxFit.fill,
         width: MediaQuery.of(context).size.width,
       );
     },
     lastCallBack: (index) {
       if (index == 0) {
         return;
       }
       setState(() {});
     },
     nextPage: (index) {
       return Image.asset(
         images[index],
         fit: BoxFit.fill,
         width: MediaQuery.of(context).size.width,
       );
     },
     controller: bookController),
```
