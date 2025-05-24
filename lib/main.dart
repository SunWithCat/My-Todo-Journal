import 'package:flutter/material.dart'; // 导入 Flutter 的 Material 库
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart'; // 引入自定义的主页组件
import 'utils/theme_manager.dart'; // 导入主题管理器
import 'utils/tag_manager.dart'; // 导入标签管理器
import 'utils/notification_manager.dart'; // 导入通知管理器
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';

// 确保在通知点击时能够运行的入口点
@pragma('vm:entry-point')
void notificationTapBackground(ReceivedAction action) {
  // 这个可以在后台处理通知点击事件
  debugPrint('后台通知点击: ${action.toString()}');
}

void main() async {
  // 捕获Flutter框架中的错误
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter错误: ${details.exception}');
    debugPrint('堆栈跟踪: ${details.stack}');
  };

  // 捕获异步错误
  runZonedGuarded<Future<void>>(() async {
    // 确保Flutter绑定初始化
    WidgetsFlutterBinding.ensureInitialized();

    // 初始化通知管理器
    final notificationManager = NotificationManager();
    await notificationManager.initialize();

    // 注册后台通知处理程序
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationManager.onActionReceivedMethod,
      onNotificationCreatedMethod: null,
      onNotificationDisplayedMethod: null,
      onDismissActionReceivedMethod: null,
    );

    // 设置设备方向，仅支持竖屏模式以减少布局计算负担
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 设置系统UI覆盖样式，优化状态栏显示
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    try {
      // 创建主题管理器
      final themeManager = ThemeManager();
      // 初始化主题设置
      await themeManager.initialize();

      // 创建标签管理器
      final tagManager = TagManager();
      // 初始化标签设置
      await tagManager.initialize();

      // 创建通知管理器
      final notificationManager = NotificationManager();
      // 初始化通知系统
      await notificationManager.initialize();

      // 启动应用程序
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => themeManager),
            ChangeNotifierProvider(create: (_) => tagManager),
            ChangeNotifierProvider(create: (_) => notificationManager),
          ],
          child: const TodoJournalApp(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('初始化错误: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      // 如果初始化失败，尝试启动一个简单的错误应用
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '应用初始化失败',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '错误信息: $e',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 尝试重新启动应用
                      main();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
  }, (error, stackTrace) {
    debugPrint('未捕获的异步错误: $error');
    debugPrint('堆栈跟踪: $stackTrace');
  });
}

class TodoJournalApp extends StatelessWidget {
  // 继承自 StatelessWidget
  const TodoJournalApp({super.key}); // 构造函数，调用父类构造函数

  @override // 重写 build 方法
  Widget build(BuildContext context) {
    // 获取主题管理器
    final themeManager = Provider.of<ThemeManager>(context);

    // 构建应用程序的 UI
    return MaterialApp(
      // 创建 Material 风格的应用程序
      debugShowCheckedModeBanner: false, // 隐藏右上角的debug标志
      title: '我的待办清单', // 应用标题
      theme: themeManager.getTheme(), // 使用主题管理器获取当前主题
      home: const HomeScreen(), // 默认主页为 HomeScreen 组件
      builder: (context, child) {
        // 添加错误处理
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      '渲染错误',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${details.exception}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: const Text('返回主页'),
                    ),
                  ],
                ),
              ),
            ),
          );
        };

        // 确保子组件不为null
        return child ?? const Scaffold();
      },
    );
  }
}
