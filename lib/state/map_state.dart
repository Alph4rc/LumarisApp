import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'map_state.freezed.dart';

@freezed
class CampusPOI with _$CampusPOI {
  const factory CampusPOI({
    required String name,
    required String description,
    required LatLng position,
  }) = _CampusPOI;
}

@freezed
class MapState with _$MapState {
  const factory MapState({
    LatLng? currentLocation,
    @Default(false) bool isLoadingLocation,
    @Default(false) bool isLoadingPOIs,
    @Default(<CampusPOI>[]) List<CampusPOI> campusPOIs,
    @Default('') String searchQuery,
  }) = _MapState;
}
