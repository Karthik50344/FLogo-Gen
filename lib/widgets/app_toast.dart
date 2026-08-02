import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastType { info, success, error }

/// A bottom-center pill toast, matching `.toast` in the original CSS.
/// Managed via an OverlayEntry so it can be triggered from anywhere.
class AppToast {
  static OverlayEntry? _entry;

  static void show(BuildContext context, String message, {ToastType type = ToastType.info}) {
    _entry?.remove();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, type: type, onDone: () {
        _entry?.remove();
        _entry = null;
      }),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDone;
  const _ToastWidget({required this.message, required this.type, required this.onDone});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 1.6), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 4000), () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success.withOpacity(0.3);
      case ToastType.error:
        return AppColors.danger.withOpacity(0.3);
      case ToastType.info:
        return AppColors.border2;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.danger;
      case ToastType.info:
        return AppColors.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _offset,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: _borderColor),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 8))],
            ),
            child: Text(
              widget.message,
              style: TextStyle(fontSize: 14, color: _textColor),
            ),
          ),
        ),
      ),
    );
  }
}
