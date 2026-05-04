int parseSchemaInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return int.parse(value);
  }
  return fallback;
}

double parseSchemaDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.parse(value);
  }
  return fallback;
}

double? parseSchemaNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.parse(value);
  }
  return null;
}

String parseSchemaString(dynamic value, {String fallback = ''}) {
  return value?.toString() ?? fallback;
}

DateTime parseSchemaDateTime(dynamic value) {
  final text = parseSchemaString(value);
  final parsed = DateTime.tryParse(text);
  if (parsed == null) {
    throw FormatException('Invalid date time value: $value');
  }
  return parsed;
}

DateTime? parseSchemaNullableDateTime(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(text);
  if (parsed == null) {
    throw FormatException('Invalid nullable date time value: $value');
  }
  return parsed;
}

bool parseSchemaBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  return fallback;
}

List<int> parseSchemaIntList(dynamic value) {
  if (value is List) {
    return value.map(parseSchemaInt).toList();
  }
  return <int>[];
}

List<String> parseSchemaStringList(dynamic value) {
  if (value is List) {
    return value.map(parseSchemaString).toList();
  }
  return <String>[];
}
