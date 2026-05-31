# Vaani AI

Vaani AI is a Flutter voice assistant that listens to your speech, sends it to
the Gemini API, and speaks back the response. The UI includes a reactive orb
animation that responds to microphone input.

## Features

- Speech-to-text input with a tap-to-talk flow
- Gemini API response generation
- Text-to-speech playback
- Dynamic orb animation based on audio levels

## Tech Stack

- Flutter (Dart)
- speech_to_text
- flutter_tts
- permission_handler
- http

## Prerequisites

- Flutter SDK (3.0+)
- A connected device or emulator
  - Android: Android Studio or a configured emulator
  - iOS: Xcode (macOS only)
- A Gemini API key

## Configure the API key

This app uses `GEMINI_API_KEY` and `GEMINI_MODEL` (optional) via
`--dart-define`. Set your own key before running.

Example model values: `gemini-2.5-flash`, `gemini-1.5-pro`.

## Run locally

1. Install dependencies

```bash
flutter pub get
```

2. Run on Android

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

3. Run on iOS (macOS only)

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

4. Run on Web

```bash
flutter run -d chrome --dart-define=GEMINI_API_KEY=YOUR_KEY
```

5. Run on Windows

```bash
flutter run -d windows --dart-define=GEMINI_API_KEY=YOUR_KEY
```

## Optional: change the model

```bash
flutter run \
	--dart-define=GEMINI_API_KEY=YOUR_KEY \
	--dart-define=GEMINI_MODEL=gemini-2.5-flash
```

## Permissions

The app requests microphone access at runtime. Make sure microphone permissions
are enabled for the app on your device.

## Troubleshooting

- If speech recognition never starts, check microphone permissions.
- If responses fail, verify the API key and network access.
- On iOS, ensure you have a valid signing setup in Xcode.
