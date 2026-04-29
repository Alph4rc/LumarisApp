import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/auth_state_notifier.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';

/// Eagerly initializes app-wide providers that used to live in the GetX
/// service container.
void initStores(WidgetRef ref) {
  ref.read(settingsStoreProvider);
  ref.read(authStateNotifierProvider);
  ref.read(userStoreProvider);
  ref.read(courseStoreProvider);
  ref.read(scheduleStoreProvider);
  ref.read(electricityStoreProvider);
  ref.read(paymentStoreProvider);
  ref.read(busTileStoreProvider);
  ref.read(tileEditControllerProvider);
}
