import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';
import '../services/reminder_service.dart';
import '../widgets/orb_painter.dart';
import '../widgets/voice_controls.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late stt.SpeechToText _speech;
  late ApiService _apiService;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _isPassiveListening = false;
  String _text = "Say 'Hey Vaani' or tap the mic";
  String _lastFinalText = '';

  late AnimationController _waveController;
  late AnimationController _pulseController;

  double _smoothSoundLevel = 0.0;
  double _targetSoundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech = stt.SpeechToText();
    _initPassiveListening();
    _apiService = ApiService();
    _tts = FlutterTts();
    _initTts();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _waveController.addListener(() {
      if (mounted && _isListening) {
        setState(() {
          _smoothSoundLevel =
              _smoothSoundLevel + (_targetSoundLevel - _smoothSoundLevel) * 0.10;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tts.stop();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _tts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
      }
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
        _startPassiveListening();
      }
    });
    _tts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
        _startPassiveListening();
      }
    });
    _tts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
        _startPassiveListening();
      }
    });
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = true;
        _isPaused = false;
      });
    }
    await _tts.speak(text);
  }

  String _sanitizeForSpeech(String text) {
    final stripped = text
        .replaceAll(RegExp(r'\[(.*?)\]\((.*?)\)'), r'$1')
        .replaceAll(RegExp(r'[*_`~>#]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return stripped;
  }

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _handleFinalResult(String recognizedText) async {
    final prompt = recognizedText.trim();
    if (prompt.isEmpty) {
      if (mounted) {
        setState(() {
          _text = "I didn't catch that. Try again.";
        });
      }
      return;
    }
    if (_isProcessing || prompt == _lastFinalText) {
      return;
    }
    _lastFinalText = prompt;
    _isProcessing = true;
    _isPassiveListening = false;
    await _speech.stop();
    if (mounted) {
      setState(() {
        _text = 'Thinking...';
      });
    }
    try {
      final response = await _apiService.getResponse(prompt);
      String displayText = response;
      try {
        if (response.contains('{"reminder":')) {
          final jsonStart = response.indexOf('{"reminder":');
          final jsonEnd = response.lastIndexOf('}') + 1;
          final jsonStr = response.substring(jsonStart, jsonEnd);
          final data = jsonDecode(jsonStr);

          final task = data['reminder']['task'];
          final time = DateTime.parse(data['reminder']['time']);

          await ReminderService().scheduleReminder(
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            "Vaani AI Reminder",
            task,
            time,
          );
          displayText =
              "${response.substring(0, jsonStart).trim()} ${response.substring(jsonEnd).trim()}";
          if (displayText.trim().isEmpty) {
            displayText =
                "OK, I've set a reminder for $task at ${time.hour}:${time.minute}.";
          }
        }
      } catch (e) {
        debugPrint("Error parsing reminder JSON: $e");
      }
      if (mounted) {
        setState(() {
          _text = displayText;
        });
      }
      final speechText = _sanitizeForSpeech(displayText);
      if (displayText.isNotEmpty &&
          !displayText.startsWith('API Error') &&
          !displayText.startsWith('Exception') &&
          speechText.isNotEmpty) {
        await _speak(speechText);
      } else {
        _startPassiveListening();
      }
    } finally {
      _isProcessing = false;
    }
  } Future<void> _initPassiveListening() async {
    final hasPermission = await _requestMicPermission();
    if (!hasPermission) return;

    bool available = await _speech.initialize(
      onError: (error) {
        debugPrint("Speech Error: ${error.errorMsg}");
        if (mounted) {
          setState(() => _isPassiveListening = false);
          Future.delayed(
              const Duration(seconds: 1), () => _startPassiveListening());
        }
      },
      onStatus: (status) {
        debugPrint("Speech Status: $status");
        if (status == 'done' ||
            status == 'notListening' ||
            status == 'stopped') {
          if (mounted) {
            setState(() => _isPassiveListening = false);
            if (!_isListening && !_isProcessing && !_isSpeaking) {
              Future.delayed(const Duration(milliseconds: 1000),
                  () => _startPassiveListening());
            }
          }
        }
      },
    );
    if (available) {
      _startPassiveListening();
    }
  }  void _startPassiveListening() async {
    if (_isListening || _isProcessing || _isSpeaking || _isPassiveListening) {
      return;
    }
    if (mounted) setState(() => _isPassiveListening = true);
    await _speech.listen(
      onResult: (val) async {
        String recognized = val.recognizedWords.toLowerCase();
        if (recognized.contains("hey vaani") ||
            recognized.contains("hey vani") ||
            recognized.contains("hi vaani") ||
            recognized.contains("hello vaani") ||
            recognized.contains("vani")) {
          if (mounted) setState(() => _isPassiveListening = false);
          await _speech.stop();
          Future.delayed(const Duration(milliseconds: 300), () => _listen());
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }
  void _togglePauseResume() async {
    if (_isSpeaking) {
      await _tts.pause();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = true;
        });
      }
    } else if (_isPaused) {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
          _isPaused = false;
        });
      }
      await _tts.speak(_sanitizeForSpeech(_text));
    }
  }
  void _listen() async {
    if (_isPassiveListening) {
      _isPassiveListening = false;
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (_isSpeaking || _isPaused) {
      await _tts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
          _text = "Listening...";
        });
      }
    }
    if (!_isListening) {
      final hasPermission = await _requestMicPermission();
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _text = 'Microphone permission denied.';
          });
        }
        return;
      }
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' ||
              status == 'notListening' ||
              status == 'stopped') {
            if (mounted) {
              setState(() {
                _isListening = false;
                _targetSoundLevel = 0.0;
                _smoothSoundLevel = 0.0;
              });
            }
          }
        },
        onError: (errorNotification) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _targetSoundLevel = 0.0;
              _smoothSoundLevel = 0.0;
            });
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _text = val.recognizedWords;
                if (_text.isEmpty && _isListening) {
                  _text = "Listening...";
                }
              });
            }
            if (val.finalResult) {
              _handleFinalResult(val.recognizedWords);
            }
          },
          listenOptions: stt.SpeechListenOptions(
            pauseFor: const Duration(seconds: 2),
          ),
          onSoundLevelChange: (level) {
            if (mounted && _isListening) {
              setState(() {
                _targetSoundLevel = level.clamp(0.0, 10.0);
              });
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _targetSoundLevel = 0.0;
        _smoothSoundLevel = 0.0;
      });
      await _speech.stop();
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const Color bgSpaceDark = Color(0xFF0D0C12);
    const Color gradientTop = Color(0xFF220F35);
    const Color glowPink = Color(0xFFFF1E7C);

    return Scaffold(
      backgroundColor: bgSpaceDark,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientTop, bgSpaceDark, bgSpaceDark],
              ),
            ),
          ),
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF9000D0).withValues(alpha: 0.3),
                    glowPink.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48.0),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chat with Vaani',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 18.0),
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _waveController,
                                  builder: (context, child) {
                                    double rotationFactor =
                                        _waveController.value * 2 * math.pi;

                                    return CustomPaint(
                                      size: const Size(250, 250),
                                      painter: ExactImageOrbPainter(
                                        rotation: rotationFactor,
                                        voiceEnergy: _smoothSoundLevel,
                                        isListening:
                                            _isListening || _isSpeaking,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 50.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    _text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 19.0,
                                      fontWeight: _isListening
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: _isListening
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.7),
                                      height: 1.5,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  VoiceControls(
                    isListening: _isListening,
                    isSpeaking: _isSpeaking,
                    isPaused: _isPaused,
                    pulseController: _pulseController,
                    onTogglePauseResume: _togglePauseResume,
                    onListen: _listen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
