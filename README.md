## 模拟纸质书籍翻页效果
    模拟了我们在看书籍时的翻页动作，并支持了电子书直接预览。
    如果你阅读文本电子书，可以直接使用EBook组件，如果你用来阅读其他例如插画等不需要计算字数的内容，请使用BookFx组件。
### 使用示例：
 **文字书籍示例:**
```dart
EBook(
maxWith: MediaQuery.of(context).size.width,
data: data,
fontSize: fontSize,
maxHeight: MediaQuery.of(context).size.height -
MediaQuery.of(context).padding.top -
56,
),
```

## 目前功能

1、默认支持直接读取txt文件文本阅读，调整字号，模拟翻页。

2、支持完全自定义当前页、下一页、指定页面的Widget布局。

3、支持手势横向滑动翻页，优化了手势控制区域，支持返回上一页。

4、支持翻页动画自定义设置。

...