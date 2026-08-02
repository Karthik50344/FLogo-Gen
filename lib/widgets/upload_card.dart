import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/app_colors.dart';
import 'app_toast.dart';
import 'section_card.dart';

const int _maxBytes = 20 * 1024 * 1024;

class UploadCard extends StatefulWidget {
  const UploadCard({super.key});

  @override
  State<UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<UploadCard> {
  bool _dragOver = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.single;
    if (f.bytes == null) return;
    _handleBytes(f.bytes!, f.name, f.size, _guessMime(f.name));
  }

  Future<void> _handleDrop(List<XFile> files) async {
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();
    _handleBytes(bytes, file.name, bytes.length, file.mimeType ?? _guessMime(file.name));
  }

  void _handleBytes(List<int> bytes, String name, int size, String mime) {
    if (size > _maxBytes) {
      AppToast.show(context, 'File too large (max 20MB)', type: ToastType.error);
      return;
    }
    context.read<AppState>().setImage(
          bytes: Uint8List.fromList(bytes),
          name: name,
          size: size,
          mime: mime,
        );
  }

  String _guessMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/*';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepLabel(number: 1, title: 'Upload Logo'),
          if (!state.hasImage) _buildDropZone() else _buildPreview(state),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Chip('max 20MB'),
              _Chip('auto-resized'),
              _Chip('memory only'),
              _Chip('never uploaded'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragOver = true),
      onDragExited: (_) => setState(() => _dragOver = false),
      onDragDone: (details) {
        setState(() => _dragOver = false);
        _handleDrop(details.files);
      },
      child: GestureDetector(
        onTap: _pickFile,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: _dragOver
                ? AppColors.accent.withOpacity(0.05)
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppColors.radius2),
            border: Border.all(
              color: _dragOver ? AppColors.accent : AppColors.border2,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 48, color: AppColors.text.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'Drop your logo here\nor click to browse',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text2, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 8),
              const Text(
                'PNG, SVG, JPG, WEBP — any size, square recommended',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text3, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppColors.radius2),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: state.imageBytes != null
                ? Image.memory(state.imageBytes!, fit: BoxFit.contain)
                : const SizedBox(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.fileName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatBytes(state.fileSize ?? 0)} · ${state.mimeType ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => context.read<AppState>().clearImage(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Remove', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.accent.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.text2,
          fontFamily: 'JetBrainsMono',
        ),
      ),
    );
  }
}

