import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/map_model.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';

class MapApi{
  static Future<List<MapModel>> getMap() async {
    try {
      final response = await EduHttpClientManager.instance.get('/Map');
      if (response is! List) {
        throw Exception('地图数据返回格式错误: ${response.runtimeType}');
      }
      return response
          .map((item) => MapModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      AppLogger.error('获取地图数据失败: $e');
      rethrow;
    }
  }
}