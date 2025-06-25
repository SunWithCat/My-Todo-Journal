import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../utils/tag_manager.dart';
import '../widgets/task_card.dart';

class SearchScreen extends StatefulWidget {
  final List<Task> tasks;

  const SearchScreen({
    super.key,
    required this.tasks,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Task> _searchResults = [];
  String? _selectedTagId;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 初始时显示所有任务
    _searchResults = List.from(widget.tasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 执行搜索
  void _performSearch(String query) {
    setState(() {
      _isSearching = true;

      // 如果查询为空且没有选择标签，显示所有任务
      if (query.isEmpty && _selectedTagId == null) {
        _searchResults = List.from(widget.tasks);
        _isSearching = false;
        return;
      }

      // 根据查询文本和选中的标签过滤任务
      _searchResults = widget.tasks.where((task) {
        // 标题匹配
        final titleMatch = query.isEmpty ||
            task.title.toLowerCase().contains(query.toLowerCase());

        // 标签匹配
        final tagMatch = _selectedTagId == null || task.tagId == _selectedTagId;

        // 两者都匹配才返回true
        return titleMatch && tagMatch;
      }).toList();

      _isSearching = false;
    });
  }

  // 选择标签
  void _selectTag(String? tagId) {
    setState(() {
      _selectedTagId = tagId;
      _performSearch(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagManager = Provider.of<TagManager>(context);
    final tags = tagManager.tags;

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索任务'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索任务...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2.0)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: _performSearch,
            ),
          ),

          // 标签筛选器
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 所有标签选项
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => _selectTag(null),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTagId == null
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '全部',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // 所有标签选项
                ...tags.map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => _selectTag(tag.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTagId == tag.id
                                ? tag.color.withValues(alpha: 0.2)
                                : Theme.of(context).brightness ==
                                        Brightness.dark
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
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? (tag.color.computeLuminance() > 0.5
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

          // 搜索结果
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '没有找到匹配的任务',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) => TaskCard(
                          task: _searchResults[index],
                          onToggle: () {
                            final taskIndex = widget.tasks.indexWhere(
                                (task) => task == _searchResults[index]);
                            if (taskIndex != -1) {
                              setState(() {
                                widget.tasks[taskIndex].isDone =
                                    !widget.tasks[taskIndex].isDone;
                                // 更新搜索结果中的任务状态
                                _searchResults[index] = widget.tasks[taskIndex];
                              });
                              // 通知父组件任务状态已更改
                              Navigator.pop(context, true);
                            }
                          },
                          onDelete: () async {
                            final navigator =
                                Navigator.of(context); // 在 await 之前捕获 Navigator
                            final taskToDelete = _searchResults[index];
                            final confirmed = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('删除任务'),
                                    content: Text(
                                        '你确定要删除任务“${_searchResults[index].title}”吗？\n此操作无法撤销哦！'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('取消')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text(
                                            '删除',
                                            style: TextStyle(color: Colors.red),
                                          )),
                                    ],
                                  );
                                });
                            if (!mounted) return;
                            if (confirmed == true) {
                              final taskIndex = widget.tasks.indexWhere(
                                  (task) => task == _searchResults[index]);
                              if (taskIndex == -1) {
                                setState(() {
                                  _searchResults.remove(taskToDelete);
                                });
                                navigator
                                    .pop({'delete': true, 'index': taskIndex});
                              }
                            }
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
