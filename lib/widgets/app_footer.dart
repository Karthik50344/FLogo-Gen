import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/contact_info.dart';
import '../services/device_info.dart';
import '../services/download_helper.dart';
import '../theme/app_colors.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('F',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            const Text(
              'FLogo Generator',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '© 2026 · Open source · MIT Licence',
          style: TextStyle(fontSize: 12, color: AppColors.text3),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            _FooterLink(
              icon: Icons.auto_stories_outlined,
              label: 'Guides & Articles',
              onTap: () => context.push('/guides'),
            ),
            const _Dot(),
            _FooterLink(
              icon: Icons.menu_book_outlined,
              label: 'User Guide',
              onTap: () => context.push('/user-guide'),
            ),
            const _Dot(),
            _FooterLink(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => context.push('/about'),
            ),
            const _Dot(),
            _FooterLink(
              icon: Icons.mail_outline,
              label: 'Contact',
              onTap: () => context.push('/contact'),
            ),
            const _Dot(),
            _FooterLink(
              icon: Icons.shield_outlined,
              label: 'Privacy Policy',
              onTap: () => context.push('/privacy-policy'),
            ),
            const _Dot(),
            _FooterLink(
              icon: Icons.gavel_outlined,
              label: 'Terms & Conditions',
              onTap: () => context.push('/terms'),
            ),
            const _Dot(),
            const _FooterStatus(),
          ],
        ),
        const SizedBox(height: 24),
        const _ContactBlock(),
        const SizedBox(height: 10),
        _VersionBlock(version: DeviceInfo.version, buildNo: DeviceInfo.buildNumber)
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text('·', style: TextStyle(color: AppColors.text3, fontSize: 13)),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.icon, required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 14, color: _hovering ? AppColors.accent : AppColors.text2),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.5,
                color: _hovering ? AppColors.accent : AppColors.text2,
                decoration: _hovering ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStatus extends StatelessWidget {
  const _FooterStatus();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.lock_outline, size: 14, color: AppColors.success),
        SizedBox(width: 6),
        Text(
          'Your logo never leaves your device',
          style: TextStyle(fontSize: 12.5, color: AppColors.success, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// "Contact Us" label with the email address shown directly beneath it —
/// tapping either opens the user's mail client via a mailto: link.
class _ContactBlock extends StatefulWidget {
  const _ContactBlock();

  @override
  State<_ContactBlock> createState() => _ContactBlockState();
}

class _ContactBlockState extends State<_ContactBlock> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => DownloadHelper.openMailto(
          kContactEmail,
          subject: 'FLogo Generator — Support',
        ),
        child: Column(
          children: [
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _hovering ? AppColors.accent : AppColors.text2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline, size: 13, color: _hovering ? AppColors.accent : AppColors.text3),
                const SizedBox(width: 6),
                Text(
                  kContactEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: _hovering ? AppColors.accent : AppColors.text3,
                    decoration: _hovering ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///Shows the current application version with build no.
class _VersionBlock extends StatelessWidget {
  final String version;
  final String buildNo;
  const _VersionBlock({super.key, required this.version, required this.buildNo});

  @override
  Widget build(BuildContext context) {
    return Text(
      "V$version ($buildNo)",
      style: TextStyle(
        fontSize: 12,
        color: AppColors.text3,
        decoration: TextDecoration.none,
      ),
    );
  }
}

