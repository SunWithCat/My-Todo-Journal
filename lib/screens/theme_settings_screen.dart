import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/theme_settings.dart';
import '../utils/theme_manager.dart';

class ThemeSettingsScreen extends StatefulWidget {
  final ThemeManager themeManager;

  const ThemeSettingsScreen({
    super.key,
    required this.themeManager,
  });

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late ThemeSettings settings;
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    settings = widget.themeManager.settings;
    pickerColor = settings.customPrimaryColor ?? settings.getPrimaryColor();
  }

  // 切换深色模式
  void _toggleDarkMode() {
    widget.themeManager.toggleDarkMode();
    setState(() {
      settings = widget.themeManager.settings;
    });
  }

  // 选择预设主题
  void _selectPreset(PresetTheme preset) {
    widget.themeManager.setPresetTheme(preset);
    setState(() {
      settings = widget.themeManager.settings;
    });
  }

  // 设置自定义颜色
  void _setCustomColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择自定义颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              setState(() {
                pickerColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.themeManager.setCustomColor(pickerColor);
              setState(() {
                settings = widget.themeManager.settings;
              });
              Navigator.of(context).pop();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 深色模式开关
          Card(
            child: ListTile(
              title: const Text('深色模式'),
              subtitle: const Text('切换应用的明暗主题'),
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (value) => _toggleDarkMode(),
                activeColor: settings.getPrimaryColor(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 预设主题选择
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('预设主题',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildThemeOption(
                        '蓝色',
                        const Color(0xFF3B82F6),
                        settings.activePreset == PresetTheme.blue &&
                            !settings.useCustomColor,
                        () => _selectPreset(PresetTheme.blue),
                      ),
                      _buildThemeOption(
                        '绿色',
                        const Color(0xFF10B981),
                        settings.activePreset == PresetTheme.green &&
                            !settings.useCustomColor,
                        () => _selectPreset(PresetTheme.green),
                      ),
                      _buildThemeOption(
                        '紫色',
                        const Color(0xFF8B5CF6),
                        settings.activePreset == PresetTheme.purple &&
                            !settings.useCustomColor,
                        () => _selectPreset(PresetTheme.purple),
                      ),
                      _buildThemeOption(
                        '橙色',
                        const Color(0xFFF97316),
                        settings.activePreset == PresetTheme.orange &&
                            !settings.useCustomColor,
                        () => _selectPreset(PresetTheme.orange),
                      ),
                      _buildThemeOption(
                        '粉色',
                        const Color(0xFFEC4899),
                        settings.activePreset == PresetTheme.pink &&
                            !settings.useCustomColor,
                        () => _selectPreset(PresetTheme.pink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 自定义颜色
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('自定义主题颜色',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildThemeOption(
                        '自定义',
                        settings.customPrimaryColor ?? Colors.grey,
                        settings.useCustomColor,
                        null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _setCustomColor,
                          child: const Text('选择颜色'),
                        ),
                      ),
                    ],
                  ),
                  if (settings.useCustomColor) ...[
                    const SizedBox(height: 8),
                    Text(
                      '当前使用自定义颜色',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 提示信息
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('提示', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• 设置会自动保存'),
                  Text('• 重启应用后设置依然有效'),
                  Text('• 可随时切换回预设主题'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建主题选项卡片
  Widget _buildThemeOption(
      String label, Color color, bool isSelected, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
