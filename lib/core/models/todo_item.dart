import 'package:hive/hive.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 4)
class TodoItem {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String deadline;
  @HiveField(3)
  bool isCompleted;
  @HiveField(4)
  String? description;
  @HiveField(5)
  String? key;

  TodoItem({
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'deadline': deadline,
        'isCompleted': isCompleted,
        'description': description,
        'key': key,
      };

  // 从 Map 创建对象（反序列化）
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    final item = TodoItem(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: (json['title'] ?? '').toString(),
      deadline: (json['deadline'] ?? '').toString(),
      isCompleted: json['isCompleted'] ?? false,
    );
    item.description = json['description']?.toString();
    item.key = json['key']?.toString();
    return item;
  }
}