import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/models/link_model.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

import 'edu_http_client_manager.dart';

class LinkApi {

  static Future<List<CategoryModel>> getLinks() async {
    final List<CategoryModel> list = [];
    try {
      final response = await await EduHttpClientManager.instance.get('/SchoolNav');

      if (response is List) {
        for (final item in response) {
          list.add(CategoryModel.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.error(
          'Error fetching links',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    list.sort((a, b) => a.index.compareTo(b.index));
    return list;
  }
}
