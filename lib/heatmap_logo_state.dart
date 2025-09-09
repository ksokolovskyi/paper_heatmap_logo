import 'package:flutter/material.dart';

class HeatmapLogoState extends ChangeNotifier {
  HeatmapLogoState() : _type = HeatmapLogoType.flutter;

  HeatmapLogoType _type;

  HeatmapLogoType get type => _type;

  set type(HeatmapLogoType value) {
    if (value == _type) {
      return;
    }

    _type = value;
    notifyListeners();
  }
}

enum HeatmapLogoType {
  flutter,
  google,
  apple,
  firebase,
  gemini;

  String get asset {
    return switch (this) {
      flutter => 'assets/images/flutter.png',
      google => 'assets/images/google.png',
      apple => 'assets/images/apple.png',
      firebase => 'assets/images/firebase.png',
      gemini => 'assets/images/gemini.png',
    };
  }

  String get icon {
    return switch (this) {
      flutter => 'assets/images/svg/flutter.svg',
      google => 'assets/images/svg/google.svg',
      apple => 'assets/images/svg/apple.svg',
      firebase => 'assets/images/svg/firebase.svg',
      gemini => 'assets/images/svg/gemini.svg',
    };
  }

  String get label {
    return switch (this) {
      flutter => 'Flutter',
      google => 'Google',
      apple => 'Apple',
      firebase => 'Firebase',
      gemini => 'Gemini',
    };
  }
}
