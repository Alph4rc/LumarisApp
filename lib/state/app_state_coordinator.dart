import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';

/// Coordinates workflows that cross feature boundaries.
///
/// Feature stores own only their own state and persistence. Reactions between
/// stores are registered here so a feature can evolve without depending on
/// unrelated feature implementations.
final appStateCoordinatorProvider = Provider<void>((ref) {
  ref.listen<List<String>>(
    courseStoreProvider.select((state) => state.ignoreCourses),
    (previous, next) {
      if (previous != null && previous != next) {
        unawaited(ref.read(scheduleStoreProvider.notifier).refreshCourseData());
      }
    },
  );

  ref.listen<int>(
    schoolStoreProvider.select(
      (state) => state.school?.weekStartDay ?? School.defaultWeekStartDay,
    ),
    (previous, next) {
      if (previous != null && previous != next) {
        unawaited(ref.read(scheduleStoreProvider.notifier).initializeData());
      }
    },
  );

  ref.listen<String>(
    settingsStoreProvider.select((state) => state.schoolId),
    (previous, next) {
      if (previous != null && previous != next) {
        unawaited(ref.read(schoolStoreProvider.notifier).fetchSchool(next));
      }
    },
  );

  ref.listen<bool>(
    userStoreProvider.select((state) => state.isLogin),
    (previous, next) {
      if (previous == true && !next) {
        ref.read(courseStoreProvider.notifier).clearCourseData();
        ref.read(scheduleStoreProvider.notifier).clean();
        ref.read(programControllerProvider.notifier).clean();
      }
    },
  );
});
