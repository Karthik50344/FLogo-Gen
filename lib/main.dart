import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'data/articles_content.dart';
import 'models/app_state.dart';
import 'screens/article_screen.dart';
import 'screens/guides_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_conditions_screen.dart';
import 'screens/user_guide_screen.dart';
import 'theme/app_colors.dart';

/// Route name → human-readable page title for every *static* route, used
/// for the <title> tag (SEO/browser tab). Article routes (/guides/<slug>)
/// aren't listed here — their title is looked up from kArticles instead,
/// see _TitleRouteObserver below. Keep this in sync with the `routes` map.
const Map<String, String> kRouteTitles = {
  '/': 'FLogo Generator — Free Flutter App Icon Generator',
  '/privacy-policy': 'Privacy Policy · FLogo Generator',
  '/terms': 'Terms & Conditions · FLogo Generator',
  '/user-guide': 'User Guide · FLogo Generator',
  '/guides': 'Guides & Articles · FLogo Generator',
};

/// Keeps `document.title` in sync with whichever route is on top of the
/// stack — including on "back" navigation, when the revealed route's
/// widget isn't necessarily rebuilt.
class _TitleRouteObserver extends NavigatorObserver {
  void _apply(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;

    if (kRouteTitles.containsKey(name)) {
      html.document.title = kRouteTitles[name]!;
      return;
    }

    if (name.startsWith('/guides/')) {
      final slug = name.substring('/guides/'.length);
      final matches = kArticles.where((a) => a.slug == slug);
      if (matches.isNotEmpty) {
        html.document.title = '${matches.first.title} · FLogo Generator';
      }
    }
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
        title: kRouteTitles['/']!,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [_TitleRouteObserver()],
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
        // kRouteTitles above, and web/sitemap.xml whenever a page is
        // added or renamed.
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/terms': (context) => const TermsConditionsScreen(),
          '/user-guide': (context) => const UserGuideScreen(),
          '/guides': (context) => const GuidesListScreen(),
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
