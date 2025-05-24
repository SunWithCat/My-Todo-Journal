import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tag.dart';
import 'package:uuid/uuid.dart';

// 标签管理器类，用于管理应用标签
class TagManager extends ChangeNotifier {
  // 标签列表
  List<Tag> _tags = [];
  // UUID生成器实例
  final Uuid _uuid = const Uuid();

  // 获取标签列表
  List<Tag> get tags => List.unmodifiable(_tags);

  // 初始化方法，加载保存的标签
  Future<void> initialize() async {
    try {
      await loadTags();
      // 如果没有标签，创建默认标签
      if (_tags.isEmpty) {
        _createDefaultTags();
      }
    } catch (e, stackTrace) {
      debugPrint('标签管理器初始化错误: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      // 如果初始化失败，至少确保有一个空的标签列表
      _tags = [];
    }
  }

  // 创建默认标签
  void _createDefaultTags() {
    try {
      _tags = [
        Tag(
          id: _safeUuidGenerate('work'),
          name: '工作',
          color: Colors.blue,
        ),
        Tag(
          id: _safeUuidGenerate('personal'),
          name: '个人',
          color: Colors.green,
        ),
        Tag(
          id: _safeUuidGenerate('study'),
          name: '学习',
          color: Colors.purple,
        ),
        Tag(
          id: _safeUuidGenerate('urgent'),
          name: '紧急',
          color: Colors.red,
        ),
      ];
      saveTags();
    } catch (e) {
      debugPrint('创建默认标签失败: $e');
      // 如果创建默认标签失败，确保标签列表不为null
      _tags = [];
    }
  }

  // 安全生成UUID的辅助方法
  String _safeUuidGenerate(String fallbackPrefix) {
    try {
      return _uuid.v4();
    } catch (e) {
      debugPrint('UUID生成失败，使用时间戳作为备用ID: $e');
      return '$fallbackPrefix-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // 从本地存储加载标签
  Future<void> loadTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagJsonList = prefs.getStringList('tags');

      if (tagJsonList != null) {
        _tags = tagJsonList
            .map((jsonStr) {
              try {
                return Tag.fromJson(json.decode(jsonStr));
              } catch (e) {
                debugPrint('解析标签JSON失败: $e, jsonStr: $jsonStr');
                return null;
              }
            })
            .where((tag) => tag != null)
            .cast<Tag>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载标签失败: $e');
      _tags = [];
    }
  }

  // 保存标签到本地存储
  Future<void> saveTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagJsonList =
          _tags.map((tag) => json.encode(tag.toJson())).toList();
      await prefs.setStringList('tags', tagJsonList);
    } catch (e) {
      debugPrint('保存标签失败: $e');
    }
  }

  // 添加标签
  Future<void> addTag(String name, Color color) async {
    if (name.isEmpty) {
      debugPrint('标签名不能为空');
      return;
    }

    try {
      final newTag = Tag(
        id: _safeUuidGenerate(name.toLowerCase().replaceAll(' ', '_')),
        name: name,
        color: color,
      );
      _tags.add(newTag);
      notifyListeners();
      await saveTags();
    } catch (e) {
      debugPrint('添加标签失败: $e');
      throw Exception('添加标签失败: $e');
    }
  }

  // 更新标签
  Future<void> updateTag(String id, String name, Color color) async {
    if (name.isEmpty) {
      debugPrint('标签名不能为空');
      return;
    }

    try {
      final index = _tags.indexWhere((tag) => tag.id == id);
      if (index != -1) {
        _tags[index] = Tag(
          id: id,
          name: name,
          color: color,
        );
        notifyListeners();
        await saveTags();
      } else {
        debugPrint('未找到ID为 $id 的标签');
      }
    } catch (e) {
      debugPrint('更新标签失败: $e');
      throw Exception('更新标签失败: $e');
    }
  }

  // 删除标签
  Future<void> deleteTag(String id) async {
    try {
      _tags.removeWhere((tag) => tag.id == id);
      notifyListeners();
      await saveTags();
    } catch (e) {
      debugPrint('删除标签失败: $e');
      throw Exception('删除标签失败: $e');
    }
  }

  // 根据ID获取标签
  Tag? getTagById(String? id) {
    if (id == null) return null;
    try {
      for (var tag in _tags) {
        if (tag.id == id) {
          return tag;
        }
      }
      return null;
    } catch (e) {
      debugPrint('获取标签失败: $e, id: $id');
      return null;
    }
  }
}
