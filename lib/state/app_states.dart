import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';

part 'app_states.freezed.dart';

enum AuthState {
  normal,
  relogging,
  relogSuccess,
  relogFailed,
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isRemind,
    @Default(15) int remindTime,
    @Default(false) bool isShowTomorrow,
    @Default(0) int pageIndex,
    @Default(false) bool enableHapticFeedback,
    @Default(false) bool updateIgnored,
    @Default('') String fontFamily,
    @Default(false) bool showCourseGrid,
    @Default(false) bool todoRemindEnabled,
    @Default('') String scheduleBackground,
    @Default('') String customBackgroundImage,
    bool? customBackgroundIsDark,
    @Default(ApiConfig.defaultSchoolId) String schoolId,
    @Default(false) bool hasAcceptedAgreement,
  }) = _SettingsState;
}

@freezed
class UserState with _$UserState {
  const factory UserState({
    @Default(false) bool isLogin,
    UserData? userData,
  }) = _UserState;
}

@freezed
class CourseState with _$CourseState {
  const factory CourseState({
    @Default(<CourseModel>[]) List<CourseModel> courses,
    @Default(<String>[]) List<String> ignoreCourses,
  }) = _CourseState;
}

@freezed
class ScheduleState with _$ScheduleState {
  const factory ScheduleState({
    @Default(<List<CourseModel>>[]) List<List<CourseModel>> allCourses,
    @Default(true) bool isLoading,
    @Default(0) int maxWeek,
    @Default(0) int currentWeek,
    @Default(0) int currentPage,
    @Default(55.0) double height,
    @Default(false) bool isYanTa,
    @Default(false) bool showTomorrow,
    @Default(0) int weekNow,
  }) = _ScheduleState;
}

@freezed
class ElectricityState with _$ElectricityState {
  const factory ElectricityState({
    @Default(true) bool isLoading,
    @Default(false) bool hasData,
    @Default(0.0) double electricity,
    @Default(<String>[]) List<String> tiles,
    @Default(<ElectricData>[]) List<ElectricData> weeklyData,
  }) = _ElectricityState;
}

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState({
    @Default(true) bool isLoading,
    @Default('') String errorMessage,
    @Default(<PaymentModel>[]) List<PaymentModel> records,
    @Default(0.0) double totalRecharge,
    @Default(false) bool isShowTile,
  }) = _PaymentState;
}

@freezed
class BusTileState with _$BusTileState {
  const factory BusTileState({
    @Default(true) bool isLoading,
    @Default(0) int busCount,
    @Default(false) bool useNewApi,
  }) = _BusTileState;
}

@freezed
class TileEditState with _$TileEditState {
  const factory TileEditState({
    @Default(false) bool isEditMode,
    required TileConfigurationList config,
    @Default(false) bool isLoading,
  }) = _TileEditState;
}

@freezed
class AuthStateView with _$AuthStateView {
  const factory AuthStateView({
    @Default(AuthState.normal) AuthState authState,
    @Default('') String relogMessage,
  }) = _AuthStateView;
}

@freezed
class BaseStoreState with _$BaseStoreState {
  const factory BaseStoreState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
  }) = _BaseStoreState;
}

@freezed
class ProgramState with _$ProgramState {
  const factory ProgramState({
    @Default(<PlanCourseList>[]) List<PlanCourseList> programs,
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    @Default('') String errorMessage,
  }) = _ProgramState;
}

@freezed
class BusPageState with _$BusPageState {
  const factory BusPageState({
    @Default('') String selectedDate,
    @Default(<BusItem>[]) List<BusItem> busData,
    @Default(<BusItem>[]) List<BusItem> todayBusData,
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
    @Default(true) bool isCaoTang,
    @Default(false) bool isShowBus,
    @Default(false) bool useNewApi,
    @Default(<String>[]) List<String> tiles,
  }) = _BusPageState;
}
