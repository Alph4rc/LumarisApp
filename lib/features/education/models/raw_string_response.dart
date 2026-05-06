import 'package:json_annotation/json_annotation.dart';

part 'raw_string_response.g.dart';

@JsonSerializable(createFactory: false)
class RawStringResponse {
  final String value;

  const RawStringResponse(this.value);

  factory RawStringResponse.fromResponse(dynamic data) {
    if (data is String) {
      return RawStringResponse(data);
    }
    throw ArgumentError.value(data, 'data', 'Expected string response');
  }

  Map<String, dynamic> toJson() => _$RawStringResponseToJson(this);
}
