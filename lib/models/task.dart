import 'package:flutter/material.dart'; // 导入Material包获取TimeOfDay

// 任务优先级枚举
enum TaskPriority {
  low, // 低优先级
  normal, // 普通优先级
  high, // 高优先级
}

class Task {
  String title; // 任务标题
  bool isDone; // 任务状态是否完成
  DateTime createdAt; // 任务创建时间
  DateTime? dueDate; // 任务截止日期，可以为空
  TaskPriority priority; // 任务优先级
  String? tagId; // 标签ID，可以为空
  bool hasNotification; // 是否设置了通知
  int? notificationId; // 通知ID
  TimeOfDay? notificationTime; // 通知时间

  // 构造函数
  Task({
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = TaskPriority.normal, // 默认为普通优先级
    this.tagId,
    this.hasNotification = false,
    this.notificationId,
    this.notificationTime,
  }) : createdAt = createdAt ?? DateTime.now(); // 如果没有传入创建时间，则默认为当前时间

  // 切换任务完成状态
  void toggleDone() {
    isDone = !isDone; // 切换任务完成状态
  }

  // 将任务转换为JSON格式
  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(), // 如果有截止日期，则转换为字符串
        'priority': priority.index, // 存储优先级的索引值
        'tagId': tagId, // 存储标签ID
        'hasNotification': hasNotification,
        'notificationId': notificationId,
        'notificationHour': notificationTime?.hour,
        'notificationMinute': notificationTime?.minute,
      };

  // 从JSON创建Task对象
  factory Task.fromJson(Map<String, dynamic> json) {
    // 处理通知时间
    TimeOfDay? notificationTime;
    if (json['notificationHour'] != null &&
        json['notificationMinute'] != null) {
      notificationTime = TimeOfDay(
        hour: json['notificationHour'],
        minute: json['notificationMinute'],
      );
    }

    return Task(
      title: json['title'],
      isDone: json['isDone'],
      createdAt:
          DateTime.tryParse(json['createdAt']) ?? DateTime.now(), // 解析创建时间
      dueDate:
          json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      priority: json['priority'] != null
          ? TaskPriority.values[json['priority']]
          : TaskPriority.normal,
      tagId: json['tagId'],
      hasNotification: json['hasNotification'] ?? false,
      notificationId: json['notificationId'],
      notificationTime: notificationTime,
    );
  }

  // 判断任务是否已经过期
  bool isOverdue() {
    if (dueDate == null || isDone) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}
