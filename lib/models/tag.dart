import 'package:flutter/material.dart';

class Tag {
  String id; // 标签ID
  String name; // 标签名称
  Color color; // 标签颜色

  // 构造函数
  Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  // 将标签转换为JSON格式
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };

  // 从JSON创建Tag对象
  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']),
      );
}
