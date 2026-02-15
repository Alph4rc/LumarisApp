/// Represents the configuration for a single tile on the home page
class TileConfiguration {
  /// Unique identifier for the tile (e.g., "电费", "校车", "饭卡")
  final String id;

  /// Display order index (0-based)
  final int order;

  /// Whether tile is shown on home page
  final bool isVisible;

  const TileConfiguration({
    required this.id,
    required this.order,
    required this.isVisible,
  });

  /// Create from JSON
  factory TileConfiguration.fromJson(Map<String, dynamic> json) {
    return TileConfiguration(
      id: json['id'] as String,
      order: json['order'] as int,
      isVisible: json['isVisible'] as bool,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'isVisible': isVisible,
    };
  }

  /// Create a copy with modified fields
  TileConfiguration copyWith({
    String? id,
    int? order,
    bool? isVisible,
  }) {
    return TileConfiguration(
      id: id ?? this.id,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileConfiguration &&
        other.id == id &&
        other.order == order &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode => Object.hash(id, order, isVisible);

  @override
  String toString() =>
      'TileConfiguration(id: $id, order: $order, isVisible: $isVisible)';
}

/// Represents the complete set of tile configurations for a user
class TileConfigurationList {
  /// Ordered list of tile configurations
  final List<TileConfiguration> configurations;

  /// Timestamp of last modification
  final DateTime lastModified;

  const TileConfigurationList({
    required this.configurations,
    required this.lastModified,
  });

  /// Create default configuration with all tiles visible
  factory TileConfigurationList.defaultConfig() {
    return TileConfigurationList(
      configurations: [
        const TileConfiguration(id: '电费', order: 0, isVisible: true),
        const TileConfiguration(id: '校车', order: 1, isVisible: true),
        const TileConfiguration(id: '饭卡', order: 2, isVisible: true),
      ],
      lastModified: DateTime.now(),
    );
  }

  /// Create from JSON
  factory TileConfigurationList.fromJson(Map<String, dynamic> json) {
    final configList = (json['configurations'] as List)
        .map((e) => TileConfiguration.fromJson(e as Map<String, dynamic>))
        .toList();

    return TileConfigurationList(
      configurations: configList,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'configurations': configurations.map((e) => e.toJson()).toList(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Get list of visible tiles sorted by order
  List<TileConfiguration> getVisibleTiles() {
    final visible = configurations.where((tile) => tile.isVisible).toList();
    visible.sort((a, b) => a.order.compareTo(b.order));
    return visible;
  }

  /// Reorder a tile to a new position
  TileConfigurationList reorderTile(String tileId, int oldIndex, int newIndex) {
    final visibleTiles = getVisibleTiles();

    if (oldIndex < 0 ||
        oldIndex >= visibleTiles.length ||
        newIndex < 0 ||
        newIndex >= visibleTiles.length) {
      throw ArgumentError('Invalid indices for reordering');
    }

    // Find the tile to move
    final tileToMove = visibleTiles[oldIndex];
    if (tileToMove.id != tileId) {
      throw ArgumentError('Tile ID mismatch at old index');
    }

    // Remove from old position and insert at new position
    visibleTiles.removeAt(oldIndex);
    visibleTiles.insert(newIndex, tileToMove);

    // Update order values for all visible tiles
    for (int i = 0; i < visibleTiles.length; i++) {
      visibleTiles[i] = visibleTiles[i].copyWith(order: i);
    }

    // Merge back with hidden tiles
    final hiddenTiles =
        configurations.where((tile) => !tile.isVisible).toList();
    final newConfigurations = [...visibleTiles, ...hiddenTiles];

    return TileConfigurationList(
      configurations: newConfigurations,
      lastModified: DateTime.now(),
    );
  }

  /// Toggle visibility of a tile
  TileConfigurationList toggleVisibility(String tileId) {
    final tileIndex = configurations.indexWhere((tile) => tile.id == tileId);

    if (tileIndex == -1) {
      throw ArgumentError('Tile not found: $tileId');
    }

    final tile = configurations[tileIndex];
    var newTile = tile.copyWith(isVisible: !tile.isVisible);

    // If showing, append to end of visible tiles
    if (newTile.isVisible) {
      final visibleTiles = getVisibleTiles();
      final maxOrder = visibleTiles.isEmpty
          ? -1
          : visibleTiles.map((t) => t.order).reduce((a, b) => a > b ? a : b);
      newTile = newTile.copyWith(order: maxOrder + 1);
    }

    // Check if all tiles would be hidden
    final newConfigurations = List<TileConfiguration>.from(configurations);
    newConfigurations[tileIndex] = newTile;

    final visibleCount =
        newConfigurations.where((tile) => tile.isVisible).length;
    if (visibleCount == 0) {
      throw StateError('Cannot hide all tiles');
    }

    return TileConfigurationList(
      configurations: newConfigurations,
      lastModified: DateTime.now(),
    );
  }

  /// Normalize order values to be sequential (0, 1, 2, ...)
  TileConfigurationList normalizeOrders() {
    final visibleTiles = getVisibleTiles();

    // Update order values
    for (int i = 0; i < visibleTiles.length; i++) {
      visibleTiles[i] = visibleTiles[i].copyWith(order: i);
    }

    // Merge back with hidden tiles
    final hiddenTiles =
        configurations.where((tile) => !tile.isVisible).toList();
    final newConfigurations = [...visibleTiles, ...hiddenTiles];

    return TileConfigurationList(
      configurations: newConfigurations,
      lastModified: DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  TileConfigurationList copyWith({
    List<TileConfiguration>? configurations,
    DateTime? lastModified,
  }) {
    return TileConfigurationList(
      configurations: configurations ?? this.configurations,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileConfigurationList &&
        _listEquals(other.configurations, configurations) &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode => Object.hash(configurations, lastModified);

  @override
  String toString() =>
      'TileConfigurationList(configurations: $configurations, lastModified: $lastModified)';

  /// Helper to compare lists
  static bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
