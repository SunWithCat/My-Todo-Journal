import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/tag_manager.dart';
import '../utils/notification_manager.dart';
import 'package:provider/provider.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(
          String title, TaskPriority priority, DateTime? dueDate, String? tagId)
      onSubmit;

  const AddTaskDialog({super.key, required this.onSubmit});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.normal;
  DateTime? _selectedDate;
  String? _selectedTagId;
  bool _hasNotification = false;
  TimeOfDay _notificationTime = TimeOfDay.now();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 处理提交操作
  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        // 创建任务对象
        final task = Task(
          title: text,
          priority: _selectedPriority,
          dueDate: _selectedDate,
          tagId: _selectedTagId,
          hasNotification: _hasNotification,
          notificationTime: _hasNotification ? _notificationTime : null,
        );

        // 添加任务
        widget.onSubmit(text, _selectedPriority, _selectedDate, _selectedTagId);

        // 如果开启了通知，设置通知
        if (_hasNotification) {
          final notificationManager =
              Provider.of<NotificationManager>(context, listen: false);
          notificationManager
              .scheduleTaskNotification(task)
              .then((notificationId) {
            if (notificationId != -1) {
              task.notificationId = notificationId;
            }
          });
        }

        Navigator.of(context).pop();
      } catch (e) {
        debugPrint('添加任务错误: $e');
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }

  // 显示日期选择器
  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } catch (e) {
      debugPrint('选择日期错误: $e');
    }
  }

  // 显示时间选择器
  Future<void> _selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _notificationTime,
      );
      if (picked != null && picked != _notificationTime) {
        setState(() {
          _notificationTime = picked;
        });
      }
    } catch (e) {
      debugPrint('选择时间错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 安全获取标签管理器
    final tagManager = Provider.of<TagManager>(context, listen: false);
    final tags = tagManager.tags;
    // 获取当前主题模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              const Text(
                '添加新任务',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 任务标题输入框
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '任务标题',
                  hintText: '请输入任务内容（支持中文）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 优先级选择部分
              const Text('优先级:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityOption('低', TaskPriority.low, Colors.green),
                  const SizedBox(width: 8),
                  _buildPriorityOption('普通', TaskPriority.normal, Colors.blue),
                  const SizedBox(width: 8),
                  _buildPriorityOption('高', TaskPriority.high, Colors.red),
                ],
              ),
              const SizedBox(height: 16),

              // 截止日期选择部分
              Row(
                children: [
                  const Text('截止日期:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? '选择日期'
                          : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  if (_selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 通知设置部分
              Row(
                children: [
                  const Text('通知提醒:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Switch(
                    value: _hasNotification,
                    onChanged: (bool value) {
                      setState(() {
                        _hasNotification = value;
                      });
                    },
                  ),
                ],
              ),

              if (_hasNotification) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('提醒时间:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '注意: 通知将在每天设定的时间提醒您完成未完成的任务',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],

              const SizedBox(height: 16),

              // 标签选择部分
              const Text('标签:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // 简化的标签选择
              DropdownButtonFormField<String?>(
                value: _selectedTagId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('选择标签'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('无标签'),
                  ),
                  ...tags.map((tag) => DropdownMenuItem<String?>(
                        value: tag.id,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: tag.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tag.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? (tag.color.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white)
                                    : Colors.black, // 浅色模式下强制为黑色
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTagId = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // 按钮行
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('添加'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建优先级选项
  Widget _buildPriorityOption(
      String label, TaskPriority priority, Color color) {
    final isSelected = _selectedPriority == priority;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
