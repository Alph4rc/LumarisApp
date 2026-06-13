import 'dart:convert';

import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

class SchoolConfigCache {
  const SchoolConfigCache._();

  static Future<void> save(School school) async {
    await PrefsService.instance.setString(
      PrefsKeys.SCHOOL_DATA,
      jsonEncode(school.toJson()),
    );
  }

  static School? read() {
    final jsonString = PrefsService.instance.getString(PrefsKeys.SCHOOL_DATA);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return School.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static int readWeekStartDay() {
    return read()?.weekStartDay ?? School.defaultWeekStartDay;
  }
}
