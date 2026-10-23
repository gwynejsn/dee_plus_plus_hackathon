import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SoundHapticsService {
  static final SoundHapticsService _instance = SoundHapticsService._internal();
  factory SoundHapticsService() => _instance;
  SoundHapticsService._internal();

  final ValueNotifier<bool> soundEnabledNotifier = ValueNotifier<bool>(true);

  bool get isSoundEnabled => soundEnabledNotifier.value;

  void toggleSound() {
    soundEnabledNotifier.value = !soundEnabledNotifier.value;
  }

  // Trigger almost-next alert (vibration + system sound)
  Future<void> triggerAlmostNextFeedback() async {
    if (!isSoundEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  // Trigger now-serving alert
  Future<void> triggerNowServingFeedback() async {
    if (!isSoundEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  // Soft tap
  Future<void> triggerTapFeedback() async {
    if (!isSoundEnabled) return;
    try {
      await HapticFeedback.selectionClick();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
