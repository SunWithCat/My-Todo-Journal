import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../utils/tag_manager.dart';
import 'package:provider/provider.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 显示添加/编辑标签对话框
  void _showAddEditTagDialog(BuildContext context, {Tag? tag}) {
    // 如果是编辑模式，设置初始值
    if (tag != null) {
      _nameController.text = tag.name;
      _selectedColor = tag.color;
    } else {
      _nameController.clear();
      _selectedColor = Colors.blue;
    }

    // 预定义的颜色列表，避免使用重量级的颜色选择器
    final List<Color> predefinedColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(tag == null ? '添加标签' : '编辑标签'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '标签名称',
                      hintText: '请输入标签名称',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('选择颜色:'),
                  const SizedBox(height: 8),
                  // 使用网格布局显示预定义颜色
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: predefinedColors.map((color) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              if (_selectedColor == color)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // 显示当前选中的颜色
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '已选颜色',
                        style: TextStyle(
                          color: _selectedColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    final tagManager =
                        Provider.of<TagManager>(context, listen: false);
                    if (tag == null) {
                      // 添加新标签
                      tagManager.addTag(name, _selectedColor);
                    } else {
                      // 更新现有标签
                      tagManager.updateTag(tag.id, name, _selectedColor);
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Text(tag == null ? '添加' : '保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 显示删除标签确认对话框
  void _showDeleteConfirmDialog(BuildContext context, Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除标签'),
        content: Text('确定要删除标签"${tag.name}"吗？这将会影响所有使用此标签的任务。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final tagManager =
                  Provider.of<TagManager>(context, listen: false);
              tagManager.deleteTag(tag.id);
              Navigator.of(context).pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagManager = Provider.of<TagManager>(context);
    final tags = tagManager.tags;
    // 获取当前主题模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签管理'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTagDialog(context),
        child: const Icon(Icons.add),
      ),
      body: tags.isEmpty
          ? const Center(
              child: Text(
                '没有标签，点击 + 添加',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tag.color,
                    ),
                    title: Text(
                      tag.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? (tag.color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white)
                            : Colors.black, // 浅色模式下强制为黑色
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showAddEditTagDialog(context, tag: tag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteConfirmDialog(context, tag),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
