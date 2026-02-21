import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/system/tile_service.dart';

/// Controller for managing tile edit mode state
class TileEditController extends GetxController {
  /// Whether edit mode is currently active
  final RxBool isEditMode = false.obs;

  /// Whether a tile is currently being dragged
  final RxBool isDragging = false.obs;

  /// Current tile configuration
  final Rx<TileConfigurationList> config =
      TileConfigurationList.defaultConfig().obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Timer for auto-exit after inactivity
  Timer? _inactivityTimer;

  /// Duration of inactivity before auto-exit (30 seconds)
  static const Duration _inactivityDuration = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _loadConfiguration();
  }

  @override
  void onClose() {
    _cancelInactivityTimer();
    super.onClose();
  }

  /// Load tile configuration from storage
  Future<void> _loadConfiguration() async {
    try {
      isLoading.value = true;
      var loadedConfig = await TileService.getTileConfigurations();

      // Merge with available tiles if any are missing
      final availableTiles = TileService.getAvailableTiles();
      final existingIds = loadedConfig.configurations.map((t) => t.id).toSet();
      
      var hasChanges = false;
      var newConfigs = List<TileConfiguration>.from(loadedConfig.configurations);
      
      for (final id in availableTiles) {
        if (!existingIds.contains(id)) {
           // Add missing tile as hidden
           newConfigs.add(TileConfiguration(
             id: id,
             order: newConfigs.length, 
             isVisible: false,
           ));
           hasChanges = true;
        }
      }
      
      if (hasChanges) {
        loadedConfig = loadedConfig.copyWith(configurations: newConfigs);
        // Save back immediately to ensure consistency
        await TileService.saveTileConfigurations(loadedConfig);
      }

      config.value = loadedConfig;
    } catch (e) {
      // Error already logged in TileService
      config.value = TileConfigurationList.defaultConfig();
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle edit mode on/off
  Future<void> toggleEditMode() async {
    if (isEditMode.value) {
      // Exiting edit mode - save changes
      await _saveConfiguration();
      isEditMode.value = false;
      _cancelInactivityTimer();
    } else {
      // Entering edit mode
      isEditMode.value = true;

      // Provide haptic feedback on mobile platforms
      if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
        await HapticFeedback.mediumImpact();
      }

      // Start inactivity timer
      _resetInactivityTimer();
    }
  }

  /// Reorder a tile to a new position
  Future<void> reorderTile(String tileId, int oldIndex, int newIndex) async {
    try {
      // Update local state immediately for responsive UI
      config.value = config.value.reorderTile(tileId, oldIndex, newIndex);

      // Reset inactivity timer
      _resetInactivityTimer();

      // Save will happen on edit mode exit
    } catch (e) {
      // Revert on error
      await _loadConfiguration();
      rethrow;
    }
  }

  /// Toggle visibility of a tile
  Future<void> toggleVisibility(String tileId) async {
    try {
      // Update local state immediately
      config.value = config.value.toggleVisibility(tileId);

      // Provide haptic feedback
      if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
        await HapticFeedback.selectionClick();
      }

      // Reset inactivity timer
      _resetInactivityTimer();

      // Save will happen on edit mode exit
    } catch (e) {
      // Revert on error
      await _loadConfiguration();
      rethrow;
    }
  }

  /// Save current configuration to storage
  Future<void> _saveConfiguration() async {
    try {
      await TileService.saveTileConfigurations(config.value);
    } catch (e) {
      // Error already logged in TileService
      rethrow;
    }
  }

  /// Reset the inactivity timer
  void _resetInactivityTimer() {
    _cancelInactivityTimer();

    if (isEditMode.value) {
      _inactivityTimer = Timer(_inactivityDuration, () {
        // Auto-exit edit mode after inactivity
        if (isEditMode.value) {
          toggleEditMode();
        }
      });
    }
  }

  /// Cancel the inactivity timer
  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Force exit edit mode (called when navigating away)
  Future<void> forceExitEditMode() async {
    if (isEditMode.value) {
      await _saveConfiguration();
      isEditMode.value = false;
      _cancelInactivityTimer();
    }
  }

  /// Get list of visible tiles
  List<TileConfiguration> get visibleTiles => config.value.getVisibleTiles();

  /// Get list of all tiles (visible and hidden)
  List<TileConfiguration> get allTiles => config.value.configurations;

  /// Check if a tile is visible
  bool isTileVisible(String tileId) {
    final tile =
        config.value.configurations.firstWhereOrNull((t) => t.id == tileId);
    return tile?.isVisible ?? false;
  }

  /// Reload configuration from storage
  Future<void> reload() async {
    await _loadConfiguration();
  }

  /// Set dragging state
  void setDragging(bool dragging) {
    isDragging.value = dragging;
  }
}
