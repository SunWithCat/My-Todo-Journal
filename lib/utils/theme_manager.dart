import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_settings.dart';

// 主题管理器类，用于管理应用主题
class ThemeManager extends ChangeNotifier {
  // 默认的主题设置
  ThemeSettings _settings = ThemeSettings();

  // 获取当前主题设置
  ThemeSettings get settings => _settings;

  // 初始化方法，加载保存的主题设置
  Future<void> initialize() async {
    await loadSettings();
  }

  // 从本地存储加载主题设置
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString('theme_settings');

      if (themeJson != null) {
        _settings = ThemeSettings.fromJson(json.decode(themeJson));
        notifyListeners();
      }
    } catch (e) {
      // 如果加载失败，使用默认设置
      _settings = ThemeSettings();
    }
  }

  // 保存主题设置到本地存储
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_settings', json.encode(_settings.toJson()));
    } catch (e) {
      debugPrint('保存主题设置失败: $e');
    }
  }

  // 切换明暗模式
  void toggleDarkMode() {
    _settings.isDarkMode = !_settings.isDarkMode;
    notifyListeners();
    saveSettings();
  }

  // 设置预设主题
  void setPresetTheme(PresetTheme preset) {
    _settings.activePreset = preset;
    _settings.useCustomColor = false; // 切换到预设主题时禁用自定义颜色
    notifyListeners();
    saveSettings();
  }

  // 设置自定义颜色
  void setCustomColor(Color color) {
    _settings.customPrimaryColor = color;
    _settings.useCustomColor = true; // 启用自定义颜色
    notifyListeners();
    saveSettings();
  }

  // 获取当前主题数据
  ThemeData getTheme() {
    final primaryColor = _settings.getPrimaryColor();
    final isDark = _settings.isDarkMode;

    // 根据明暗模式和主色调创建主题
    return ThemeData(
      primaryColor: primaryColor,
      primarySwatch: _createMaterialColor(primaryColor),
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F4E3),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F4E3),
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: isDark ? 4 : 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F4E3),
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey[700],
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      // 对话框主题
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: isDark ? 24 : 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // 辅助函数：从单个颜色创建MaterialColor
  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255).round(),
        g = (color.g * 255).round(),
        b = (color.b * 255).round();

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.toARGB32(), swatch);
  }
}
