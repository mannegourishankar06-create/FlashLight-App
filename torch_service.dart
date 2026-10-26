import 'package:torch_light/torch_light.dart';

/// Thin wrapper around the torch_light plugin that remembers the current state
/// and never throws (errors are reported through the return value).
class TorchService {
  bool _on = false;

  bool get isOn => _on;

  Future<bool> isAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Turns the torch on or off. Returns an error message, or null on success.
  Future<String?> set(bool on) async {
    if (on == _on) return null;
    try {
      if (on) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
      _on = on;
      return null;
    } catch (e) {
      return 'Could not control the flashlight. Check the camera permission.';
    }
  }
}
