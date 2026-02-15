# TileService API Contract

**Feature**: Editable Home Tiles
**Date**: 2026-02-15
**Purpose**: Define the service layer API for tile configuration management

## Overview

The TileService provides methods for managing home page tile configurations, including loading, saving, reordering, and visibility toggling. This contract extends the existing TileService with new methods while maintaining backward compatibility.

## Service Class: TileService

**Location**: `lib/features/system/tile_service.dart`

**Responsibilities**:
- Load and save tile configurations from/to local storage
- Provide CRUD operations for tile configurations
- Handle migration from old format to new format
- Maintain backward compatibility with existing code

---

## Methods

### getTileConfigurations()

Load the complete tile configuration from local storage.

**Signature**:
```dart
static Future<TileConfigurationList> getTileConfigurations()
```

**Parameters**: None

**Returns**: `Future<TileConfigurationList>`
- On success: Returns TileConfigurationList with user's saved configuration
- On first run: Returns default configuration
- On error: Returns default configuration and logs error

**Behavior**:
1. Load JSON string from shared_preferences (key: PrefsKeys.TILE_CONFIGURATIONS)
2. If not found, check for old format (PrefsKeys.TILES)
3. If old format exists, migrate to new format
4. If no data exists, return default configuration
5. Deserialize JSON to TileConfigurationList
6. Validate configuration (check for duplicates, invalid IDs)
7. Return configuration

**Error Handling**:
- JSON parse error → Return default configuration
- Invalid tile IDs → Filter out invalid tiles
- Duplicate orders → Normalize orders
- Storage error → Log and return default

**Example Usage**:
```dart
final config = await TileService.getTileConfigurations();
final visibleTiles = config.getVisibleTiles();
// Build UI with visibleTiles
```

**Performance**: O(n) where n = number of tiles, typically <10ms

---

### saveTileConfigurations()

Save the complete tile configuration to local storage.

**Signature**:
```dart
static Future<void> saveTileConfigurations(TileConfigurationList config)
```

**Parameters**:
- `config` (TileConfigurationList): The configuration to save

**Returns**: `Future<void>`
- Completes successfully on save
- Throws TileConfigurationException on error

**Behavior**:
1. Validate configuration (no duplicates, valid IDs)
2. Update lastModified timestamp
3. Serialize to JSON
4. Save to shared_preferences (key: PrefsKeys.TILE_CONFIGURATIONS)
5. Complete future

**Error Handling**:
- Validation error → Throw TileConfigurationException with details
- Storage error → Throw TileConfigurationException
- All errors logged with debugPrint

**Example Usage**:
```dart
try {
  await TileService.saveTileConfigurations(updatedConfig);
  // Show success feedback
} catch (e) {
  // Show error message to user
  showErrorSnackBar('保存失败，请重试');
}
```

**Performance**: O(n) serialization + O(1) storage, typically <50ms

---

### reorderTile()

Move a tile to a new position in the display order.

**Signature**:
```dart
static Future<void> reorderTile(String tileId, int oldIndex, int newIndex)
```

**Parameters**:
- `tileId` (String): ID of the tile to reorder
- `oldIndex` (int): Current index in visible tiles list
- `newIndex` (int): Target index in visible tiles list

**Returns**: `Future<void>`
- Completes successfully after reordering and saving
- Throws TileConfigurationException on error

**Behavior**:
1. Load current configuration
2. Find tile by ID
3. Validate indices (>= 0, < visible tiles count)
4. Remove tile from old position
5. Insert tile at new position
6. Recalculate order values for all visible tiles
7. Save updated configuration
8. Complete future

**Error Handling**:
- Tile not found → Throw TileConfigurationException
- Invalid index → Throw TileConfigurationException
- Storage error → Throw TileConfigurationException

**Example Usage**:
```dart
// User drags "电费" from position 0 to position 2
await TileService.reorderTile("电费", 0, 2);
// Order updates: [校车:0, 饭卡:1, 电费:2]
```

**Performance**: O(n) where n = number of visible tiles, typically <20ms

---

### toggleTileVisibility()

Show or hide a tile.

**Signature**:
```dart
static Future<void> toggleTileVisibility(String tileId)
```

**Parameters**:
- `tileId` (String): ID of the tile to toggle

**Returns**: `Future<void>`
- Completes successfully after toggling and saving
- Throws TileConfigurationException on error

**Behavior**:
1. Load current configuration
2. Find tile by ID
3. Toggle isVisible flag
4. If showing: Append to end of visible tiles (highest order)
5. If hiding: Preserve order for when re-shown
6. Validate: Warn if all tiles would be hidden
7. Save updated configuration
8. Complete future

**Error Handling**:
- Tile not found → Throw TileConfigurationException
- All tiles hidden → Throw TileConfigurationException with warning
- Storage error → Throw TileConfigurationException

**Example Usage**:
```dart
// Hide "电费" tile
await TileService.toggleTileVisibility("电费");
// isVisible: true → false

// Show "电费" tile again
await TileService.toggleTileVisibility("电费");
// isVisible: false → true, appended to end
```

**Performance**: O(n) where n = number of tiles, typically <20ms

---

### resetToDefault()

Reset tile configuration to default state.

**Signature**:
```dart
static Future<void> resetToDefault()
```

**Parameters**: None

**Returns**: `Future<void>`
- Completes successfully after resetting and saving

**Behavior**:
1. Create default TileConfigurationList
2. Save to storage
3. Complete future

**Error Handling**:
- Storage error → Throw TileConfigurationException

**Example Usage**:
```dart
// User requests reset in settings
await TileService.resetToDefault();
// All tiles visible in default order
```

**Performance**: O(1), typically <10ms

---

### getAvailableTiles()

Get list of all available tile types (for edit mode UI).

**Signature**:
```dart
static List<String> getAvailableTiles()
```

**Parameters**: None

**Returns**: `List<String>`
- List of all available tile IDs

**Behavior**:
1. Return hardcoded list of available tile types
2. In future, could be dynamic based on user permissions

**Example Usage**:
```dart
final available = TileService.getAvailableTiles();
// ["电费", "校车", "饭卡"]
```

**Performance**: O(1), immediate

---

## Backward Compatibility

### Existing Methods (Preserved)

These methods remain unchanged for backward compatibility:

```dart
// Existing method - returns simple string list
static Future<List<String>> getTiles() async {
  // Implementation unchanged
  // Used by old code that hasn't migrated yet
}

// Existing method - saves simple string list
static Future<void> setTiles(List<String> map) async {
  // Implementation unchanged
  // Used by old code that hasn't migrated yet
}
```

**Migration Path**:
1. New code uses `getTileConfigurations()` and `saveTileConfigurations()`
2. Old code continues using `getTiles()` and `setTiles()`
3. Both formats coexist during transition
4. Eventually deprecate old methods

---

## Data Migration

### Migration Strategy

When `getTileConfigurations()` is called for the first time:

```dart
static Future<TileConfigurationList> getTileConfigurations() async {
  final prefs = PrefsService.instance;

  // Try new format first
  final newFormatJson = prefs.getString(PrefsKeys.TILE_CONFIGURATIONS);
  if (newFormatJson != null) {
    try {
      return TileConfigurationList.fromJson(jsonDecode(newFormatJson));
    } catch (e) {
      debugPrint('Failed to parse new format: $e');
    }
  }

  // Fall back to old format
  final oldFormatList = prefs.getStringList(PrefsKeys.TILES);
  if (oldFormatList != null && oldFormatList.isNotEmpty) {
    // Migrate to new format
    final config = _migrateFromOldFormat(oldFormatList);
    await saveTileConfigurations(config);  // Save in new format
    return config;
  }

  // No data, return default
  return TileConfigurationList.defaultConfig();
}

static TileConfigurationList _migrateFromOldFormat(List<String> oldList) {
  final configurations = oldList.asMap().entries.map((entry) {
    return TileConfiguration(
      id: entry.value,
      order: entry.key,
      isVisible: true,
    );
  }).toList();

  return TileConfigurationList(
    configurations: configurations,
    lastModified: DateTime.now(),
  );
}
```

---

## Error Types

### TileConfigurationException

Custom exception for tile configuration errors.

```dart
class TileConfigurationException implements Exception {
  final String message;
  final String? details;

  TileConfigurationException(this.message, {this.details});

  @override
  String toString() => 'TileConfigurationException: $message${details != null ? ' ($details)' : ''}';
}
```

**Usage**:
```dart
throw TileConfigurationException(
  '无法保存磁贴配置',
  details: 'Storage write failed: $error',
);
```

---

## Testing Contract

### Unit Tests Required

1. **getTileConfigurations()**
   - Returns default on first run
   - Loads saved configuration correctly
   - Migrates from old format
   - Handles parse errors gracefully

2. **saveTileConfigurations()**
   - Saves valid configuration
   - Throws on invalid configuration
   - Updates lastModified timestamp

3. **reorderTile()**
   - Reorders tiles correctly
   - Updates order values
   - Throws on invalid indices
   - Persists changes

4. **toggleTileVisibility()**
   - Toggles visibility correctly
   - Appends to end when showing
   - Preserves order when hiding
   - Warns on all hidden

5. **resetToDefault()**
   - Resets to default configuration
   - Persists reset

6. **Migration**
   - Migrates old format correctly
   - Handles missing data
   - Handles corrupt data

### Mock Data

```dart
// Valid configuration
final mockConfig = TileConfigurationList(
  configurations: [
    TileConfiguration(id: "电费", order: 0, isVisible: true),
    TileConfiguration(id: "校车", order: 1, isVisible: true),
    TileConfiguration(id: "饭卡", order: 2, isVisible: false),
  ],
  lastModified: DateTime(2026, 2, 15),
);

// Old format data
final mockOldFormat = ["电费", "校车", "饭卡"];
```

---

## Performance Requirements

| Operation | Target | Measured |
|-----------|--------|----------|
| getTileConfigurations() | <50ms | TBD |
| saveTileConfigurations() | <100ms | TBD |
| reorderTile() | <50ms | TBD |
| toggleTileVisibility() | <50ms | TBD |
| resetToDefault() | <20ms | TBD |

All operations must complete within target times on mid-range devices (e.g., iPhone 11, Samsung Galaxy A52).

---

## Integration with GetX

The TileService is stateless and called by GetX controllers:

```dart
class TileEditController extends GetxController {
  final Rx<TileConfigurationList> config = TileConfigurationList.defaultConfig().obs;

  @override
  void onInit() {
    super.onInit();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    config.value = await TileService.getTileConfigurations();
  }

  Future<void> reorderTile(String tileId, int oldIndex, int newIndex) async {
    await TileService.reorderTile(tileId, oldIndex, newIndex);
    await _loadConfiguration();  // Reload to update UI
  }

  Future<void> toggleVisibility(String tileId) async {
    await TileService.toggleTileVisibility(tileId);
    await _loadConfiguration();  // Reload to update UI
  }
}
```

---

## Security Considerations

- No sensitive data stored (only tile IDs and order)
- Local storage only (no network transmission)
- No authentication required
- Input validation prevents injection attacks
- Graceful degradation on storage errors

---

## Future Enhancements (Out of Scope)

- Batch operations (reorder multiple tiles at once)
- Undo/redo support
- Configuration export/import
- Cloud sync
- Tile configuration versioning
- Analytics tracking for tile usage
