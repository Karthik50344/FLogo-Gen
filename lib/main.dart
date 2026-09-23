import 'dart:html' as html;

import 'package:flogo/services/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
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

/// Route path → (title, meta description) for every *static* route. Used
/// both for the <title> tag and the <meta name="description"> tag, so
/// every crawlable page gets unique SEO metadata instead of every route
/// inheriting the homepage's tags from index.html. Article routes
/// (/guides/<slug>) aren't listed here — their copy comes from kArticles
/// instead, see _applySeo below. Keep this in sync with the GoRouter
/// `routes` list below, widgets/site_nav_bar.dart, and web/sitemap.xml.
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
/// link in sync with whichever route is current — called from every
/// route's `builder` below (including on back/forward), which is what
/// gives a Flutter Web SPA per-route SEO metadata despite having a single
/// static index.html.
void _applySeo(String path, {String? title, String? description}) {
  if (title == null && kRouteSeo.containsKey(path)) {
    (title, description) = kRouteSeo[path]!;
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
      ?.setAttribute('href', '$kSiteOrigin$path');
  html.document
      .querySelector('meta[property="og:url"]')
      ?.setAttribute('content', '$kSiteOrigin$path');
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  // Unknown route: fall back to Home rather than a blank/error page.
  errorBuilder: (context, state) => const HomeScreen(),
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        _applySeo('/');
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      builder: (context, state) {
        _applySeo('/privacy-policy');
        return const PrivacyPolicyScreen();
      },
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) {
        _applySeo('/terms');
        return const TermsConditionsScreen();
      },
    ),
    GoRoute(
      path: '/user-guide',
      name: 'user-guide',
      builder: (context, state) {
        _applySeo('/user-guide');
        return const UserGuideScreen();
      },
    ),
    GoRoute(
      path: '/guides',
      name: 'guides',
      builder: (context, state) {
        _applySeo('/guides');
        return const GuidesListScreen();
      },
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      builder: (context, state) {
        _applySeo('/about');
        return const AboutScreen();
      },
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) {
        _applySeo('/contact');
        return const ContactScreen();
      },
    ),
    // Dynamic /guides/<slug> article routes — one Article, one URL,
    // without hand-writing a named route per article above.
    GoRoute(
      path: '/guides/:slug',
      name: 'article',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final matches = kArticles.where((a) => a.slug == slug);
        if (matches.isEmpty) {
          _applySeo('/');
          return const HomeScreen();
        }
        final article = matches.first;
        _applySeo('/guides/$slug',
            title: '${article.title} · FLogo Generator',
            description: article.metaDescription);
        return ArticleScreen(article: article);
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean, path-based URLs (yoursite.com/privacy-policy) instead of
  // Flutter's default hash-based ones (yoursite.com/#/privacy-policy).
  // Hash fragments are effectively invisible to search engines, so this
  // one call matters more for SEO than anything in <head>.
  usePathUrlStrategy();
  await DeviceInfo.loadDeviceInfo();
  runApp(const FlutterLogoGeneratorApp());
}

class FlutterLogoGeneratorApp extends StatelessWidget {
  const FlutterLogoGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp.router(
        title: kRouteSeo['/']!.$1,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
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
      ),
    );
  }
}
