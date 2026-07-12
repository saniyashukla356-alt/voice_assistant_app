import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;

  bool get isListening => _speech.isListening;
  bool get speechEnabled => _speechEnabled;

  Future<bool> initialize({
    required Function(String status) onStatus,
    required Function(dynamic error) onError,
  }) async {
    _speechEnabled = await _speech.initialize(
      onStatus: onStatus,
      onError: (val) => onError(val),
    );
    return _speechEnabled;
  }

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startListening({
    required Function(dynamic result) onResult,
    required Function(double level)? onSoundLevelChange,
    stt.SpeechListenOptions? listenOptions,
  }) async {
    if (!_speechEnabled) return;
    
    await _speech.listen(
      onResult: (val) => onResult(val),
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: listenOptions ?? stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }
}
