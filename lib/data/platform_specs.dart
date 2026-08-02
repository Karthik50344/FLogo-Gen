import 'package:flutter/material.dart';

/// Static metadata for the platform-selector cards. Mirrors the
/// `.platform-card` entries in the original HTML.
class PlatformMeta {
  final String id;
  final String emoji;
  final Color iconBg;
  final String name;
  final String desc;

  const PlatformMeta({
    required this.id,
    required this.emoji,
    required this.iconBg,
    required this.name,
    required this.desc,
  });
}

const List<PlatformMeta> kPlatforms = [
  PlatformMeta(
    id: 'android',
    emoji: '🤖',
    iconBg: Color(0x1F78C257),
    name: 'Android',
    desc: 'mipmap + Play Store',
  ),
  PlatformMeta(
    id: 'ios',
    emoji: '🍎',
    iconBg: Color(0x0FFFFFFF),
    name: 'iOS',
    desc: 'AppIcon + Sticker',
  ),
  PlatformMeta(
    id: 'web',
    emoji: '🌐',
    iconBg: Color(0x1A54A0FF),
    name: 'Web',
    desc: 'favicon + icons',
  ),
  PlatformMeta(
    id: 'linux',
    emoji: '🐧',
    iconBg: Color(0x1AFFA500),
    name: 'Linux',
    desc: 'desktop icon',
  ),
  PlatformMeta(
    id: 'windows',
    emoji: '🪟',
    iconBg: Color(0x1A0078D4),
    name: 'Windows',
    desc: 'ICO + app icon',
  ),
  PlatformMeta(
    id: 'macos',
    emoji: '💻',
    iconBg: Color(0x0FC8C8C8),
    name: 'macOS',
    desc: 'ICNS sizes',
  ),
];

/// Android mipmap density -> (launcher size, adaptive foreground size)
const Map<String, List<int>> kAndroidMipmapSizes = {
  'mipmap-mdpi': [48, 108],
  'mipmap-hdpi': [72, 162],
  'mipmap-xhdpi': [96, 216],
  'mipmap-xxhdpi': [144, 324],
  'mipmap-xxxhdpi': [192, 432],
};

class IosIconSpec {
  final String name;
  final int size;
  const IosIconSpec(this.name, this.size);
}

const List<IosIconSpec> kIosIconSizes = [
  IosIconSpec('Icon-App-20x20@1x.png', 20),
  IosIconSpec('Icon-App-20x20@2x.png', 40),
  IosIconSpec('Icon-App-20x20@3x.png', 60),
  IosIconSpec('Icon-App-29x29@1x.png', 29),
  IosIconSpec('Icon-App-29x29@2x.png', 58),
  IosIconSpec('Icon-App-29x29@3x.png', 87),
  IosIconSpec('Icon-App-40x40@1x.png', 40),
  IosIconSpec('Icon-App-40x40@2x.png', 80),
  IosIconSpec('Icon-App-40x40@3x.png', 120),
  IosIconSpec('Icon-App-60x60@2x.png', 120),
  IosIconSpec('Icon-App-60x60@3x.png', 180),
  IosIconSpec('Icon-App-76x76@1x.png', 76),
  IosIconSpec('Icon-App-76x76@2x.png', 152),
  IosIconSpec('Icon-App-83.5x83.5@2x.png', 167),
  IosIconSpec('ItunesArtwork@2x.png', 1024),
];

const List<int> kMacIconSizes = [16, 32, 64, 128, 256, 512, 1024];

const Map<String, int> kAndroidNotifDrawableSizes = {
  'drawable-mdpi': 24,
  'drawable-hdpi': 36,
  'drawable-xhdpi': 48,
  'drawable-xxhdpi': 72,
  'drawable-xxxhdpi': 96,
};
