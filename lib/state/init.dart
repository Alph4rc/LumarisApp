import 'package:get/get.dart';
import 'bus_tile_store.dart';
import 'payment_store.dart';
import 'user_store.dart';
import 'course_store.dart';
import 'schedule_store.dart';
import 'settings_store.dart';
import 'electricity_store.dart';
import '../features/education/services/edu_http_client_manager.dart';

/// 初始化所有 Store
void initStores() {
  Get.put(SettingsStore());
  Get.put(EduHttpClientManager()); // 初始化教务系统 HTTP 客户端管理器
  Get.put(UserStore());
  Get.put(CourseStore());
  Get.put(ScheduleStore());
  Get.put(ElectricityStore());
  Get.put(PaymentStore());
  Get.put(BusTileStore());
}

/// 释放所有 Store
void disposeStores() {
  Get.delete<EduHttpClientManager>();
  Get.delete<UserStore>();
  Get.delete<CourseStore>();
  Get.delete<ScheduleStore>();
  Get.delete<SettingsStore>();
  Get.delete<ElectricityStore>();
  Get.delete<PaymentStore>();
  Get.delete<BusTileStore>();
}
