import 'package:flutter/material.dart';

import '../data/contact_info.dart';
import '../services/download_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/site_nav_bar.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SiteNavBar(showBack: true),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                    child: Column(
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
                          child: const Icon(Icons.mail_outline, color: AppColors.accent, size: 26),
                        ),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
                          child: const Text(
                            'Contact',
                            style: TextStyle(
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
                          child: const Text(
                            'FLogo Generator is maintained by a single developer, so every '
                            'message is read directly — there\'s no support ticket system '
                            'or automated reply. Pick the category that fits best and it\'ll '
                            'open your mail client with the subject line pre-filled; feel '
                            'free to rewrite it however you like.',
                            style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _EmailCard(),
                        const SizedBox(height: 28),
                        const Text(
                          'What kind of message is this?',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(builder: (context, constraints) {
                          final columns = constraints.maxWidth > 700 ? 2 : 1;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              for (final category in kContactCategories)
                                SizedBox(
                                  width: columns == 2 ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth,
                                  child: _CategoryCard(category: category),
                                ),
                            ],
                          );
                        }),
                        const SizedBox(height: 28),
                        _NotePanel(),
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
}

class _EmailCard extends StatefulWidget {
  @override
  State<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<_EmailCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => DownloadHelper.openMailto(kContactEmail, subject: 'FLogo Generator — Contact'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: _hovering ? AppColors.accent.withOpacity(0.4) : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.email_outlined, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email directly',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(kContactEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: _hovering ? AppColors.accent : AppColors.text2,
                          decoration: _hovering ? TextDecoration.underline : TextDecoration.none,
                        )),
                  ],
                ),
              ),
              Icon(Icons.arrow_outward, size: 18, color: _hovering ? AppColors.accent : AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final ContactCategory category;
  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => DownloadHelper.openMailto(kContactEmail, subject: widget.category.subject),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: _hovering ? AppColors.border2 : AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(widget.category.icon, color: AppColors.accent, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.category.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _hovering ? AppColors.accent : AppColors.text,
                        )),
                    const SizedBox(height: 6),
                    Text(widget.category.description,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.text2, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_outlined, size: 18, color: AppColors.success),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a side project maintained in spare time, so replies aren\'t '
              'instant — but every message does get read. For bug reports, '
              'including your browser and the platform(s) you selected helps a lot.',
              style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
