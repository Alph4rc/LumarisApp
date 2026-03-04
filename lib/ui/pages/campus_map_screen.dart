import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Dart 3 记录 (Record) 用于定义校园地标
typedef CampusPOI = ({String name, String description, LatLng position});

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final MapController _mapController = MapController();

  // 当前定位与权限状态
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;

  // 预设校园地标 (已经是高德的 GCJ-02 坐标)
  final List<CampusPOI> _campusPOIs = [
    (
      name: '主图书馆',
      description: '24小时开放自习室',
      position: const LatLng(39.993203, 116.327096)
    ),
    (
      name: '第一教学楼',
      description: '理科及多媒体教室',
      position: const LatLng(39.992520, 116.325881)
    ),
    (
      name: '学生食堂',
      description: '风味餐厅与咖啡厅',
      position: const LatLng(39.994200, 116.326500)
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  /// 获取并处理跨平台定位
  Future<void> _checkLocationPermission() async {
    setState(() => _isLoadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // 获取当前原始 WGS-84 坐标
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    // *关键*：将硬件获取的 WGS-84 国际坐标转换为高德的 GCJ-02 坐标
    final gcj02Location = _wgs84ToGcj02(position.latitude, position.longitude);

    setState(() {
      _currentLocation = gcj02Location;
      _isLoadingLocation = false;
    });

    _moveToLocation(gcj02Location);
  }

  void _moveToLocation(LatLng loc) {
    _mapController.move(loc, 17.5);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. 底层：FlutterMap 渲染高德地图
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // 默认视角对准校园
              initialCenter: _campusPOIs.first.position,
              initialZoom: 16.0,
              maxZoom: 19.0,
            ),
            children: [
              // 高德底图瓦片层 (支持国内快速加载与正常显示)
              TileLayer(
                urlTemplate:
                    'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                subdomains: const ['1', '2', '3', '4'],
                maxZoom: 19,
              ),
              // 地标及当前定位图层
              MarkerLayer(
                markers: [
                  // 渲染校园建筑标识
                  ..._campusPOIs.map((poi) => Marker(
                        point: poi.position,
                        width: 120,
                        height: 50,
                        child: _buildPOIMarker(poi),
                      )),
                  // 渲染我的位置
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: _buildMyLocationMarker(),
                    )
                ],
              ),
            ],
          ),

          // 2. 顶层：毛玻璃导航面板
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildFrostedGlassDashboard(isDarkMode),
          ),

          // 3. 定位按钮
          Positioned(
            bottom: 48,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: isDarkMode
                  ? Colors.black54.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.7),
              elevation: 8,
              onPressed: () {
                if (_currentLocation != null) {
                  _moveToLocation(_currentLocation!);
                } else {
                  _checkLocationPermission();
                }
              },
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOIMarker(CampusPOI poi) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(
            poi.name,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
        ),
        const Icon(Icons.location_on, color: Colors.blueAccent, size: 22),
      ],
    );
  }

  Widget _buildMyLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.circle, color: Colors.blue, size: 16),
      ),
    );
  }

  Widget _buildFrostedGlassDashboard(bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black54.withOpacity(0.3)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child:
                        const Icon(Icons.map_rounded, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '建大地图',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _campusPOIs.map((poi) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ActionChip(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        label: Text(poi.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        onPressed: () => _moveToLocation(poi.position),
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
