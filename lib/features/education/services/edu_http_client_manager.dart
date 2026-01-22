import 'package:get/get.dart';
import '../../../core/config/api_config.dart';
import '../../../state/settings_store.dart';
import 'edu_http_client.dart';

/// 教务系统 HTTP 客户端管理器
///
/// 提供全局单例的 EduHttpClient，支持动态切换学校配置
class EduHttpClientManager extends GetxController {
  static EduHttpClientManager get to => Get.find();

  late EduHttpClient _client;

  /// 获取当前的 HTTP 客户端实例
  static EduHttpClient get instance => to._client;

  @override
  void onInit() {
    super.onInit();
    _initializeClient();
  }

  /// 初始化 HTTP 客户端
  void _initializeClient() {
    // 从 SettingsStore 获取当前学校配置
    try {
      final currentSchool = SettingsStore.to.currentSchool;
      _client = EduHttpClient(baseUrl: currentSchool.eduApiBaseUrl);
    } catch (e) {
      // 如果 SettingsStore 还未初始化，使用默认配置
      final defaultSchool = ApiConfig.getDefaultSchool();
      _client = EduHttpClient(baseUrl: defaultSchool.eduApiBaseUrl);
    }
  }

  /// 更新学校配置
  ///
  /// 当切换学校时调用此方法更新 API 基础 URL
  void updateSchoolConfig(SchoolConfig school) {
    _client.updateBaseUrl(school.eduApiBaseUrl);
  }

  /// 重新初始化客户端
  ///
  /// 用于完全重置客户端实例（例如在登出后）
  void reinitialize() {
    _client.dispose();
    _initializeClient();
  }
}
