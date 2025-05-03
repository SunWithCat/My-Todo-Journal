import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  // 有状态变化
  final Function(String) onSubmit; // 提交任务的回调函数，接收一个字符串参数
  // 用于添加新任务的对话框组件

  const AddTaskDialog({super.key, required this.onSubmit}); // 构造函数，接收一个回调函数
  // super.key 用于传递给父类的构造函数，required 表示该参数是必须的

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState(); // 创建状态类
  // 返回一个新的 _AddTaskDialogState 实例
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  // 继承自State<AddTaskDialog>
  // 定义一个状态类，用于管理 AddTaskDialog 的状态
  final TextEditingController _controller =
      TextEditingController(); // 文本编辑控制器，用于获取输入的文本
  // 用于控制文本输入框的内容

  void _handleSubmit() {
    // 提交任务的方法
    // 当用户点击提交按钮时调用
    final text = _controller.text.trim(); // 获取输入的文本并去除前后空格
    // 调用 trim() 方法去除字符串前后的空格
    if (text.isNotEmpty) {
      // 如果文本不为空
      // 判断文本是否为空
      widget.onSubmit(text); // 调用回调函数，将文本传递给父组件
      // 调用父组件传入的 onSubmit 方法，传入文本
      Navigator.of(context).pop(); // 关闭对话框
      // 调用 Navigator 的 pop 方法，关闭当前对话框
    }
  }

  @override
  Widget build(BuildContext context) {
    // 构建对话框的 UI
    return AlertDialog(
      // 创建一个警告对话框
      // AlertDialog 是 Flutter 提供的一个对话框组件
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // 设置对话框的圆角
      title: const Text('添加新任务', style: TextStyle(fontSize: 20)), // 对话框标题
      // 设置对话框的标题和字体大小
      content: TextField(
        // 创建一个文本输入框
        // 用于输入任务内容
        controller: _controller, // 绑定文本编辑控制器
        // 绑定控制器，获取输入的文本
        autofocus: true, // 自动获取焦点
        // 设置文本输入框自动获取焦点
        decoration: const InputDecoration(hintText: '请输入任务内容（支持中文）'), // 提示文本
      ),
      actions: [
        // 对话框的操作按钮
        // actions 是对话框底部的按钮列表
        TextButton(
          // 创建一个文本按钮
          // 用于取消操作
          onPressed: () => Navigator.of(context).pop(), // 点击时关闭对话框
          // 调用 Navigator 的 pop 方法，关闭当前对话框
          child: const Text('取消'), // 按钮文本
        ),
        ElevatedButton(
            onPressed: _handleSubmit, child: const Text('添加')), // 创建一个提升按钮
        // 用于提交操作
      ],
    );
  }
}
