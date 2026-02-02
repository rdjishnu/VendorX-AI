import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  /// Tracks the actual listening status to sync with UI.
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);

  /// Initialize the speech engine
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('Voice Error: ${error.errorMsg}');
          isListeningNotifier.value = false;
        },
        onStatus: (status) {
          debugPrint('Voice Status: $status');
          if (status == 'listening') {
            isListeningNotifier.value = true;
          } else if (status == 'notListening' || status == 'done') {
            isListeningNotifier.value = false;
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Voice Service Init Failed: $e');
      return false;
    }
  }

  /// Start listening and stream words. Returns true if started successfully.
  Future<bool> listen({
    required Function(String) onResult,
    String? localeId,
    ListenMode listenMode = ListenMode.dictation,
  }) async {
    if (!_isInitialized) {
      bool available = await initialize();
      if (!available) return false;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenMode: listenMode,
        cancelOnError: false,
        partialResults: true,
      );
      return true;
    } catch (e) {
      debugPrint('Listen failed: $e');
      return false;
    }
  }

  /// Stop listening
  Future<void> stop() async {
    await _speech.stop();
    isListeningNotifier.value = false;
  }

  bool get isListening => _speech.isListening;
}
