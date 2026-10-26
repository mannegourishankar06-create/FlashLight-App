#!/usr/bin/env bash
# Creates the android/ folder (if missing) and adds the permissions the
# flashlight needs. Safe to run more than once.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d android ]; then
  flutter create --platforms=android --project-name flashlight_app .
fi

MANIFEST=android/app/src/main/AndroidManifest.xml

if ! grep -q "android.permission.CAMERA" "$MANIFEST"; then
  sed -i '0,/<manifest[^>]*>/s//&\n    <uses-permission android:name="android.permission.CAMERA"\/>\n    <uses-permission android:name="android.permission.FLASHLIGHT"\/>\n    <uses-feature android:name="android.hardware.camera" android:required="false"\/>\n    <uses-feature android:name="android.hardware.camera.flash" android:required="false"\/>/' "$MANIFEST"
fi

echo "Android setup done. Permissions in $MANIFEST:"
grep -n "uses-permission\|uses-feature" "$MANIFEST"
