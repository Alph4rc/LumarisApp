// This is the main test file that runs all tests in the project.

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'all_tests.dart' as all_tests;

void main() {
  // 配置leak_tracker，启用内存泄漏检测
  LeakTesting.settings = LeakTesting.settings.withTrackedAll();
  
  // Run all tests
  all_tests.main();
}
