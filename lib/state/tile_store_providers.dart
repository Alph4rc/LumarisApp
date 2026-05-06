import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls whether tile-backed stores eagerly load their data when first read.
///
/// The app keeps this enabled so home tiles hydrate automatically. Tests can
/// override it to drive loading explicitly without racing an initial microtask.
final tileStoreAutoLoadProvider = Provider<bool>((ref) => true);
