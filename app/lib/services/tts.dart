import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 단일 FlutterTts 인스턴스 + ja-JP / ko-KR 언어 토글.
/// 사용:
///   await Tts.instance.speakJa("ありがとう");
///   await Tts.instance.speakKo("고마워");
class Tts {
  Tts._();
  static final Tts instance = Tts._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  String? _currentLang;
  bool _muted = false;

  bool get muted => _muted;
  void toggleMute() => _muted = !_muted;
  void setMuted(bool v) => _muted = v;

  Future<void> _ensureInit() async {
    if (_ready) return;
    _ready = true;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45); // 약간 느리게 (학습용)
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> _setLang(String lang) async {
    if (_currentLang == lang) return;
    try {
      await _tts.setLanguage(lang);
      _currentLang = lang;
    } catch (e) {
      debugPrint('TTS setLanguage error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> speakJa(String text) async {
    if (_muted || text.trim().isEmpty) return;
    await _ensureInit();
    await _setLang('ja-JP');
    await stop();
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speakJa error: $e');
    }
  }

  Future<void> speakKo(String text) async {
    if (_muted || text.trim().isEmpty) return;
    await _ensureInit();
    await _setLang('ko-KR');
    await stop();
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speakKo error: $e');
    }
  }
}
