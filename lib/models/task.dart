class Task {
  String title; // 任务标题
  bool isDone; // 任务状态是否完成
  DateTime createdAt;

  Task({
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // 如果没有传入创建时间，则默认为当前时间

  void toggleDone() {
    isDone = !isDone; // 切换任务完成状态
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
      };
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'],
        createdAt:
            DateTime.tryParse(json['createdAt']) ?? DateTime.now(), // 解析创建时间
      );
}
