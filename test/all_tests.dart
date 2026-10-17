import 'unit/course_model_test.dart' as course_model_test;
import 'unit/score_model_test.dart' as score_model_test;
import 'unit/turnover_analyzer_test.dart' as turnover_analyzer_test;
import 'unit/course_store_test.dart' as course_store_test;
import 'unit/course_repository_test.dart' as course_repository_test;
import 'unit/score_repository_test.dart' as score_repository_test;
import 'widget/empty_widget_test.dart' as empty_widget_test;

void main() {
  // 运行所有单元测试
  course_model_test.main();
  score_model_test.main();
  turnover_analyzer_test.main();
  course_store_test.main();
  course_repository_test.main();
  score_repository_test.main();

  // 运行所有小部件测试
  empty_widget_test.main();
}
