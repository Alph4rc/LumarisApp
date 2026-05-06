import 'package:json_annotation/json_annotation.dart';

import 'schema_parsers.dart';

part 'exam_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamItem {
  @JsonKey(fromJson: parseSchemaString)
  final String name;

  @JsonKey(name: 'time', fromJson: parseSchemaString)
  final String examTime;

  @JsonKey(name: 'location', fromJson: parseSchemaString)
  final String room;

  @JsonKey(name: 'seat', fromJson: parseSchemaString)
  final String seatNo;

  ExamItem({
    this.name = '',
    this.examTime = '',
    this.room = '',
    this.seatNo = '',
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) =>
      _$ExamItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExamItemToJson(this);
}
