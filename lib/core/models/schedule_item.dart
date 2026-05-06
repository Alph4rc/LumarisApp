import 'package:json_annotation/json_annotation.dart';

part 'schedule_item.g.dart';

@JsonSerializable(explicitToJson: true)
class ScheduleItem {
  final String title;
  final String time;
  final String location;
  final String teacher;
  final String description;

  ScheduleItem({
    required this.title,
    required this.time,
    required this.location,
    required this.teacher,
    this.description = '',
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleItemToJson(this);
}
