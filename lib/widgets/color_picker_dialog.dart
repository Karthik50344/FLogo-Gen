import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'checkerboard_swatch.dart';

/// A minimal, dependency-free color picker (hue/saturation/brightness
/// sliders, a manual hex/RGB input, and an opacity slider with
/// transparency support) shown when the user taps a color swatch —
/// stands in for the native `<input type="color">` picker in the
/// original HTML.
class ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const ColorPickerDialog({super.key, required this.initial});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();

  static Future<Color?> show(BuildContext context, Color initial) {
    return showDialog<Color>(
      context: context,
      builder: (_) => ColorPickerDialog(initial: initial),
    );
  }
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsv;
  late TextEditingController _hexController;
  late TextEditingController _rController;
  late TextEditingController _gController;
  late TextEditingController _bController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
    _hexController = TextEditingController(text: _toHex(widget.initial));
    _rController = TextEditingController(text: '${widget.initial.red}');
    _gController = TextEditingController(text: '${widget.initial.green}');
    _bController = TextEditingController(text: '${widget.initial.blue}');
  }

  @override
  void dispose() {
    _hexController.dispose();
    _rController.dispose();
    _gController.dispose();
    _bController.dispose();
    super.dispose();
  }

  // Hex/RGB fields are RGB-only — opacity is controlled separately by the
  // slider below, so editing hex never resets transparency back to opaque.
  String _toHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}'.toUpperCase();

  void _syncRgbFields(Color c) {
    _hexController.text = _toHex(c);
    _rController.text = '${c.red}';
    _gController.text = '${c.green}';
    _bController.text = '${c.blue}';
  }

  void _applyHex(String v) {
    final match = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(v.trim());
    if (match == null) return;
    final rgb = int.parse(match.group(1)!, radix: 16);
    final alpha = (_hsv.alpha * 255).round();
    setState(() {
      _hsv = HSVColor.fromColor(Color((alpha << 24) | rgb));
      _rController.text = '${(rgb >> 16) & 0xFF}';
      _gController.text = '${(rgb >> 8) & 0xFF}';
      _bController.text = '${rgb & 0xFF}';
    });
  }

  void _applyRgb() {
    int clampByte(String s) => (int.tryParse(s) ?? 0).clamp(0, 255);
    final r = clampByte(_rController.text);
    final g = clampByte(_gController.text);
    final b = clampByte(_bController.text);
    final alpha = (_hsv.alpha * 255).round();
    setState(() {
      _hsv = HSVColor.fromColor(Color.fromARGB(alpha, r, g, b));
      _hexController.text = _toHex(Color.fromARGB(255, r, g, b));
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _hsv.toColor();
    final isTransparent = color.alpha == 0;

    return Dialog(
      backgroundColor: AppColors.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radius)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckerboardSwatch(
                  color: color,
                  width: double.infinity,
                  height: 56,
                  borderRadius: BorderRadius.circular(AppColors.radius2),
                ),
                const SizedBox(height: 16),
                _buildSlider(
                  label: 'Hue',
                  value: _hsv.hue,
                  max: 360,
                  onChanged: (v) => setState(() {
                    _hsv = _hsv.withHue(v);
                    _syncRgbFields(_hsv.toColor());
                  }),
                ),
                _buildSlider(
                  label: 'Saturation',
                  value: _hsv.saturation * 100,
                  max: 100,
                  onChanged: (v) => setState(() {
                    _hsv = _hsv.withSaturation(v / 100);
                    _syncRgbFields(_hsv.toColor());
                  }),
                ),
                _buildSlider(
                  label: 'Brightness',
                  value: _hsv.value * 100,
                  max: 100,
                  onChanged: (v) => setState(() {
                    _hsv = _hsv.withValue(v / 100);
                    _syncRgbFields(_hsv.toColor());
                  }),
                ),
                _buildSlider(
                  label: 'Opacity',
                  value: _hsv.alpha * 100,
                  max: 100,
                  onChanged: (v) => setState(() => _hsv = _hsv.withAlpha(v / 100)),
                  valueLabel: '${(_hsv.alpha * 100).round()}%',
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _hsv = _hsv.withAlpha(0)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isTransparent ? AppColors.accent : AppColors.text2,
                          side: BorderSide(color: isTransparent ? AppColors.accent : AppColors.border2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Transparent', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _hsv = _hsv.withAlpha(1)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: !isTransparent ? AppColors.accent : AppColors.text2,
                          side: BorderSide(color: !isTransparent ? AppColors.accent : AppColors.border2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Opaque', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Manual color', style: TextStyle(fontSize: 12, color: AppColors.text2)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _hexController,
                  onChanged: _applyHex,
                  maxLength: 7,
                  style: const TextStyle(color: AppColors.text, fontFamily: 'JetBrainsMono'),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '#RRGGBB',
                    hintStyle: const TextStyle(color: AppColors.text3),
                    filled: true,
                    fillColor: AppColors.surface3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppColors.radius2),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildRgbField('R', _rController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildRgbField('G', _gController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildRgbField('B', _bController)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.text2)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(color),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRgbField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => _applyRgb(),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.text, fontFamily: 'JetBrainsMono', fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.text3, fontSize: 11),
        filled: true,
        fillColor: AppColors.surface3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radius2),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
    String? valueLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
            if (valueLabel != null)
              Text(valueLabel, style: const TextStyle(fontSize: 12, color: AppColors.text3)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surface3,
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accent.withOpacity(0.2),
          ),
          child: Slider(value: value.clamp(0, max), min: 0, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
