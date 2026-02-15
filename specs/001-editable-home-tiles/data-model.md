# Data Model: 可编辑和可拖动的首页磁贴

**Feature**: Editable Home Tiles
**Date**: 2026-02-15
**Purpose**: Define data structures and relationships for tile configuration management

## Entity Overview

This feature introduces a structured configuration model for home page tiles, replacing the simple string list with a rich configuration object that tracks order and visibility.

## Entities

### TileConfiguration

Represents the configuration for a single tile on the home page.

**Purpose**: Store user preferences for individual tiles including display order and visibility state.

**Fields**:

| Field | Type | Required | Description | Validation Rules |
|-------|------|----------|-------------|------------------|
| id | String | Yes | Unique identifier for the tile (e.g., "电费", "校车", "饭卡") | Non-empty, matches available tile types |
| order | int | Yes | Display order index (0-based) | >= 0, unique within configuration list |
| isVisible | bool | Yes | Whether tile is shown on home page | true or false |

**Relationships**:
- Part of TileConfigurationList (one-to-many)
- Maps to actual tile widget via id field

**State Transitions**:
```
Initial State: { id: "电费", order: 0, isVisible: true }
  ↓ User hides tile
Hidden State: { id: "电费", order: 0, isVisible: false }
  ↓ User shows tile
Visible State: { id: "电费", order: 2, isVisible: true }  // Appended to end
  ↓ User drags to new position
Reordered State: { id: "电费", order: 0, isVisible: true }
```

**Serialization**:
```dart
// To JSON
{
  "id": "电费",
  "order": 0,
  "isVisible": true
}

// From JSON
TileConfiguration.fromJson(Map<String, dynamic> json)
```

**Invariants**:
- id must match one of the available tile types
- order must be unique within the configuration list
- isVisible determines whether tile appears in UI

**Example Instances**:
```dart
// Visible tile at first position
TileConfiguration(id: "电费", order: 0, isVisible: true)

// Hidden tile (order preserved for when re-shown)
TileConfiguration(id: "校车", order: 1, isVisible: false)

// Visible tile at last position
TileConfiguration(id: "饭卡", order: 2, isVisible: true)
```

---

### TileConfigurationList

Represents the complete set of tile configurations for a user.

**Purpose**: Manage the ordered collection of all tile configurations with operations for reordering and visibility toggling.

**Fields**:

| Field | Type | Required | Description | Validation Rules |
|-------|------|----------|-------------|------------------|
| configurations | List<TileConfiguration> | Yes | Ordered list of tile configurations | Non-null, may be empty |
| lastModified | DateTime | Yes | Timestamp of last modification | Valid DateTime |

**Relationships**:
- Contains multiple TileConfiguration instances
- Persisted to shared_preferences as JSON string

**Operations**:

1. **getVisibleTiles()**: Returns list of visible tiles sorted by order
   - Input: None
   - Output: List<TileConfiguration> (filtered and sorted)
   - Validation: None

2. **reorderTile(String tileId, int newOrder)**: Move tile to new position
   - Input: tileId (String), newOrder (int)
   - Output: Updated TileConfigurationList
   - Validation: tileId exists, newOrder >= 0 and < list length
   - Side Effect: Adjusts order of other tiles

3. **toggleVisibility(String tileId)**: Show/hide a tile
   - Input: tileId (String)
   - Output: Updated TileConfigurationList
   - Validation: tileId exists
   - Side Effect: If showing, appends to end; if hiding, preserves order

4. **resetToDefault()**: Restore default configuration
   - Input: None
   - Output: Default TileConfigurationList
   - Validation: None

**Serialization**:
```dart
// To JSON (stored in shared_preferences)
{
  "configurations": [
    {"id": "电费", "order": 0, "isVisible": true},
    {"id": "校车", "order": 1, "isVisible": true},
    {"id": "饭卡", "order": 2, "isVisible": false}
  ],
  "lastModified": "2026-02-15T10:30:00.000Z"
}

// From JSON
TileConfigurationList.fromJson(Map<String, dynamic> json)
```

**Invariants**:
- All order values must be unique among visible tiles
- Order values must be sequential (0, 1, 2, ...) for visible tiles
- At least one tile should be visible (warn user if all hidden)

**Default Configuration**:
```dart
TileConfigurationList.defaultConfig() {
  return TileConfigurationList(
    configurations: [
      TileConfiguration(id: "电费", order: 0, isVisible: true),
      TileConfiguration(id: "校车", order: 1, isVisible: true),
      TileConfiguration(id: "饭卡", order: 2, isVisible: true),
    ],
    lastModified: DateTime.now(),
  );
}
```

---

## Data Flow

### Read Flow (App Startup)
```
1. App starts → TileService.getTileConfigurations()
2. Load from shared_preferences (key: PrefsKeys.TILE_CONFIGURATIONS)
3. Deserialize JSON → TileConfigurationList
4. If null/error → Return default configuration
5. Filter visible tiles → Sort by order
6. Build UI with ordered tiles
```

### Write Flow (User Edits)
```
1. User drags tile → TileEditController.reorderTile(tileId, newIndex)
2. Update TileConfigurationList in memory
3. Serialize to JSON
4. Save to shared_preferences
5. Update UI reactively (GetX)
```

### Migration Flow (First Run After Update)
```
1. Check for old format data (PrefsKeys.TILES - List<String>)
2. If exists:
   a. Load old list
   b. Convert to TileConfigurationList with default order
   c. Save in new format
   d. Delete old key (optional, for cleanup)
3. If not exists:
   a. Use default configuration
```

## Storage Schema

### SharedPreferences Keys

| Key | Type | Description | Example Value |
|-----|------|-------------|---------------|
| PrefsKeys.TILE_CONFIGURATIONS | String (JSON) | Complete tile configuration | See TileConfigurationList JSON above |
| PrefsKeys.TILES (deprecated) | List<String> | Old format, kept for migration | ["电费", "校车", "饭卡"] |

### Storage Size Estimate

```
Single TileConfiguration: ~50 bytes
TileConfigurationList (3 tiles): ~200 bytes
Maximum (10 tiles): ~600 bytes
```

Well within shared_preferences limits and project constraints (<1KB).

## Validation Rules

### At Model Level
- TileConfiguration.id must be non-empty
- TileConfiguration.order must be >= 0
- TileConfiguration.isVisible must be boolean

### At Service Level
- All tile IDs must match available tile types
- No duplicate tile IDs in configuration list
- Order values must be unique among visible tiles
- Order values should be sequential (0, 1, 2, ...) for visible tiles

### At UI Level
- Warn user if attempting to hide all tiles
- Prevent drag operations during save
- Validate order before persisting

## Error Handling

### Deserialization Errors
```dart
try {
  final config = TileConfigurationList.fromJson(json);
  return config;
} catch (e) {
  debugPrint('Failed to load tile configuration: $e');
  return TileConfigurationList.defaultConfig();
}
```

### Storage Errors
```dart
try {
  await prefs.setString(PrefsKeys.TILE_CONFIGURATIONS, jsonEncode(config));
} catch (e) {
  debugPrint('Failed to save tile configuration: $e');
  // UI shows error message, keeps current state
  throw TileConfigurationException('保存失败，请重试');
}
```

### Invalid State Errors
```dart
// All tiles hidden
if (config.getVisibleTiles().isEmpty) {
  // Show warning dialog
  // Prevent save or auto-show last hidden tile
}

// Duplicate orders
if (hasDuplicateOrders(config)) {
  // Recompute orders
  config = config.normalizeOrders();
}
```

## Testing Considerations

### Unit Tests Required
- TileConfiguration serialization/deserialization
- TileConfigurationList operations (reorder, toggle, filter)
- Default configuration generation
- Migration from old format
- Validation rules enforcement

### Test Data
```dart
// Valid configuration
final validConfig = TileConfigurationList(
  configurations: [
    TileConfiguration(id: "电费", order: 0, isVisible: true),
    TileConfiguration(id: "校车", order: 1, isVisible: true),
  ],
  lastModified: DateTime.now(),
);

// Invalid configuration (duplicate orders)
final invalidConfig = TileConfigurationList(
  configurations: [
    TileConfiguration(id: "电费", order: 0, isVisible: true),
    TileConfiguration(id: "校车", order: 0, isVisible: true),  // Duplicate!
  ],
  lastModified: DateTime.now(),
);

// Edge case (all hidden)
final allHiddenConfig = TileConfigurationList(
  configurations: [
    TileConfiguration(id: "电费", order: 0, isVisible: false),
    TileConfiguration(id: "校车", order: 1, isVisible: false),
  ],
  lastModified: DateTime.now(),
);
```

## Performance Considerations

- **Read Performance**: O(n) where n = number of tiles (typically 3-5, negligible)
- **Write Performance**: O(n) serialization + O(1) storage write
- **Memory Footprint**: ~200-600 bytes in memory, minimal impact
- **Reorder Operation**: O(n) to update orders, acceptable for small lists

## Future Extensions (Out of Scope)

- Tile size configuration (1x1, 1x2, 2x2)
- Tile grouping/categories
- Custom tile types
- Cloud sync of configurations
- Configuration versioning for rollback
