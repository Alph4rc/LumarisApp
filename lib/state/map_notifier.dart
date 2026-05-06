import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'map_state.dart';

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() {
    return const MapState(
      campusPOIs: [
        CampusPOI(
          name: '主图书馆',
          description: '24小时开放自习室',
          position: LatLng(39.993203, 116.327096),
        ),
        CampusPOI(
          name: '第一教学楼',
          description: '理科及多媒体教室',
          position: LatLng(39.992520, 116.325881),
        ),
        CampusPOI(
          name: '学生食堂',
          description: '风味餐厅与咖啡厅',
          position: LatLng(39.994200, 116.326500),
        ),
      ],
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> checkLocationPermission() async {
    state = state.copyWith(isLoadingLocation: true);

    try {
      final status = await PermissionService.request(Permission.location);
      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited ||
          status == PermissionStatus.provisional) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
          ),
        );
        final gcj02Location =
            _wgs84ToGcj02(position.latitude, position.longitude);
        state = state.copyWith(
          currentLocation: gcj02Location,
          isLoadingLocation: false,
        );
      } else {
        state = state.copyWith(isLoadingLocation: false);
      }
    } catch (e) {
      state = state.copyWith(isLoadingLocation: false);
    }
  }

  // ==========================================
  // 核心纠偏算法：WGS-84 (国际标准) 转 GCJ-02 (火星坐标/高德地图)
  // 用于消除由于设备硬件返回 WGS84 导致的定位在地图上偏移问题
  // ==========================================
  static const double _a = 6378245.0;
  static const double _ee = 0.00669342162296594323;

  LatLng _wgs84ToGcj02(double lat, double lng) {
    if (_outOfChina(lat, lng)) return LatLng(lat, lng);

    double dLat = _transformLat(lng - 105.0, lat - 35.0);
    double dLng = _transformLng(lng - 105.0, lat - 35.0);
    double radLat = lat / 180.0 * math.pi;
    double magic = math.sin(radLat);
    magic = 1 - _ee * magic * magic;
    double sqrtMagic = math.sqrt(magic);
    dLat = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * math.pi);
    dLng = (dLng * 180.0) / (_a / sqrtMagic * math.cos(radLat) * math.pi);

    return LatLng(lat + dLat, lng + dLng);
  }

  bool _outOfChina(double lat, double lng) {
    if (lng < 72.004 || lng > 137.8347) return true;
    if (lat < 0.8293 || lat > 55.8271) return true;
    return false;
  }

  double _transformLat(double x, double y) {
    double ret = -100.0 +
        2.0 * x +
        3.0 * y +
        0.2 * y * y +
        0.1 * x * y +
        0.2 * math.sqrt(x.abs());
    ret += (20.0 * math.sin(6.0 * x * math.pi) +
            20.0 * math.sin(2.0 * x * math.pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(y * math.pi) + 40.0 * math.sin(y / 3.0 * math.pi)) *
        2.0 /
        3.0;
    ret += (160.0 * math.sin(y / 12.0 * math.pi) +
            320 * math.sin(y * math.pi / 30.0)) *
        2.0 /
        3.0;
    return ret;
  }

  double _transformLng(double x, double y) {
    double ret = 300.0 +
        x +
        2.0 * y +
        0.1 * x * x +
        0.1 * x * y +
        0.1 * math.sqrt(x.abs());
    ret += (20.0 * math.sin(6.0 * x * math.pi) +
            20.0 * math.sin(2.0 * x * math.pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(x * math.pi) + 40.0 * math.sin(x / 3.0 * math.pi)) *
        2.0 /
        3.0;
    ret += (150.0 * math.sin(x / 12.0 * math.pi) +
            300.0 * math.sin(x / 30.0 * math.pi)) *
        2.0 /
        3.0;
    return ret;
  }
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
