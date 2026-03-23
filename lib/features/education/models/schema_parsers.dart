int parseSchemaInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return int.parse(value);
  }
  return fallback;
}
