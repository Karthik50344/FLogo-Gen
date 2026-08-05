import 'dart:typed_data';

/// Everything the background isolate needs to build the ZIP, as a plain,
/// isolate-safe value. Deliberately holds no `Color`, no `AppState`, no
/// Flutter types at all — colors are raw ARGB ints, platforms is a
/// `List<String>` — because isolate messages are copied across an
/// isolate boundary, and keeping this to primitives + Uint8List/List/Map
/// avoids any ambiguity about what is and isn't safe to send.
class GenerateJob {
  final Uint8List imageBytes;
  final List<String> platforms;
  final bool removeBg;
  final bool genNotif;
  final bool genAdaptive;
  final String theme;
  final int lightBg;
  final int lightFg;
  final int darkBg;
  final int darkFg;

  const GenerateJob({
    required this.imageBytes,
    required this.platforms,
    required this.removeBg,
    required this.genNotif,
    required this.genAdaptive,
    required this.theme,
    required this.lightBg,
    required this.lightFg,
    required this.darkBg,
    required this.darkFg,
  });

  /// The same step list the loader overlay displays, computed once here
  /// so both the UI (before the job is sent) and the worker (as it
  /// reports progress indices) agree on what step N means.
  List<String> get stepLabels => [
        'Loading image',
        'Processing image',
        if (removeBg) 'Removing background',
        for (final p in platforms) 'Generating $p assets',
        if (genNotif) 'Creating notification icons',
        'Building ZIP archive',
      ];

  /// Encodes to a plain Map of only primitive/Uint8List/List<String>
  /// values — the safest possible shape to pass through a SendPort.
  Map<String, dynamic> toMap() => {
        'imageBytes': imageBytes,
        'platforms': platforms,
        'removeBg': removeBg,
        'genNotif': genNotif,
        'genAdaptive': genAdaptive,
        'theme': theme,
        'lightBg': lightBg,
        'lightFg': lightFg,
        'darkBg': darkBg,
        'darkFg': darkFg,
      };

  factory GenerateJob.fromMap(Map<dynamic, dynamic> map) => GenerateJob(
        imageBytes: map['imageBytes'] as Uint8List,
        platforms: List<String>.from(map['platforms'] as List),
        removeBg: map['removeBg'] as bool,
        genNotif: map['genNotif'] as bool,
        genAdaptive: map['genAdaptive'] as bool,
        theme: map['theme'] as String,
        lightBg: map['lightBg'] as int,
        lightFg: map['lightFg'] as int,
        darkBg: map['darkBg'] as int,
        darkFg: map['darkFg'] as int,
      );
}
