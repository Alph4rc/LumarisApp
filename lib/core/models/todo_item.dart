import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_item.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 4)
class TodoItem {
  @JsonKey(fromJson: _idFromJson)
  @HiveField(0)
  String id;
  @JsonKey(fromJson: _stringFromJson)
  @HiveField(1)
  String title;
  @JsonKey(fromJson: _stringFromJson)
  @HiveField(2)
  String deadline;
  @JsonKey(fromJson: _boolFromJson)
  @HiveField(3)
  bool isCompleted;
  @JsonKey(fromJson: _nullableStringFromJson)
  @HiveField(4)
  String? description;
  @JsonKey(fromJson: _nullableStringFromJson)
  @HiveField(5)
  String? key;

  TodoItem({
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => _$TodoItemToJson(this);

  // 从 Map 创建对象（反序列化）
  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}

String _stringFromJson(dynamic value) => value?.toString() ?? '';

String _idFromJson(dynamic value) =>
    (value ?? DateTime.now().millisecondsSinceEpoch).toString();

String? _nullableStringFromJson(dynamic value) => value?.toString();

bool _boolFromJson(dynamic value) => value is bool ? value : false;
