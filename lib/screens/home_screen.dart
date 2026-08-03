import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../widgets/faq_section.dart';
import '../widgets/generate_button.dart';
import '../widgets/guides_teaser_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/loader_overlay.dart';
import '../widgets/options_card.dart';
import '../widgets/output_tree_card.dart';
import '../widgets/platform_grid_card.dart';
import '../widgets/theme_card.dart';
import '../widgets/upload_card.dart';
import '../widgets/why_use_section.dart';
import 'grid_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: GridBackground()),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, outerConstraints) {
                  // No max-width cap: content fills the available screen
                  // width. Padding scales up a bit on larger screens so
                  // cards don't run edge-to-edge on huge monitors.
                  final screenWidth = outerConstraints.maxWidth;
                  final hPad = screenWidth < 700
                      ? 24.0
                      : (screenWidth < 1100 ? 40.0 : 64.0);

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 60),
                    child: Column(
                      children: [
                        const AppHeader(),
                        const SizedBox(height: 52),
                        LayoutBuilder(builder: (context, constraints) {
                          final wide = constraints.maxWidth > 640;
                          // Width each card actually gets once split into
                          // the two-column layout, so the grid/field
                          // column counts below match reality instead of
                          // guessing off the full row width.
                          final cardWidth =
                              wide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;

                          // Always 2 rows of 3 (never collapse to a single
                          // row of 6, even on wide screens) — only drop to
                          // 2-per-row on genuinely narrow cards.
                          final platformColumns = cardWidth < 360 ? 2 : 3;
                          final themeTwoCols = cardWidth > 380;

                          const upload = UploadCard();
                          final platforms = PlatformGridCard(columns: platformColumns);
                          const options = OptionsCard();
                          final themeCard = ThemeCard(twoColumnFields: themeTwoCols);

                          if (!wide) {
                            return Column(
                              children: [
                                upload,
                                const SizedBox(height: 20),
                                platforms,
                                const SizedBox(height: 20),
                                options,
                                const SizedBox(height: 20),
                                themeCard,
                              ],
                            );
                          }

                          return Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: upload),
                                    const SizedBox(width: 20),
                                    Expanded(child: platforms),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: options),
                                    const SizedBox(width: 20),
                                    Expanded(child: themeCard),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 20),
                        const OutputTreeCard(),
                        const SizedBox(height: 28),
                        const GenerateButton(),
                        const SizedBox(height: 80),
                        // Long-form landing-page content below the tool
                        // itself — capped to a readable width even though
                        // the generator UI above uses the full screen.
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: const Column(
                              children: [
                                HowItWorksSection(),
                                SizedBox(height: 64),
                                WhyUseSection(),
                                SizedBox(height: 64),
                                GuidesTeaserSection(),
                                SizedBox(height: 64),
                                FaqSection(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 56),
                        const AppFooter(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const LoaderOverlay(),
        ],
      ),
    );
  }
}
