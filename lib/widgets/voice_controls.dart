import 'package:flutter/material.dart';

class VoiceControls extends StatelessWidget {
  final bool isListening;
  final bool isSpeaking;
  final bool isPaused;
  final AnimationController pulseController;
  final VoidCallback onTogglePauseResume;
  final VoidCallback onListen;

  const VoiceControls({
    super.key,
    required this.isListening,
    required this.isSpeaking,
    required this.isPaused,
    required this.pulseController,
    required this.onTogglePauseResume,
    required this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    const Color glowPink = Color(0xFFFF1E7C);
    const Color micOuterLight = Color(0xFFE5B0E2);
    const Color micOuterDark = Color(0xFF9000D0);
    const Color micInnerPink = Color(0xFFFF90B1);
    const Color micInnerPurple = Color(0xFF7A368F);
    const Color bgSpaceDark = Color(0xFF0D0C12);

    final bool isPlaybackActive = isSpeaking || isPaused;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isListening
              ? 'Listening...'
              : isSpeaking
                  ? 'Speaking...'
                  : isPaused
                      ? 'Paused'
                      : 'Tap Mic to Start',
          style: TextStyle(
            color: isListening || isSpeaking || isPaused
                ? glowPink
                : Colors.white60,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pause/Resume button always besides microphone
              GestureDetector(
                onTap: isPlaybackActive ? onTogglePauseResume : null,
                child: Opacity(
                  opacity: isPlaybackActive ? 1.0 : 0.3,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      isSpeaking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              GestureDetector(
                onTap: onListen,
                child: AnimatedBuilder(
                  animation: pulseController,
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
                            color: glowPink.withValues(
                                alpha: isListening
                                    ? (0.45 * pulseController.value)
                                    : 0.15),
                            blurRadius: isListening ? 28 : 12,
                            spreadRadius: isListening
                                ? (6 * pulseController.value)
                                : 1,
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
                            isListening
                                ? Icons.stop_rounded
                                : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 34.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
