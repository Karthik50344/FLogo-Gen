import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../services/generate_controller.dart';
import '../theme/app_colors.dart';
import 'app_toast.dart';

class GenerateButton extends StatefulWidget {
  const GenerateButton({super.key});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton> {
  bool _hovering = false;

  Future<void> _onPressed() async {
    final state = context.read<AppState>();
    final result = await GenerateController.generate(state);
    if (!mounted) return;
    AppToast.show(
      context,
      result.message,
      type: result.success ? ToastType.success : ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = context.watch<AppState>().isGenerating;

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            onTap: isGenerating ? null : _onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(0, (_hovering && !isGenerating) ? -2 : 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: _hovering && !isGenerating
                    ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 12))]
                    : [],
              ),
              child: Opacity(
                opacity: isGenerating ? 0.5 : 1,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Generate & Download ZIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'All processing happens in your browser. Nothing is sent to any server.',
          style: TextStyle(fontSize: 12, color: AppColors.text3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
