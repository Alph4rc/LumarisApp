// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoItemAdapter extends TypeAdapter<TodoItem> {
  @override
  final int typeId = 4;

  @override
  TodoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoItem(
      title: fields[1] as String,
      deadline: fields[2] as String,
      isCompleted: fields[3] as bool,
      id: fields[0] as String?,
    )
      ..description = fields[4] as String?
      ..key = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.deadline)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => TodoItem(
      title: _stringFromJson(json['title']),
      deadline: _stringFromJson(json['deadline']),
      isCompleted: json['isCompleted'] == null
          ? false
          : _boolFromJson(json['isCompleted']),
      id: _idFromJson(json['id']),
    )
      ..description = _nullableStringFromJson(json['description'])
      ..key = _nullableStringFromJson(json['key']);

Map<String, dynamic> _$TodoItemToJson(TodoItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'deadline': instance.deadline,
      'isCompleted': instance.isCompleted,
      'description': instance.description,
      'key': instance.key,
    };
