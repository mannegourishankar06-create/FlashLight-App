# Flashlight (Flutter)

A simple flashlight app with:

- Big power button (tap to turn the LED torch on/off)
- Strobe mode with a speed slider
- SOS mode (Morse code ... --- ...)
- Screen light: use the display as a lamp, tap to change colour

Uses the [`torch_light`](https://pub.dev/packages/torch_light) plugin. Android only.

## Build the APK on your computer

1. Install Flutter (https://docs.flutter.dev/get-started/install) and Android Studio
   (for the Android SDK). Run `flutter doctor` and fix anything it flags.
2. In a terminal, inside this folder:

```bash
bash tools/setup_android.sh      # creates android/ and adds the flashlight permissions
flutter pub get
flutter run                      # optional: test on a real phone (emulators have no torch)
flutter build apk --release
```

On Windows, run the script from Git Bash, or do it by hand: run
`flutter create --platforms=android --project-name flashlight_app .`, then add these
lines inside `<manifest>` in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.FLASHLIGHT"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.camera.flash" android:required="false"/>
```

3. The APK is at `build/app/outputs/flutter-apk/app-release.apk`. Copy it to your
   phone and install it (allow "install unknown apps" when asked).

## Build without installing anything (GitHub Actions)

1. Push this folder to a new GitHub repository (branch `main`).
2. Open the **Actions** tab, pick **Build APK** and click **Run workflow**.
3. Download `flashlight-apk` from the run's **Artifacts** section.

## Notes

- Test on a real phone: emulators have no flashlight hardware.
- On first use, Android may ask for camera permission. The flashlight is part of the
  camera hardware, and the app never takes pictures.
- The release APK is signed with the debug key, fine for demos. For the Play Store,
  create your own keystore: https://docs.flutter.dev/deployment/android
