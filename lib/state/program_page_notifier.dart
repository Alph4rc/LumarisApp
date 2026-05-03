import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/features/education/services/program_service.dart';
import 'package:ios_club_app/state/app_states.dart';

final programControllerProvider =
    NotifierProvider<ProgramPageNotifier, ProgramState>(ProgramPageNotifier.new);

class ProgramPageNotifier extends Notifier<ProgramState> {
  int _loadCount = 0;
  final List<String> semesterNames = const [
    '大一上',
    '大一下',
    '大二上',
    '大二下',
    '大三上',
    '大三下',
    '大四上',
    '大四下',
    '大五上',
    '大五下',
    '特殊分组',
  ];

  @override
  ProgramState build() {
    Future<void>.microtask(loadPrograms);
    return const ProgramState();
  }

  List<PlanCourseList> get programs => List.unmodifiable(state.programs);
  bool get isLoading => state.isLoading;
  bool get isError => state.isError;
  String get errorMessage => state.errorMessage;

  Future<void> loadPrograms() async {
    final currentLoadId = ++_loadCount;
    try {
      state = state.copyWith(isLoading: true, isError: false);
      final result = await ProgramService.getPrograms();

      if (currentLoadId != _loadCount) return;

      state = state.copyWith(programs: result);
    } catch (e) {
      if (currentLoadId != _loadCount) return;
      state = state.copyWith(isError: true, errorMessage: e.toString());
    } finally {
      if (currentLoadId == _loadCount) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> refreshPrograms() async {
    await loadPrograms();
  }

  void clean() {
    state = state.copyWith(programs: const []);
  }
}
