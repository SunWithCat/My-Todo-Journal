import 'package:flutter/material.dart';

// 预设主题枚举
enum PresetTheme {
  blue, // 蓝色主题（默认）
  green, // 绿色主题
  purple, // 紫色主题
  orange, // 橙色主题
  pink, // 粉色主题
}

// 主题设置类，用于保存用户的主题配置
class ThemeSettings {
  bool isDarkMode; // 是否开启深色模式
  PresetTheme activePreset; // 当前使用的预设主题
  Color? customPrimaryColor; // 自定义主色调（可选）
  bool useCustomColor; // 是否使用自定义颜色

  // 构造函数
  ThemeSettings({
    this.isDarkMode = false, // 默认为浅色模式
    this.activePreset = PresetTheme.blue, // 默认为蓝色主题
    this.customPrimaryColor, // 默认无自定义颜色
    this.useCustomColor = false, // 默认不使用自定义颜色
  });

  // 从JSON创建ThemeSettings对象
  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      activePreset: PresetTheme.values[json['activePreset'] ?? 0],
      customPrimaryColor: json['customPrimaryColor'] != null
          ? Color(json['customPrimaryColor'])
          : null,
      useCustomColor: json['useCustomColor'] ?? false,
    );
  }

  // 将ThemeSettings转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'activePreset': activePreset.index,
      'customPrimaryColor': customPrimaryColor?.toARGB32(),
      'useCustomColor': useCustomColor,
    };
  }

  // 获取当前主题的主色调
  Color getPrimaryColor() {
    if (useCustomColor && customPrimaryColor != null) {
      return customPrimaryColor!;
    }

    // 根据预设主题返回对应的颜色
    switch (activePreset) {
      case PresetTheme.blue:
        return const Color(0xFF3B82F6); // 蓝色
      case PresetTheme.green:
        return const Color(0xFF10B981); // 绿色
      case PresetTheme.purple:
        return const Color(0xFF8B5CF6); // 紫色
      case PresetTheme.orange:
        return const Color(0xFFF97316); // 橙色
      case PresetTheme.pink:
        return const Color(0xFFEC4899); // 粉色
    }
  }

  // 获取与主色调搭配的次级颜色
  Color getSecondaryColor() {
    Color primaryColor = getPrimaryColor();

    // 生成一个次级颜色，稍微调整色相
    HSLColor hsl = HSLColor.fromColor(primaryColor);
    return hsl.withHue((hsl.hue + 30) % 360).toColor();
  }

  // 获取预设主题的名称
  String getPresetName() {
    switch (activePreset) {
      case PresetTheme.blue:
        return '蓝色';
      case PresetTheme.green:
        return '绿色';
      case PresetTheme.purple:
        return '紫色';
      case PresetTheme.orange:
        return '橙色';
      case PresetTheme.pink:
        return '粉色';
    }
  }
}
