import 'package:flutter/material.dart';
import '../widgets/task_card.dart'; // 导入task_card.dart
import '../widgets/add_task_dialog.dart'; // 导入add_task_dialog.dart
import '../models/task.dart'; // 导入task.dart
import 'dart:convert'; // 导入dart:convert库，用于JSON编码和解码
import 'package:shared_preferences/shared_preferences.dart'; // 导入shared_preferences库，用于本地存储数据

class HomeScreen extends StatefulWidget {
  // 继承自StatefulWidget
  const HomeScreen({super.key}); // 构造函数，调用父类构造函数

  @override // 重写 createState 方法
  State<HomeScreen> createState() => _HomeScreenState(); // 创建状态类
  // 返回一个新的 _HomeScreenState 实例
}

class _HomeScreenState extends State<HomeScreen> {
  // 继承自State<HomeScreen>
  // 定义一个状态类，用于管理 HomeScreen 的状态
  final List<Task> _tasks = []; // 任务列表，初始为空
  // 定义一个私有变量 _tasks，用于存储任务列表，初始为空

  @override
  void initState() {
    super.initState();
    _loadTasks(); // 页面初始化时加载任务
  }

  void _addTask(String title) {
    // 添加任务的方法，接收任务标题
    if (title.isEmpty) return; // 如果标题为空，直接返回
    setState(() {
      // 更新状态
      // 调用 setState 方法，通知 Flutter 框架状态已改变
      _tasks.add(Task(title: title)); // 创建一个新的 Task 实例，并添加到任务列表中
    });
    _saveTasks();
  }

  void _toggleTask(int index) {
    // 状态切换
    setState(() {
      // 用 setState 告诉 Flutter : 我要刷新界面
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    // 任务删除
    setState(() {
      // 用 setState 告诉 Flutter : 我要刷新界面
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(onSubmit: _addTask),
    );
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskJsonList =
        _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskJsonList);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskJsonList = prefs.getStringList('tasks');
    if (taskJsonList != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(
            taskJsonList.map((jsonStr) => Task.fromJson(json.decode(jsonStr))));
      });
    }
  }

  @override //
  Widget build(BuildContext context) {
    return Stack(
      // 将多个组件堆叠
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/notebook_bg.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('我的待办清单'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddDialog,
            backgroundColor: Colors.blue[300],
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tasks.length,
            itemBuilder: (context, index) => TaskCard(
              task: _tasks[index],
              onToggle: () => _toggleTask(index),
              onDelete: () => _deleteTask(index),
            ),
          ),
        ),
      ],
    );
  }
}
