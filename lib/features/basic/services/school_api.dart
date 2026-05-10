import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client_manager.dart';

class SchoolApi {

  /// 需求1：返回学校列表
  static Future<SchoolListData> listSchools() async {
    final response = await BasicHttpClientManager.instance.get('/api/schools');
    final data = response.data['data'];
    return SchoolListData.fromJson(data as Map<String, dynamic>);
  }

  /// 需求2：根据代号返回学校详情及支持功能
  /// GET /api/schools/:code
  static Future<School> getSchool(String code) async {
    final response = await BasicHttpClientManager.instance.get('/api/schools/$code');
    final data = response.data['data'];
    return School.fromJson(data as Map<String, dynamic>);
  }
}