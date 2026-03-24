import 'package:ios_club_app/features/education/models/exam_result.dart';
import 'package:ios_club_app/features/education/services/exam_service.dart'
    as education_exam_service;

/// 兼容层，勿新增逻辑。
@Deprecated('Use features/education/services/exam_service.dart instead.')
class ExamService {
  static Future<ExamResult> getExam({bool isRefresh = false}) {
    return education_exam_service.ExamService.getExamResult(
      isRefresh: isRefresh,
    );
  }
}
