#!/bin/bash
# Fix: tray_manager Package.swift declares macOS 10.14 but FlutterFramework requires 10.15.
# SPM enforces that the consumer's platform minimum >= the dependency's minimum, so
# the build fails with "requires minimum platform version 10.15 ... but this target supports 10.14".
# This patch bumps tray_manager's SPM manifest to 10.15 in the pub cache.
# Run this once after `flutter pub get`, or any time you update tray_manager.

PATCH_FILE="$HOME/.pub-cache/hosted/pub.dev/tray_manager-0.5.3/macos/tray_manager/Package.swift"

if [ ! -f "$PATCH_FILE" ]; then
  echo "tray_manager Package.swift not found at: $PATCH_FILE"
  echo "Check if the version is still 0.5.3 in pubspec.lock."
  exit 1
fi

if grep -q '.macOS("10.14")' "$PATCH_FILE"; then
  sed -i '' 's/.macOS("10.14")/.macOS("10.15")/' "$PATCH_FILE"
  echo "✅  Patched tray_manager Package.swift: 10.14 → 10.15"
else
  echo "ℹ️  tray_manager Package.swift already at 10.15 or higher — no change needed."
fi
