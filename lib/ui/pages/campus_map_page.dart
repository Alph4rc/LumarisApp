import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ios_club_app/state/map_notifier.dart';
import 'package:ios_club_app/state/map_state.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';

class CampusMapPage extends ConsumerStatefulWidget {
  const CampusMapPage({super.key});

  @override
  ConsumerState<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends ConsumerState<CampusMapPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // 初始执行定位请求
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).checkLocationPermission();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng loc) {
    _mapController.move(loc, 17.5);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final clubColors = context.clubColors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. 底层：FlutterMap 渲染高德地图
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // 默认视角对准校园
              initialCenter: mapState.campusPOIs.isNotEmpty
                  ? mapState.campusPOIs.first.position
                  : const LatLng(34.2312, 108.9632), // 西建大坐标兜底
              initialZoom: 16.0,
              maxZoom: 19.0,
            ),
            children: [
              // 高德底图瓦片层
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
                  ...mapState.campusPOIs.map((poi) => Marker(
                        point: poi.position,
                        width: 120,
                        height: 50,
                        child: _buildPOIMarker(poi, clubColors),
                      )),
                  // 渲染我的位置
                  if (mapState.currentLocation != null)
                    Marker(
                      point: mapState.currentLocation!,
                      width: 50,
                      height: 50,
                      child: _buildMyLocationMarker(clubColors),
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
            child: _buildFrostedGlassDashboard(mapState, clubColors),
          ),

          // 3. 定位按钮
          Positioned(
            bottom: 48,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: clubColors.cardBackground.withValues(alpha: 0.8),
              elevation: 4,
              shape: const CircleBorder(),
              onPressed: () {
                if (mapState.currentLocation != null) {
                  _moveToLocation(mapState.currentLocation!);
                } else {
                  ref
                      .read(mapNotifierProvider.notifier)
                      .checkLocationPermission();
                }
              },
              child: mapState.isLoadingLocation
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: clubColors.primary,
                      ))
                  : Icon(Icons.my_location, color: clubColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOIMarker(CampusPOI poi, ClubColors colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 4,
              )
            ],
            border: Border.all(
              color: colors.separator.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Text(
            poi.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ),
        Icon(Icons.location_on, color: colors.primary, size: 22),
      ],
    );
  }

  Widget _buildMyLocationMarker(ClubColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary, width: 2),
      ),
      child: Center(
        child: Icon(Icons.circle, color: colors.primary, size: 16),
      ),
    );
  }

  Widget _buildFrostedGlassDashboard(MapState mapState, ClubColors colors) {
    return ClipRRect(
      borderRadius: ClubRadii.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.cardOverlay,
            borderRadius: ClubRadii.card,
            border: Border.all(
              color: colors.separator.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
              )
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
                      color: colors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.map_rounded, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '建大地图',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colors.label,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: mapState.campusPOIs.map((poi) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ActionChip(
                        elevation: 0,
                        backgroundColor: colors.surfaceRaised,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide.none,
                        ),
                        label: Text(
                          poi.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.label,
                          ),
                        ),
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
}
