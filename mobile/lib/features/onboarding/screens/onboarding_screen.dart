import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/router/route_names.dart';
import '../../../widgets/buttons/bc_primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    context.push(RouteNames.roleSelect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.neon
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: AppColors.ink,
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Bottom controls
                  if (_currentPage == 2)
                    BCPrimaryButton.neon(
                      label: 'Let\'s Go →',
                      onPressed: _skip,
                      isFullWidth: true,
                    )
                  else
                    Row(
                      children: [
                        TextButton(
                          onPressed: _skip,
                          child: Text(
                            'Skip',
                            style: AppTypography.buttonMD.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const Spacer(),
                        BCPrimaryButton.dark(
                          label: 'Next →',
                          onPressed: _nextPage,
                          isFullWidth: false,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 1: Find collabs that pay
class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustrated area (55%)
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              // Background blob
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.neon.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Neo-brutalist creator card mockup
              Center(
                child: Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(top: 80),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.ink,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                      boxShadow: AppShadows.neon,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.pink.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull),
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '🎨',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 12,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: AppColors.ink,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 10,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.muted,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 8,
                          width: 180,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neon,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            '₹500-2K',
                            style: AppTypography.labelXS.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content area (45%)
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find collabs\nthat pay.',
                  style: AppTypography.displayMD.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Brands are looking for creators just like you — from nano to macro. Real collabs, real money, starting at ₹100.',
                  style: AppTypography.bodyMD.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Page 2: Brands bid for YOU
class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustrated area (55%)
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              // Background blob
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.pink.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Two cards side by side
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand campaign card (pink shadow)
                      Transform.rotate(
                        angle: -0.08,
                        child: _buildMiniCard(
                          shadow: AppShadows.pink,
                          emoji: '🏢',
                          width: 130,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Creator bid card (blue shadow)
                      Transform.rotate(
                        angle: 0.08,
                        child: _buildMiniCard(
                          shadow: AppShadows.blue,
                          emoji: '💬',
                          width: 130,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content area (45%)
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brands bid\nfor YOU.',
                  style: AppTypography.displayMD.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Post a campaign or browse creators. Privacy protected — full details only unlock when both sides say yes.',
                  style: AppTypography.bodyMD.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required List<BoxShadow> shadow,
    required String emoji,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.ink,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        boxShadow: shadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: AppColors.ink,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// Page 3: IRL invites. Digital tickets.
class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustrated area (55%)
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              // Background blob
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Ticket card with fake QR
              Center(
                child: Transform.rotate(
                  angle: -0.03,
                  child: Container(
                    width: 260,
                    margin: const EdgeInsets.only(top: 44),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.ink,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                      boxShadow: AppShadows.purpleLarge,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 150,
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Fake QR code grid
                        Container(
                          width: 108,
                          height: 108,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.ink,
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSM),
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                            itemCount: 64,
                            itemBuilder: (context, index) {
                              // Create a pseudo-random pattern
                              final shouldFill =
                                  (index * 7 + index ~/ 8 * 13) % 3 == 0;
                              return Container(
                                decoration: BoxDecoration(
                                  color:
                                      shouldFill ? AppColors.ink : Colors.white,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            'ADMIT ONE',
                            style: AppTypography.labelSM.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content area (45%)
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IRL invites.\nDigital tickets.',
                  style: AppTypography.displayMD.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Get invited to brand events and receive a digital entry pass right inside the app. No printing needed.',
                  style: AppTypography.bodyMD.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
