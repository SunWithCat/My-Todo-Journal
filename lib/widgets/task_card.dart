import 'package:flutter/material.dart';
import '../models/task.dart';

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

  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}'
        ' '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: task.isDone ? Colors.green[100] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: onToggle,
          child: Image.asset(
            task.isDone
                ? 'assets/images/check.png'
                : 'assets/images/uncheck.png',
            width: 32,
            height: 32,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 20,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '添加时间:${_formatTime(task.createdAt)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
