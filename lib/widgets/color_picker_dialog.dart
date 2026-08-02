import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A minimal, dependency-free color picker (hue slider + saturation/value
/// field) shown when the user taps a color swatch — stands in for the
/// native `<input type="color">` picker in the original HTML.
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

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
    _hexController = TextEditingController(text: _toHex(widget.initial));
  }

  String _toHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2)}';

  void _applyHex(String v) {
    final match = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(v.trim());
    if (match == null) return;
    final color = Color(int.parse('FF${match.group(1)}', radix: 16));
    setState(() => _hsv = HSVColor.fromColor(color));
  }

  @override
  Widget build(BuildContext context) {
    final color = _hsv.toColor();

    return Dialog(
      backgroundColor: AppColors.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radius)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppColors.radius2),
                  border: Border.all(color: AppColors.border2),
                ),
              ),
              const SizedBox(height: 16),
              _buildSlider(
                label: 'Hue',
                value: _hsv.hue,
                max: 360,
                onChanged: (v) => setState(() {
                  _hsv = _hsv.withHue(v);
                  _hexController.text = _toHex(_hsv.toColor());
                }),
              ),
              _buildSlider(
                label: 'Saturation',
                value: _hsv.saturation * 100,
                max: 100,
                onChanged: (v) => setState(() {
                  _hsv = _hsv.withSaturation(v / 100);
                  _hexController.text = _toHex(_hsv.toColor());
                }),
              ),
              _buildSlider(
                label: 'Brightness',
                value: _hsv.value * 100,
                max: 100,
                onChanged: (v) => setState(() {
                  _hsv = _hsv.withValue(v / 100);
                  _hexController.text = _toHex(_hsv.toColor());
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hexController,
                onChanged: _applyHex,
                maxLength: 7,
                style: const TextStyle(color: AppColors.text, fontFamily: 'JetBrainsMono'),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surface3,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radius2),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
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
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
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
