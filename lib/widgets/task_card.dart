import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../utils/theme_manager.dart';
import '../utils/tag_manager.dart';

class TaskCard extends StatelessWidget {
  // 不需要管理状态， 由父类决定
  final Task task; // 任务对象
  final VoidCallback onToggle; // 点击勾选图标时调用的方法
  final VoidCallback onDelete; // 点击删除图标时调用的方法

  const TaskCard({
    // 标准的构造函数
    super.key, // 继承父类
    required this.task, // 必须传入task
    required this.onToggle, // 必须传入
    required this.onDelete, // 必须传入
  });

  // 格式化日期时间为易读字符串
  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}'
        ' '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 格式化截止日期（只显示日期）
  String _formatDate(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  }

  // 格式化通知时间（只显示时间）
  String _formatNotificationTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 获取优先级对应的颜色
  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.normal:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  // 获取优先级对应的文本
  String _getPriorityText() {
    switch (task.priority) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.normal:
        return '中';
      case TaskPriority.high:
        return '高';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 判断任务是否过期
    final bool isOverdue = task.isOverdue();

    // 获取主题设置
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.settings.isDarkMode;

    // 获取标签管理器
    final tagManager = Provider.of<TagManager>(context);
    final tag = tagManager.getTagById(task.tagId);

    // 根据深色/浅色模式和任务状态确定卡片颜色
    Color cardColor;
    if (task.isDone) {
      // 已完成任务的颜色
      cardColor = isDarkMode ? const Color(0xFF2A3E2A) : Colors.green[100]!;
    } else if (isOverdue) {
      // 已过期任务的颜色
      cardColor = isDarkMode ? const Color(0xFF3E2A2A) : Colors.red[50]!;
    } else {
      // 普通任务的颜色
      cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    }

    // 优先级颜色
    final priorityColor = _getPriorityColor();
    final priorityText = _getPriorityText();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.isDone
              ? Colors.green.withValues(alpha: 0.3)
              : isOverdue
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 任务状态图标（可点击）
                InkWell(
                  onTap: onToggle,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isDone
                            ? Colors.green
                            : isDarkMode
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey,
                        width: 2,
                      ),
                      color: task.isDone ? Colors.green : Colors.transparent,
                    ),
                    child: task.isDone
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // 任务内容区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 任务标题
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone
                              ? isDarkMode
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.black54
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 创建时间
                      Text(
                        '创建于: ${_formatTime(task.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black54,
                        ),
                      ),

                      // 截止日期（如果有）
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 14,
                              color: isOverdue
                                  ? Colors.red
                                  : isDarkMode
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '截止: ${_formatDate(task.dueDate!)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isOverdue ? FontWeight.bold : null,
                                color: isOverdue
                                    ? Colors.red
                                    : isDarkMode
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : Colors.black54,
                              ),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '已过期',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],

                      // 通知提醒（如果有）
                      if (task.hasNotification &&
                          task.notificationTime != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              size: 14,
                              color: isDarkMode ? Colors.amber : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '每日提醒: ${_formatNotificationTime(task.notificationTime!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.amber
                                    : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // 删除按钮
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black45,
                  ),
                  onPressed: onDelete,
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 底部信息栏
            Row(
              children: [
                // 优先级标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 12,
                        color: priorityColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        priorityText,
                        style: TextStyle(
                          fontSize: 12,
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 标签（如果有）
                if (tag != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tag.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.label,
                          size: 12,
                          color: tag.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tag.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: tag.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
