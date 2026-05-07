import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final TextEditingController _searchController;
  CampusPOI? _selectedPOI;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isSidebarOpen = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapNotifierProvider.notifier).checkLocationPermission();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _moveToLocation(LatLng loc, {double zoom = 17.5}) {
    _mapController.move(loc, zoom);
    HapticFeedback.lightImpact();
  }

  void _onPOITap(CampusPOI poi) {
    setState(() {
      _selectedPOI = poi;
    });
    _moveToLocation(poi.position);
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.35,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final clubColors = context.clubColors;
    final padding = MediaQuery.of(context).padding;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Listen for location changes to auto-center once
    ref.listen(mapNotifierProvider.select((s) => s.currentLocation),
        (previous, next) {
      if (previous == null && next != null) {
        _moveToLocation(next);
      }
    });

    final filteredPOIs = mapState.searchQuery.isEmpty
        ? mapState.campusPOIs
        : mapState.campusPOIs
            .where((poi) =>
                poi.name
                    .toLowerCase()
                    .contains(mapState.searchQuery.toLowerCase()) ||
                poi.description
                    .toLowerCase()
                    .contains(mapState.searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final effectiveSidebarOpen = isWide && _isSidebarOpen;

          return Stack(
            children: [
              // 1. Map Layer (Now always full screen)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapState.campusPOIs.isNotEmpty
                      ? mapState.campusPOIs.first.position
                      : const LatLng(34.2312, 108.9632),
                  initialZoom: 16.0,
                  maxZoom: 19.0,
                  onTap: (_, __) {
                    setState(() => _selectedPOI = null);
                    _sheetController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                    );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                    subdomains: const ['1', '2', '3', '4'],
                    maxZoom: 19,
                    tileBuilder: isDarkMode
                        ? (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                -1, 0, 0, 0, 255, // R
                                0, -1, 0, 0, 255, // G
                                0, 0, -1, 0, 255, // B
                                0, 0, 0, 1, 0, // A
                              ]),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  clubColors.primary.withValues(alpha: 0.05),
                                  BlendMode.colorBurn,
                                ),
                                child: tileWidget,
                              ),
                            );
                          }
                        : null,
                  ),
                  MarkerLayer(
                    markers: [
                      ...filteredPOIs.map((poi) => Marker(
                            point: poi.position,
                            width: 120,
                            height: 60,
                            child: GestureDetector(
                              onTap: () => _onPOITap(poi),
                              child: _buildPOIMarker(
                                  poi, clubColors, _selectedPOI == poi),
                            ),
                          )),
                      if (mapState.currentLocation != null)
                        Marker(
                          point: mapState.currentLocation!,
                          width: 60,
                          height: 60,
                          child: _buildMyLocationMarker(clubColors),
                        )
                    ],
                  ),
                ],
              ),

              // 2. Search & Categories Panel (Top - Mobile Only)
              if (!isWide)
                Positioned(
                  top: padding.top + 12,
                  left: 16,
                  right: 16,
                  child: _buildFloatingTopPanel(
                      mapState, clubColors, filteredPOIs),
                ),

              // 3. Wide Screen Sidebar (Animated Floating)
              if (isWide)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  top: padding.top + 20,
                  left: effectiveSidebarOpen ? 20 : -320,
                  bottom: 20,
                  width: 320,
                  child: _buildSidebar(mapState, clubColors, filteredPOIs),
                ),

              // 4. Sidebar Toggle Button (Wide Screen Only - Adjust position based on sidebar)
              if (isWide)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  top: padding.top + 20,
                  left: effectiveSidebarOpen ? 350 : 20,
                  child: _buildSidebarToggle(clubColors),
                ),

              // 5. Map Controls (Right)
              Positioned(
                bottom: isWide ? 40 : 120,
                right: 16,
                child: _buildMapControls(mapState, clubColors),
              ),

              // 6. Bottom Sheet (Mobile)
              if (!isWide) _buildPOIBottomSheet(clubColors),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebarToggle(ClubColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardOverlay,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.separator.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: Icon(
              _isSidebarOpen
                  ? Icons.chevron_left_rounded
                  : Icons.menu_open_rounded,
              color: colors.label,
            ),
            onPressed: _toggleSidebar,
          ),
        ),
      ),
    );
  }

  Widget _buildPOIMarker(CampusPOI poi, ClubColors colors, bool isSelected) {
    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: isSelected
                    ? colors.onAccent
                    : colors.separator.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              poi.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? colors.onAccent : colors.label,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            Icons.location_on_rounded,
            color: isSelected
                ? colors.primary
                : colors.primary.withValues(alpha: 0.7),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMyLocationMarker(ClubColors colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: colors.onAccent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingTopPanel(
      MapState mapState, ClubColors colors, List<CampusPOI> filteredPOIs) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: ClubRadii.card,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.cardOverlay,
                borderRadius: ClubRadii.card,
                border: Border.all(
                  color: colors.separator.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: colors.secondaryLabel),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref
                            .read(mapNotifierProvider.notifier)
                            .updateSearchQuery(value);
                      },
                      style: TextStyle(
                        color: colors.label,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '搜索地点或建筑...',
                        hintStyle: TextStyle(
                          color: colors.tertiaryLabel,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        suffixIcon: mapState.searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  ref
                                      .read(mapNotifierProvider.notifier)
                                      .updateSearchQuery('');
                                },
                                child: Icon(Icons.clear_rounded,
                                    color: colors.secondaryLabel, size: 18),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.map_rounded,
                        color: colors.primary, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filteredPOIs.map((poi) {
              final isSelected = _selectedPOI == poi;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(poi.name),
                  selected: isSelected,
                  onSelected: (_) => _onPOITap(poi),
                  backgroundColor: colors.cardOverlay,
                  selectedColor: colors.primarySoft,
                  labelStyle: TextStyle(
                    color: isSelected ? colors.primary : colors.label,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : colors.separator.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  showCheckmark: false,
                  elevation: 0,
                  pressElevation: 0,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControls(MapState mapState, ClubColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom Controls
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44,
              decoration: BoxDecoration(
                color: colors.cardOverlay,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.separator.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlItem(
                    icon: Icons.add_rounded,
                    onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1),
                    colors: colors,
                  ),
                  Divider(
                      height: 1,
                      color: colors.separator.withValues(alpha: 0.1)),
                  _buildControlItem(
                    icon: Icons.remove_rounded,
                    onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1),
                    colors: colors,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Location Control
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.cardOverlay,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.separator.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: _buildControlItem(
                icon: mapState.isLoadingLocation
                    ? Icons.hourglass_empty_rounded
                    : Icons.my_location_rounded,
                onTap: () {
                  if (mapState.currentLocation != null) {
                    _moveToLocation(mapState.currentLocation!);
                  } else {
                    ref
                        .read(mapNotifierProvider.notifier)
                        .checkLocationPermission();
                  }
                },
                colors: colors,
                iconColor: mapState.currentLocation != null
                    ? colors.primary
                    : colors.label,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required VoidCallback onTap,
    required ClubColors colors,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: iconColor ?? colors.secondaryLabel,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(
      MapState mapState, ClubColors colors, List<CampusPOI> filteredPOIs) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: ClubRadii.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? colors.cardBackground.withValues(alpha: 0.8)
                : colors.cardOverlay.withValues(alpha: 0.7),
            borderRadius: ClubRadii.card,
            border: Border.all(
              color: colors.separator.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              color: colors.secondaryLabel, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                ref
                                    .read(mapNotifierProvider.notifier)
                                    .updateSearchQuery(value);
                              },
                              style: TextStyle(
                                color: colors.label,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '搜索...',
                                hintStyle: TextStyle(
                                  color: colors.secondaryLabel,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: mapState.searchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          ref
                                              .read(
                                                  mapNotifierProvider.notifier)
                                              .updateSearchQuery('');
                                        },
                                        child: Icon(Icons.clear_rounded,
                                            color: colors.secondaryLabel,
                                            size: 18),
                                      )
                                    : null,
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                    height: 1, color: colors.separator.withValues(alpha: 0.2)),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: filteredPOIs.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(
                        height: 1,
                        color: colors.separator.withValues(alpha: 0.1)),
                  ),
                  itemBuilder: (context, index) {
                    final poi = filteredPOIs[index];
                    final isSelected = _selectedPOI == poi;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.primarySoft.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: isSelected ? colors.onAccent : colors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        poi.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? colors.primary : colors.label,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          poi.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13, color: colors.secondaryLabel),
                        ),
                      ),
                      onTap: () => _onPOITap(poi),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPOIBottomSheet(ClubColors colors) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0,
      minChildSize: 0,
      maxChildSize: 0.6,
      snap: true,
      builder: (context, scrollController) {
        if (_selectedPOI == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.separator.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _selectedPOI!.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colors.label,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.directions_rounded,
                        color: colors.onAccent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoSection(
                title: '建筑介绍',
                content: _selectedPOI!.description,
                icon: Icons.info_outline_rounded,
                colors: colors,
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                title: '具体位置',
                content:
                    '${_selectedPOI!.position.latitude.toStringAsFixed(6)}, ${_selectedPOI!.position.longitude.toStringAsFixed(6)}',
                icon: Icons.map_outlined,
                colors: colors,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    required ClubColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.secondaryLabel),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: colors.label,
            ),
          ),
        ],
      ),
    );
  }
}
