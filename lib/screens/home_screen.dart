import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/task_card.dart'; // 导入task_card.dart
import '../widgets/add_task_dialog.dart'; // 导入add_task_dialog.dart
import '../models/task.dart'; // 导入task.dart
import '../utils/theme_manager.dart'; // 导入主题管理器
import '../utils/tag_manager.dart'; // 导入标签管理器
import '../utils/notification_manager.dart'; // 导入通知管理器
import 'theme_settings_screen.dart'; // 导入主题设置页面
import 'tag_management_screen.dart'; // 导入标签管理页面
import 'search_screen.dart'; // 导入搜索页面
import 'dart:convert'; // 导入dart:convert库，用于JSON编码和解码
import 'package:shared_preferences/shared_preferences.dart'; // 导入shared_preferences库，用于本地存储数据

// 任务筛选类型枚举
enum TaskFilterType {
  all, // 全部任务
  active, // 未完成任务
  completed, // 已完成任务
  overdue, // 已过期任务（未完成且过期）
  byTag, // 按标签分组
}

// 任务排序类型枚举
enum TaskSortType {
  creationDate, // 创建时间排序
  dueDate, // 截止日期排序
  priority, // 优先级排序
}

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

  // 当前的筛选类型，默认为全部任务
  TaskFilterType _currentFilter = TaskFilterType.all;
  // 当前的排序类型，默认为创建时间
  TaskSortType _currentSort = TaskSortType.creationDate;
  // 排序方向，默认为降序（新的在前）
  bool _isAscending = false;
  // 当前选中的标签ID，用于按标签筛选
  String? _selectedTagId;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // 页面初始化时加载任务
  }

  // 添加任务方法，接收任务标题、优先级、截止日期和标签ID
  void _addTask(
      String title, TaskPriority priority, DateTime? dueDate, String? tagId) {
    // 添加任务的方法，接收任务标题
    if (title.isEmpty) return; // 如果标题为空，直接返回

    // 获取通知管理器
    final notificationManager =
        Provider.of<NotificationManager>(context, listen: false);

    setState(() {
      // 更新状态
      // 调用 setState 方法，通知 Flutter 框架状态已改变
      final newTask = Task(
        title: title,
        priority: priority,
        dueDate: dueDate,
        tagId: tagId,
      ); // 创建一个新的 Task 实例

      _tasks.add(newTask); // 添加到任务列表
      _sortTasks(); // 排序任务

      // 如果任务设置了通知，设置通知
      if (newTask.hasNotification && newTask.notificationTime != null) {
        notificationManager
            .scheduleTaskNotification(newTask)
            .then((notificationId) {
          if (notificationId != -1) {
            setState(() {
              // 更新任务的通知ID
              final index = _tasks.indexOf(newTask);
              if (index != -1) {
                _tasks[index].notificationId = notificationId;
                _saveTasks(); // 保存任务
              }
            });
          }
        });
      }
    });
    _saveTasks(); // 保存任务
  }

  void _toggleTask(int index) {
    // 状态切换
    setState(() {
      // 用 setState 告诉 Flutter : 我要刷新界面
      _tasks[index].isDone = !_tasks[index].isDone;

      // 如果任务已完成且有通知，取消通知
      if (_tasks[index].isDone &&
          _tasks[index].hasNotification &&
          _tasks[index].notificationId != null) {
        final notificationManager =
            Provider.of<NotificationManager>(context, listen: false);
        notificationManager.cancelNotification(_tasks[index].notificationId!);
      }
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    // 任务删除
    // 如果任务有通知，取消通知
    if (_tasks[index].hasNotification && _tasks[index].notificationId != null) {
      final notificationManager =
          Provider.of<NotificationManager>(context, listen: false);
      notificationManager.cancelNotification(_tasks[index].notificationId!);
    }

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

  // 打开主题设置页面
  void _openThemeSettings() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeSettingsScreen(themeManager: themeManager),
      ),
    );
  }

  // 打开标签管理页面
  void _openTagManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TagManagementScreen(),
      ),
    );
  }

  // 打开搜索页面
  Future<void> _openSearchScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(tasks: _tasks),
      ),
    );

    // 处理搜索页面返回的结果
    if (result != null) {
      if (result is Map && result['delete'] == true) {
        // 删除任务
        _deleteTask(result['index']);
      } else if (result == true) {
        // 任务状态已更改，保存任务
        _saveTasks();
      }
    }
  }

  // 根据当前的排序类型对任务进行排序
  void _sortTasks() {
    _tasks.sort((a, b) {
      int result;

      // 根据选择的排序类型进行比较
      switch (_currentSort) {
        case TaskSortType.creationDate:
          // 按创建时间排序
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case TaskSortType.dueDate:
          // 按截止日期排序，无截止日期的排在最后
          if (a.dueDate == null && b.dueDate == null) {
            result = 0;
          } else if (a.dueDate == null) {
            result = 1;
          } else if (b.dueDate == null) {
            result = -1;
          } else {
            result = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortType.priority:
          // 按优先级排序（高优先级在前）
          result = b.priority.index.compareTo(a.priority.index);
          break;
      }

      // 根据排序方向返回结果
      return _isAscending ? result : -result;
    });
  }

  // 获取符合筛选条件的任务列表
  List<Task> _getFilteredTasks() {
    switch (_currentFilter) {
      case TaskFilterType.all:
        return _tasks;
      case TaskFilterType.active:
        return _tasks.where((task) => !task.isDone).toList();
      case TaskFilterType.completed:
        return _tasks.where((task) => task.isDone).toList();
      case TaskFilterType.overdue:
        return _tasks.where((task) => task.isOverdue()).toList();
      case TaskFilterType.byTag:
        // 如果没有选中标签，返回所有任务
        if (_selectedTagId == null) return _tasks;
        // 否则返回指定标签的任务
        return _tasks.where((task) => task.tagId == _selectedTagId).toList();
    }
  }

  // 更改筛选类型
  void _changeFilter(TaskFilterType filterType) {
    setState(() {
      _currentFilter = filterType;
      // 如果切换到非按标签筛选的模式，清空选中的标签
      if (filterType != TaskFilterType.byTag) {
        _selectedTagId = null;
      }
    });
  }

  // 选择标签进行筛选
  void _selectTag(String? tagId) {
    setState(() {
      _selectedTagId = tagId;
      _currentFilter = TaskFilterType.byTag;
    });
  }

  // 更改排序类型
  void _changeSort(TaskSortType sortType) {
    setState(() {
      // 如果选择了相同的排序类型，则切换排序方向
      if (_currentSort == sortType) {
        _isAscending = !_isAscending;
      } else {
        _currentSort = sortType;
        _isAscending = false; // 默认为降序
      }
      _sortTasks(); // 重新排序
    });
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
        _sortTasks(); // 加载后排序
      });
    }
  }

  @override //
  Widget build(BuildContext context) {
    // 获取主题管理器和当前主题
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = themeManager.settings.isDarkMode;

    // 获取标签管理器
    final tagManager = Provider.of<TagManager>(context);
    final tags = tagManager.tags;

    // 获取筛选后的任务列表
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('待办清单'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchScreen,
            tooltip: '搜索任务',
          ),
          // 排序按钮
          PopupMenuButton<TaskSortType>(
            tooltip: '排序方式',
            icon: const Icon(Icons.sort),
            onSelected: _changeSort,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskSortType.creationDate,
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      '创建时间 ${_currentSort == TaskSortType.creationDate ? (_isAscending ? '↑' : '↓') : ''}',
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskSortType.dueDate,
                child: Row(
                  children: [
                    const Icon(Icons.event),
                    const SizedBox(width: 8),
                    Text(
                      '截止日期 ${_currentSort == TaskSortType.dueDate ? (_isAscending ? '↑' : '↓') : ''}',
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskSortType.priority,
                child: Row(
                  children: [
                    const Icon(Icons.priority_high),
                    const SizedBox(width: 8),
                    Text(
                      '优先级 ${_currentSort == TaskSortType.priority ? (_isAscending ? '↑' : '↓') : ''}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 标签管理按钮
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: _openTagManagement,
            tooltip: '标签管理',
          ),
          // 深色/浅色模式切换按钮
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeManager.toggleDarkMode,
            tooltip: isDarkMode ? '切换到浅色模式' : '切换到深色模式',
          ),
          // 主题设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openThemeSettings,
            tooltip: '主题设置',
          ),
        ],
      ),
      // 底部导航栏，用于筛选任务
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 固定显示所有项目
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        currentIndex: _currentFilter.index,
        onTap: (index) => _changeFilter(TaskFilterType.values[index]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '全部',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outline_blank),
            label: '未完成',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: '已完成',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber),
            label: '已过期',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label),
            label: '标签',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        backgroundColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _currentFilter == TaskFilterType.byTag
          ? Column(
              children: [
                // 标签选择器
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // 所有标签选项
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                        child: InkWell(
                          onTap: () => _selectTag(null),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTagId == null
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('全部标签'),
                          ),
                        ),
                      ),
                      // 所有标签选项
                      ...tags.map((tag) => Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0, top: 8.0),
                            child: InkWell(
                              onTap: () => _selectTag(tag.id),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedTagId == tag.id
                                      ? tag.color.withValues(alpha: 0.2)
                                      : isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: tag.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tag.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? (tag.color.computeLuminance() >
                                                    0.5
                                                ? Colors.black
                                                : Colors.white)
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                // 任务列表
                Expanded(
                  child: filteredTasks.isEmpty
                      // 如果没有任务，显示提示信息
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 60,
                                color: isDarkMode
                                    ? Colors.grey
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getEmptyStateMessage(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      // 如果有任务，显示任务列表
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) => TaskCard(
                            task: filteredTasks[index],
                            onToggle: () => _toggleTask(
                                _tasks.indexOf(filteredTasks[index])),
                            onDelete: () => _deleteTask(
                                _tasks.indexOf(filteredTasks[index])),
                          ),
                        ),
                ),
              ],
            )
          : filteredTasks.isEmpty
              // 如果没有任务，显示提示信息
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: isDarkMode ? Colors.grey : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getEmptyStateMessage(),
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              isDarkMode ? Colors.grey : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              // 如果有任务，显示任务列表
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) => TaskCard(
                    task: filteredTasks[index],
                    onToggle: () =>
                        _toggleTask(_tasks.indexOf(filteredTasks[index])),
                    onDelete: () =>
                        _deleteTask(_tasks.indexOf(filteredTasks[index])),
                  ),
                ),
    );
  }

  // 根据当前筛选类型返回空状态提示信息
  String _getEmptyStateMessage() {
    switch (_currentFilter) {
      case TaskFilterType.all:
        return '没有任务，点击 + 添加';
      case TaskFilterType.active:
        return '没有未完成的任务';
      case TaskFilterType.completed:
        return '没有已完成的任务';
      case TaskFilterType.overdue:
        return '没有过期的任务';
      case TaskFilterType.byTag:
        return _selectedTagId == null ? '没有任务，点击 + 添加' : '该标签下没有任务';
    }
  }
}
