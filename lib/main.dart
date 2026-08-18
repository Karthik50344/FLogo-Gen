import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'data/articles_content.dart';
import 'models/app_state.dart';
import 'screens/about_screen.dart';
import 'screens/article_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/guides_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_conditions_screen.dart';
import 'screens/user_guide_screen.dart';
import 'theme/app_colors.dart';

const String kSiteOrigin = 'https://flogo-gen.web.app';

/// Route name → (title, meta description) for every *static* route. Used
/// both for the <title> tag and the <meta name="description"> tag, so
/// every crawlable page gets unique SEO metadata instead of every route
/// inheriting the homepage's tags from index.html. Article routes
/// (/guides/<slug>) aren't listed here — their copy comes from kArticles
/// instead, see _SeoRouteObserver below. Keep this in sync with the
/// `routes` map, widgets/site_nav_bar.dart, and web/sitemap.xml.
const Map<String, (String title, String description)> kRouteSeo = {
  '/': (
    'FLogo Generator — Free Flutter App Icon Generator',
    'Generate Flutter app icons for Android, iOS, Web, Windows, macOS, and '
        'Linux from one logo. Resize, package, and download your icons '
        'entirely in your browser — nothing is ever uploaded.',
  ),
  '/privacy-policy': (
    'Privacy Policy · FLogo Generator',
    'What FLogo Generator does and does not collect, how your uploaded '
        'image is processed locally, and how advertising on this site is '
        'handled.',
  ),
  '/terms': (
    'Terms & Conditions · FLogo Generator',
    'The terms that apply to using FLogo Generator, including acceptable '
        'use, intellectual property, and limitation of liability.',
  ),
  '/user-guide': (
    'User Guide · FLogo Generator',
    'Learn how to generate, download, and use Flutter app icons for '
        'Android, iOS, Web, Windows, macOS, and Linux — step by step.',
  ),
  '/guides': (
    'Guides & Articles · FLogo Generator',
    'App icon sizing, Android adaptive icons, iOS icon requirements, '
        'notification icons, and other Flutter icon guides.',
  ),
  '/about': (
    'About FLogo Generator',
    'Learn why FLogo Generator was created, how it works, and how it '
        'handles your images and privacy.',
  ),
  '/contact': (
    'Contact · FLogo Generator',
    'Get in touch about bugs, feature requests, privacy questions, or '
        'general feedback for FLogo Generator.',
  ),
};

/// Keeps `document.title`, the meta-description tag, and the canonical
/// link in sync with whichever route is on top of the stack — including
/// on "back" navigation, when the revealed route's widget isn't
/// necessarily rebuilt. This is what gives a Flutter Web SPA per-route
/// SEO metadata despite having a single static index.html.
class _SeoRouteObserver extends NavigatorObserver {
  void _apply(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;

    String? title;
    String? description;

    if (kRouteSeo.containsKey(name)) {
      (title, description) = kRouteSeo[name]!;
    } else if (name.startsWith('/guides/')) {
      final slug = name.substring('/guides/'.length);
      final matches = kArticles.where((a) => a.slug == slug);
      if (matches.isNotEmpty) {
        title = '${matches.first.title} · FLogo Generator';
        description = matches.first.metaDescription;
      }
    }

    if (title == null) return;
    html.document.title = title;

    if (description != null) {
      html.document
          .querySelector('meta[name="description"]')
          ?.setAttribute('content', description);
      html.document
          .querySelector('meta[property="og:description"]')
          ?.setAttribute('content', description);
    }
    html.document
        .querySelector('meta[property="og:title"]')
        ?.setAttribute('content', title);
    html.document
        .querySelector('link[rel="canonical"]')
        ?.setAttribute('href', '$kSiteOrigin$name');
    html.document
        .querySelector('meta[property="og:url"]')
        ?.setAttribute('content', '$kSiteOrigin$name');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _apply(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _apply(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _apply(newRoute);
}

void main() {
  // Clean, path-based URLs (yoursite.com/privacy-policy) instead of
  // Flutter's default hash-based ones (yoursite.com/#/privacy-policy).
  // Hash fragments are effectively invisible to search engines, so this
  // one call matters more for SEO than anything in <head>.
  usePathUrlStrategy();
  runApp(const FlutterLogoGeneratorApp());
}

class FlutterLogoGeneratorApp extends StatelessWidget {
  const FlutterLogoGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: kRouteSeo['/']!.$1,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [_SeoRouteObserver()],
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bg,
          fontFamily: 'SpaceGrotesk',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.dark,
            surface: AppColors.surface,
          ),
        ),
        // Named routes give every page a real, bookmarkable, crawlable
        // URL. Keep this map in sync with widgets/app_footer.dart's links,
        // widgets/site_nav_bar.dart's kNavItems, kRouteSeo above, and
        // web/sitemap.xml whenever a page is added or renamed.
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/terms': (context) => const TermsConditionsScreen(),
          '/user-guide': (context) => const UserGuideScreen(),
          '/guides': (context) => const GuidesListScreen(),
          '/about': (context) => const AboutScreen(),
          '/contact': (context) => const ContactScreen(),
        },
        // Dynamic /guides/<slug> article routes — one Article, one URL,
        // without hand-writing a named route per article above.
        onGenerateRoute: (settings) {
          final name = settings.name ?? '';
          if (name.startsWith('/guides/')) {
            final slug = name.substring('/guides/'.length);
            final matches = kArticles.where((a) => a.slug == slug);
            if (matches.isNotEmpty) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => ArticleScreen(article: matches.first),
              );
            }
          }
          // Unknown route: fall back to Home rather than a blank/error page.
          return MaterialPageRoute(
            settings: const RouteSettings(name: '/'),
            builder: (context) => const HomeScreen(),
          );
        },
      ),
    );
  }
}
