// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreModelAdapter extends TypeAdapter<ScoreModel> {
  @override
  final int typeId = 1;

  @override
  ScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreModel(
      name: fields[0] as String,
      lessonCode: fields[1] as String,
      lessonName: fields[2] as String,
      grade: fields[3] as String,
      gpa: fields[4] as String,
      gradeDetail: fields[5] as String,
      credit: fields[6] as String,
      isMinor: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.lessonCode)
      ..writeByte(2)
      ..write(obj.lessonName)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.gpa)
      ..writeByte(5)
      ..write(obj.gradeDetail)
      ..writeByte(6)
      ..write(obj.credit)
      ..writeByte(7)
      ..write(obj.isMinor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoreListAdapter extends TypeAdapter<ScoreList> {
  @override
  final int typeId = 2;

  @override
  ScoreList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreList(
      semester: fields[1] as SemesterModel,
      list: (fields[0] as List).cast<ScoreModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScoreList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.list)
      ..writeByte(1)
      ..write(obj.semester);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
