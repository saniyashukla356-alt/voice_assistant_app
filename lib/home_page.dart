import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap the microphone to start speaking";

  late AnimationController _waveController;
  late AnimationController _pulseController;

  double _smoothSoundLevel = 0.0;
  double _targetSoundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

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
          _smoothSoundLevel = _smoothSoundLevel + (_targetSoundLevel - _smoothSoundLevel) * 0.10;
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening' || status == 'stopped') {
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
    const Color micOuterLight = Color(0xFFE5B0E2);
    const Color micOuterDark = Color(0xFF9000D0);
    const Color micInnerPink = Color(0xFFFF90B1);
    const Color micInnerPurple = Color(0xFF7A368F);

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
                    const Color(0xFF9000D0).withOpacity(0.3),
                    glowPink.withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18.0),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            double rotationFactor = _waveController.value * 2 * math.pi;

                            return CustomPaint(
                              size: const Size(250, 250),
                              painter: ExactImageOrbPainter(
                                rotation: rotationFactor,
                                voiceEnergy: _smoothSoundLevel,
                                isListening: _isListening,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 50.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.0,
                              fontWeight: _isListening ? FontWeight.w600 : FontWeight.w400,
                              color: _isListening ? Colors.white : Colors.white.withOpacity(0.7),
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isListening ? 'Listening...' : 'Tap Mic to Start',
                        style: TextStyle(
                          color: _isListening ? glowPink : Colors.white60,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: GestureDetector(
                          onTap: _listen,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                height: 80,
                                width: 80,
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [micOuterLight, micOuterDark],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: glowPink.withOpacity(_isListening ? (0.45 * _pulseController.value) : 0.15),
                                      blurRadius: _isListening ? 28 : 12,
                                      spreadRadius: _isListening ? (6 * _pulseController.value) : 1,
                                    )
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: bgSpaceDark,
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [micInnerPink, micInnerPurple],
                                        radius: 0.75,
                                      ),
                                    ),
                                    child: Icon(
                                      _isListening ? Icons.stop_rounded : Icons.mic_none_rounded,
                                      color: Colors.white,
                                      size: 34.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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

class ExactImageOrbPainter extends CustomPainter {
  final double rotation;
  final double voiceEnergy;
  final bool isListening;

  ExactImageOrbPainter({
    required this.rotation,
    required this.voiceEnergy,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final coreRadius = size.width * 0.32;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    int ribbonLayers = 65;

    double organicAmplitude = isListening ? (4.5 + (voiceEnergy * 1.6)) : 4.0;

    for (int i = 0; i < ribbonLayers; i++) {
      final double progress = i / ribbonLayers;

      paint.color = Color.lerp(
        const Color(0xFFFF499E).withOpacity(0.85),
        const Color(0xFF8A2BE2).withOpacity(0.15),
        progress,
      )!;

      final Path layerPath = Path();

      for (int step = 0; step <= 120; step++) {
        final double radialAngle = (step / 120) * 2 * math.pi;

        double dynamicWaveform = math.sin(radialAngle * 5 + rotation) * math.cos(radialAngle * 3 - (progress * math.pi));

        if (voiceEnergy > 1.5) {
          dynamicWaveform += 0.20 * math.sin(radialAngle * 10 + (rotation * 1.5));
        }

        double finalRadius = (coreRadius * progress) + (dynamicWaveform * organicAmplitude);
        double x = center.dx + finalRadius * math.cos(radialAngle);
        double y = center.dy + finalRadius * math.sin(radialAngle);

        if (step == 0) {
          layerPath.moveTo(x, y);
        } else {
          layerPath.lineTo(x, y);
        }
      }
      canvas.drawPath(layerPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ExactImageOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.voiceEnergy != voiceEnergy ||
        oldDelegate.isListening != isListening;
  }
}