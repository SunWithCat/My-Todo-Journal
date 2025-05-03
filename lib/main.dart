import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 库
import 'screens/home_screen.dart'; // 引入自定义的主页组件

void main() {
  // 入口函数
  runApp(const TodoJournalApp()); // 启动应用程序，传入 TodoJournalApp 组件
}

class TodoJournalApp extends StatelessWidget {
  // 继承自 StatelessWidget
  const TodoJournalApp({super.key}); // 构造函数，调用父类构造函数

  @override // 重写 build 方法
  Widget build(BuildContext context) {
    // 构建应用程序的 UI
    return MaterialApp(
      // 创建 Material 风格的应用程序
      debugShowCheckedModeBanner: false, // 隐藏右上角的debug标志
      title: '我的待办清单', // 应用标题
      theme: ThemeData(
        // 全局样式配置
        fontFamily: 'NotoSansSC', // 使用本地图字体
        primarySwatch: Colors.blue, // 主色调为棕色
        scaffoldBackgroundColor: const Color(0xFFF8F4E3), // 背景色为淡棕色
        textTheme: const TextTheme(
          // 全局文本样式配置
          bodyMedium: TextStyle(fontSize: 17), // 正文字体大小
          titleLarge:
              TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // 标题字体大小和加粗
        ),
      ),
      home: const HomeScreen(), // 默认主页为 HomeScreen 组件
    );
  }
}
