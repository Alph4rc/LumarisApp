import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/system/permissions/course_feature_permissions.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('CourseFeaturePermissions', () {
    test('should_require_notification_and_alarm_for_reminders', () {
      expect(
        CourseFeaturePermissions.requiredFor(CourseFeaturePermission.reminder),
        [
          Permission.notification,
          Permission.scheduleExactAlarm,
          Permission.ignoreBatteryOptimizations,
        ],
      );
    });

    test('should_require_background_execution_for_widgets', () {
      expect(
        CourseFeaturePermissions.requiredFor(CourseFeaturePermission.widget),
        [Permission.ignoreBatteryOptimizations],
      );
    });

    test('should_treat_limited_and_provisional_as_granted', () {
      expect(
        CourseFeaturePermissions.isGranted(PermissionStatus.granted),
        isTrue,
      );
      expect(
        CourseFeaturePermissions.isGranted(PermissionStatus.limited),
        isTrue,
      );
      expect(
        CourseFeaturePermissions.isGranted(PermissionStatus.provisional),
        isTrue,
      );
      expect(
        CourseFeaturePermissions.isGranted(PermissionStatus.denied),
        isFalse,
      );
      expect(
        CourseFeaturePermissions.isGranted(PermissionStatus.permanentlyDenied),
        isFalse,
      );
    });

    test('should_only_report_all_granted_when_list_is_not_empty', () {
      expect(CourseFeaturePermissions.allGranted(const []), isFalse);
      expect(
        CourseFeaturePermissions.allGranted(const [
          PermissionStatus.granted,
          PermissionStatus.limited,
        ]),
        isTrue,
      );
      expect(
        CourseFeaturePermissions.allGranted(const [
          PermissionStatus.granted,
          PermissionStatus.denied,
        ]),
        isFalse,
      );
    });

    test('should_count_granted_permissions', () {
      expect(
        CourseFeaturePermissions.grantedCount(const [
          PermissionStatus.granted,
          PermissionStatus.denied,
          PermissionStatus.provisional,
        ]),
        2,
      );
    });
  });
}
