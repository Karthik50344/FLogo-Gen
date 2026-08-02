import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Central app state, equivalent to the `state` object + assorted
/// DOM-driven flags in the original script.
class AppState extends ChangeNotifier {
  // --- Upload ---
  Uint8List? imageBytes;
  String? fileName;
  int? fileSize;
  String? mimeType;

  bool get hasImage => imageBytes != null;

  // --- Platforms ---
  final Set<String> platforms = {};

  // --- Options ---
  bool removeBg = false;
  bool genNotif = true;
  bool genAdaptive = true;

  // --- Notification theme ---
  String theme = 'both'; // 'both' | 'light' | 'dark'
  Color lightBg = const Color(0xFFFFFFFF);
  Color lightFg = const Color(0xFF1A1A2E);
  Color darkBg = const Color(0xFF1A1A2E);
  Color darkFg = const Color(0xFFFFFFFF);

  // --- Generation / loader ---
  bool isGenerating = false;
  List<String> loaderSteps = [];
  int currentStepIndex = -1;
  String loaderText = '';

  void setImage({
    required Uint8List bytes,
    required String name,
    required int size,
    required String mime,
  }) {
    imageBytes = bytes;
    fileName = name;
    fileSize = size;
    mimeType = mime;
    notifyListeners();
  }

  void clearImage() {
    imageBytes = null;
    fileName = null;
    fileSize = null;
    mimeType = null;
    notifyListeners();
  }

  void togglePlatform(String id) {
    if (platforms.contains(id)) {
      platforms.remove(id);
    } else {
      platforms.add(id);
    }
    notifyListeners();
  }

  void selectAllPlatforms(List<String> ids) {
    platforms
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void clearPlatforms() {
    platforms.clear();
    notifyListeners();
  }

  void setRemoveBg(bool v) {
    removeBg = v;
    notifyListeners();
  }

  void setGenNotif(bool v) {
    genNotif = v;
    notifyListeners();
  }

  void setGenAdaptive(bool v) {
    genAdaptive = v;
    notifyListeners();
  }

  void setTheme(String t) {
    theme = t;
    notifyListeners();
  }

  void setColor(String field, Color c) {
    switch (field) {
      case 'lightBg':
        lightBg = c;
        break;
      case 'lightFg':
        lightFg = c;
        break;
      case 'darkBg':
        darkBg = c;
        break;
      case 'darkFg':
        darkFg = c;
        break;
    }
    notifyListeners();
  }

  void startLoading(List<String> steps) {
    isGenerating = true;
    loaderSteps = steps;
    currentStepIndex = -1;
    loaderText = '';
    notifyListeners();
  }

  Future<void> setStep(int idx) async {
    currentStepIndex = idx;
    loaderText = '${loaderSteps[idx]}…';
    notifyListeners();
    // Yield to the UI thread so the loader animates, like the JS setTimeout(20ms).
    await Future.delayed(const Duration(milliseconds: 20));
  }

  void stopLoading() {
    isGenerating = false;
    currentStepIndex = -1;
    notifyListeners();
  }
}
