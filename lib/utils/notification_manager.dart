import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task.dart';

class NotificationManager extends ChangeNotifier {
  // 单例模式
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;

  NotificationManager._internal();

  bool _isInitialized = false;

  // 初始化通知系统
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化时区数据
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 初始化Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // 使用默认应用图标
      [
        NotificationChannel(
          channelKey: 'task_reminder_channel',
          channelName: '任务提醒',
          channelDescription: '待办任务的提醒通知',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          locked: true,
          enableVibration: true,
          channelGroupKey: 'basic_channel_group',
          // 设置通知图标
          icon: 'resource://mipmap/ic_launcher',
        )
      ],
      // 设置全局通知图标
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group', channelGroupName: '基本通知')
      ],
    );

    // 设置通知点击监听
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );

    _isInitialized = true;
  }

  // 处理通知点击事件 (静态方法，可在后台调用)
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // 可以在这里处理用户点击通知的逻辑
    debugPrint('收到通知响应: ${receivedAction.payload}');
  }

  // 为任务设置通知
  Future<int> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) await initialize();
    if (!task.hasNotification || task.notificationTime == null) return -1;

    // 检查并请求通知权限
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      final userResponse =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      if (!userResponse) return -1; // 用户拒绝了权限
    }

    // 如果任务已经完成，取消通知
    if (task.isDone) {
      if (task.notificationId != null) {
        await cancelNotification(task.notificationId!);
      }
      return -1;
    }

    // 使用UUID生成唯一ID（如果任务没有通知ID）
    final int notificationId = task.notificationId ??
        DateTime.now().millisecondsSinceEpoch % 2147483647;

    // 计算今天的通知时间
    final now = tz.TZDateTime.now(tz.local);
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      task.notificationTime!.hour,
      task.notificationTime!.minute,
    );

    // 如果今天的通知时间已经过了，安排在明天的相同时间
    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 创建通知内容
    String body = task.title;

    // 如果有截止日期，在通知内容中提及
    if (task.dueDate != null) {
      final dueDate = task.dueDate!;
      final formattedDate =
          '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
      body += ' (截止日期: $formattedDate)';
    }

    // 创建循环定时通知 (每天在指定时间)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'task_reminder_channel',
        title: '任务提醒',
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {'task_id': notificationId.toString()},
      ),
      schedule: NotificationCalendar(
        hour: task.notificationTime!.hour,
        minute: task.notificationTime!.minute,
        second: 0,
        repeats: true, // 每天重复
        allowWhileIdle: true,
      ),
    );

    return notificationId;
  }

  // 取消特定通知
  Future<void> cancelNotification(int notificationId) async {
    await AwesomeNotifications().cancel(notificationId);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // 释放资源
  @override
  void dispose() {
    // 清理通知资源
    AwesomeNotifications().dispose();
    super.dispose();
  }
}
