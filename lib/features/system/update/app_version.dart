import 'package:package_info_plus/package_info_plus.dart';

class AppVersion implements Comparable<AppVersion> {
  AppVersion({
    required this.segments,
    required this.buildNumber,
    required this.isBeta,
    required this.rawValue,
  });

  final List<int> segments;
  final int buildNumber;
  final bool isBeta;
  final String rawValue;

  static final RegExp _pattern = RegExp(
    r'^\s*(beta\s+)?(\d+(?:\.\d+)*)(?:\+(\d+))?\s*$',
    caseSensitive: false,
  );

  static AppVersion? tryParse(String raw) {
    final match = _pattern.firstMatch(raw);
    if (match == null) {
      return null;
    }

    final segmentSource = match.group(2);
    if (segmentSource == null || segmentSource.isEmpty) {
      return null;
    }

    final segments =
        segmentSource.split('.').map(int.tryParse).whereType<int>().toList();
    if (segments.isEmpty) {
      return null;
    }

    return AppVersion(
      segments: segments,
      buildNumber: int.tryParse(match.group(3) ?? '') ?? 0,
      isBeta: match.group(1) != null,
      rawValue: raw.trim(),
    );
  }

  factory AppVersion.fromPackageInfo(PackageInfo packageInfo) {
    final versionText = packageInfo.buildNumber.trim().isEmpty
        ? packageInfo.version
        : '${packageInfo.version}+${packageInfo.buildNumber}';

    return AppVersion.tryParse(versionText) ??
        AppVersion(
          segments: packageInfo.version
              .split('.')
              .map(int.tryParse)
              .whereType<int>()
              .toList(),
          buildNumber: int.tryParse(packageInfo.buildNumber) ?? 0,
          isBeta: false,
          rawValue: versionText,
        );
  }

  @override
  int compareTo(AppVersion other) {
    final maxLength = segments.length > other.segments.length
        ? segments.length
        : other.segments.length;

    for (var i = 0; i < maxLength; i++) {
      final current = i < segments.length ? segments[i] : 0;
      final target = i < other.segments.length ? other.segments[i] : 0;
      if (current != target) {
        return current.compareTo(target);
      }
    }

    if (buildNumber != other.buildNumber) {
      return buildNumber.compareTo(other.buildNumber);
    }

    if (isBeta == other.isBeta) {
      return 0;
    }

    return isBeta ? -1 : 1;
  }

  bool isNewerThan(AppVersion other) => compareTo(other) > 0;
}
