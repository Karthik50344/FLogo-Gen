import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NavItemData {
  final String label;
  final String route;
  final IconData icon;
  const NavItemData(this.label, this.route, this.icon);
}

/// Kept in sync with main.dart's `routes` map and web/sitemap.xml —
/// every entry here should be a real, crawlable page.
const List<NavItemData> kNavItems = [
  NavItemData('Home', '/', Icons.home_outlined),
  NavItemData('User Guide', '/user-guide', Icons.menu_book_outlined),
  NavItemData('Guides', '/guides', Icons.auto_stories_outlined),
  NavItemData('About', '/about', Icons.info_outline),
  NavItemData('Contact', '/contact', Icons.mail_outline),
];

/// Site-wide header: logo (links home), a horizontal nav on wide screens
/// or a compact menu on narrow ones, and an optional back button for
/// sub-pages. Used on every screen so the whole site shares one
/// navigation model instead of each page inventing its own app bar.
class SiteNavBar extends StatelessWidget {
  final bool showBack;
  const SiteNavBar({super.key, this.showBack = false});

  void _go(BuildContext context, String route) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 760;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (showBack)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 20),
                ),
              ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _go(context, '/'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text('F',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FLogo Generator',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (wide)
              Row(
                children: [
                  for (final item in kNavItems)
                    _NavLink(item: item, active: item.route == currentRoute, onTap: () => _go(context, item.route)),
                ],
              )
            else
              _MobileNavMenu(currentRoute: currentRoute, onSelect: (route) => _go(context, route)),
          ],
        ),
      );
    });
  }
}

class _NavLink extends StatefulWidget {
  final NavItemData item;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({required this.item, required this.active, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovering;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            widget.item.label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
              color: highlighted ? AppColors.accent : AppColors.text2,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavMenu extends StatelessWidget {
  final String? currentRoute;
  final ValueChanged<String> onSelect;
  const _MobileNavMenu({required this.currentRoute, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      color: AppColors.surface,
      icon: const Icon(Icons.menu, color: AppColors.text),
      onSelected: onSelect,
      itemBuilder: (context) => [
        for (final item in kNavItems)
          PopupMenuItem(
            value: item.route,
            child: Row(
              children: [
                Icon(item.icon,
                    size: 18, color: item.route == currentRoute ? AppColors.accent : AppColors.text2),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: item.route == currentRoute ? AppColors.accent : AppColors.text,
                    fontWeight: item.route == currentRoute ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
