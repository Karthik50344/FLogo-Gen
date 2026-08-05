import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;
import 'package:image/image.dart' as img;

/// Direct port of the canvas-based image pipeline from the original
/// `<script>` block (resizeImage, removeBackground, generateNotificationIcon,
/// generateICO) using package:image instead of the HTML canvas API.
class ImageService {
  ImageService._();

  static img.Image? decode(Uint8List bytes) => img.decodeImage(bytes);

  static img.Image _blankCanvas(int size, {Color? bgColor}) {
    final canvas = img.Image(width: size, height: size, numChannels: 4);
    if (bgColor != null) {
      // bgColor.alpha (not a hardcoded 255) — otherwise a transparent
      // background selection would silently render fully opaque.
      img.fill(
        canvas,
        color: img.ColorRgba8(bgColor.red, bgColor.green, bgColor.blue, bgColor.alpha),
      );
    } else {
      img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
    }
    return canvas;
  }

  /// Equivalent of `resizeImage(img, size, opts)`.
  static img.Image resizeImage(
      img.Image src,
      int size, {
        Color? bgColor,
        bool maskable = false,
        bool rounded = false,
      }) {
    if (maskable) {
      final canvas = _blankCanvas(size, bgColor: bgColor ?? const Color(0xFFFFFFFF));
      final safeSize = (size * 0.8).round();
      final offset = ((size - safeSize) / 2).round();
      final resized = img.copyResize(
        src,
        width: safeSize,
        height: safeSize,
        interpolation: img.Interpolation.cubic,
      );
      img.compositeImage(canvas, resized, dstX: offset, dstY: offset);
      return canvas;
    }

    final canvas = _blankCanvas(size, bgColor: bgColor);
    final resized = img.copyResize(
      src,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(canvas, resized, dstX: 0, dstY: 0);

    if (rounded) {
      _applyRoundedMask(canvas, size * 0.2);
    }
    return canvas;
  }

  static void _applyRoundedMask(img.Image image, double radius) {
    final w = image.width, h = image.height;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!_insideRoundedRect(x + 0.5, y + 0.5, w.toDouble(), h.toDouble(), radius)) {
          final p = image.getPixel(x, y);
          image.setPixelRgba(x, y, p.r, p.g, p.b, 0);
        }
      }
    }
  }

  static bool _insideRoundedRect(double x, double y, double w, double h, double r) {
    double cx, cy;
    if (x < r && y < r) {
      cx = r;
      cy = r;
    } else if (x > w - r && y < r) {
      cx = w - r;
      cy = r;
    } else if (x < r && y > h - r) {
      cx = r;
      cy = h - r;
    } else if (x > w - r && y > h - r) {
      cx = w - r;
      cy = h - r;
    } else {
      return true; // not in a corner region
    }
    final dx = x - cx, dy = y - cy;
    return (dx * dx + dy * dy) <= r * r;
  }

  /// Equivalent of `removeBackground(canvas)`: samples the top-left,
  /// top-right and bottom-left pixels, averages them as the background
  /// color, and clears any pixel within `threshold` distance of it.
  static img.Image removeBackground(img.Image src) {
    final out = img.Image.from(src);
    final w = out.width, h = out.height;

    final tl = out.getPixel(0, 0);
    final tr = out.getPixel(w - 1, 0);
    final bl = out.getPixel(0, h - 1);

    final bgR = ((tl.r + tr.r + bl.r) / 3).round();
    final bgG = ((tl.g + tr.g + bl.g) / 3).round();
    final bgB = ((tl.b + tr.b + bl.b) / 3).round();

    const threshold = 40;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = out.getPixel(x, y);
        final dr = p.r - bgR, dg = p.g - bgG, db = p.b - bgB;
        final dist = (dr * dr + dg * dg + db * db).toDouble();
        if (dist < threshold * threshold) {
          out.setPixelRgba(x, y, p.r, p.g, p.b, 0);
        }
      }
    }
    return out;
  }

  /// Equivalent of `generateNotificationIcon(img, size, bgColor, fgColor)`.
  static img.Image generateNotificationIcon(
      img.Image src,
      int size,
      Color bgColor,
      Color fgColor,
      ) {
    final canvas = _blankCanvas(size, bgColor: bgColor);

    final temp = img.copyResize(
      src,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final p = temp.getPixel(x, y);
        if (p.a > 10) {
          final combinedAlpha = (p.a * (fgColor.alpha / 255)).round();
          temp.setPixelRgba(x, y, fgColor.red, fgColor.green, fgColor.blue, combinedAlpha);
        }
      }
    }

    final scaledSize = (size * 0.8).round();
    final offset = (size * 0.1).round();
    final scaled = img.copyResize(
      temp,
      width: scaledSize,
      height: scaledSize,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(canvas, scaled, dstX: offset, dstY: offset);
    return canvas;
  }

  static Uint8List encodePng(img.Image image) => img.encodePng(image);

  /// Equivalent of `generateICO(img, sizes)`: hand-rolled ICO container
  /// (ICONDIR + ICONDIRENTRY[] + embedded PNG payloads).
  static Uint8List generateIco(img.Image src, List<int> sizes) {
    final pngBuffers = <Uint8List>[
      for (final s in sizes) encodePng(resizeImage(src, s)),
    ];

    const headerSize = 6;
    const dirEntrySize = 16;
    final dirSize = sizes.length * dirEntrySize;
    final totalDirOffset = headerSize + dirSize;

    var totalSize = headerSize + dirSize;
    for (final b in pngBuffers) {
      totalSize += b.lengthInBytes;
    }

    final buffer = ByteData(totalSize);

    // ICONDIR
    buffer.setUint16(0, 0, Endian.little); // reserved
    buffer.setUint16(2, 1, Endian.little); // type = 1 (icon)
    buffer.setUint16(4, sizes.length, Endian.little);

    var dataOffset = totalDirOffset;
    for (var i = 0; i < sizes.length; i++) {
      final s = sizes[i];
      final png = pngBuffers[i];
      final off = headerSize + i * dirEntrySize;
      buffer.setUint8(off, s >= 256 ? 0 : s); // width
      buffer.setUint8(off + 1, s >= 256 ? 0 : s); // height
      buffer.setUint8(off + 2, 0); // color count
      buffer.setUint8(off + 3, 0); // reserved
      buffer.setUint16(off + 4, 1, Endian.little); // planes
      buffer.setUint16(off + 6, 32, Endian.little); // bit count
      buffer.setUint32(off + 8, png.lengthInBytes, Endian.little);
      buffer.setUint32(off + 12, dataOffset, Endian.little);
      dataOffset += png.lengthInBytes;
    }

    final out = Uint8List(totalSize);
    out.setRange(0, headerSize + dirSize, buffer.buffer.asUint8List(0, headerSize + dirSize));

    var writeOffset = totalDirOffset;
    for (final png in pngBuffers) {
      out.setRange(writeOffset, writeOffset + png.lengthInBytes, png);
      writeOffset += png.lengthInBytes;
    }

    return out;
  }
}
