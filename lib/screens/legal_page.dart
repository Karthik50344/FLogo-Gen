import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/legal_content.dart';
import '../theme/app_colors.dart';

class LegalPage extends StatefulWidget {
  final String title;
  final IconData heroIcon;
  final String subtitle;
  final String effectiveDate;
  final String version;
  final List<LegalSection> sections;
  final List<PageBadge> badges;
  final IconData footerIcon;
  final Color footerIconColor;
  final String footerNote;

  const LegalPage({
    super.key,
    required this.title,
    required this.heroIcon,
    required this.subtitle,
    required this.effectiveDate,
    required this.version,
    required this.sections,
    this.badges = const [],
    this.footerIcon = Icons.shield_outlined,
    this.footerIconColor = AppColors.success,
    this.footerNote = 'This application processes all data locally on your '
        'device. No information is ever transmitted to external servers.',
  });

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  late final List<GlobalKey> _sectionKeys;
  late final List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _sectionKeys = List.generate(widget.sections.length, (_) => GlobalKey());
    // Overview/Agreement (index 0) starts expanded, like the reference.
    _expanded = List.generate(widget.sections.length, (i) => i == 0);
  }

  void _scrollToSection(int index) {
    setState(() => _expanded[index] = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _sectionKeys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 28),
                        _buildTableOfContents(),
                        const SizedBox(height: 28),
                        for (var i = 0; i < widget.sections.length; i++)
                          Padding(
                            key: _sectionKeys[i],
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _AccordionCard(
                              index: i + 1,
                              section: widget.sections[i],
                              expanded: _expanded[i],
                              onTap: () => setState(() => _expanded[i] = !_expanded[i]),
                            ),
                          ),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy link',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.title));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied')),
              );
            },
            icon: const Icon(Icons.copy_outlined, color: AppColors.text2, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withOpacity(0.25)),
          ),
          child: Icon(widget.heroIcon, color: AppColors.accent, size: 26),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.badges,
        ),
      ],
    );
  }

  Widget _buildTableOfContents() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt_outlined, size: 18, color: AppColors.text),
              SizedBox(width: 10),
              Text(
                'Table of Contents',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < widget.sections.length; i++)
            _TocRow(
              index: i + 1,
              title: widget.sections[i].title,
              isLast: i == widget.sections.length - 1,
              onTap: () => _scrollToSection(i),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text('F',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FLogo Generator',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                  Text('v${widget.version} · ${widget.effectiveDate}',
                      style: const TextStyle(fontSize: 12, color: AppColors.text3)),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.footerIcon, size: 18, color: widget.footerIconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.footerNote,
                  style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PageBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const PageBadge({super.key, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TocRow extends StatefulWidget {
  final int index;
  final String title;
  final bool isLast;
  final VoidCallback onTap;
  const _TocRow({required this.index, required this.title, required this.isLast, required this.onTap});

  @override
  State<_TocRow> createState() => _TocRowState();
}

class _TocRowState extends State<_TocRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: widget.isLast
                ? null
                : const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text('${widget.index}',
                    style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: _hovering ? AppColors.text : AppColors.text2,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18,
                  color: _hovering ? AppColors.accent : AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  final int index;
  final LegalSection section;
  final bool expanded;
  final VoidCallback onTap;

  const _AccordionCard({
    required this.index,
    required this.section,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text('$index',
                        style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: AppColors.text2),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 14),
                  for (var i = 0; i < section.paragraphs.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == section.paragraphs.length - 1 ? 0 : 12),
                      child: Text(
                        section.paragraphs[i],
                        style: const TextStyle(fontSize: 13.5, color: AppColors.text2, height: 1.7),
                      ),
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
