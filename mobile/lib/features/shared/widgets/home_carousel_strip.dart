import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/home_carousel_item.dart';
import '../../../widgets/cards/bc_card.dart';

class HomeCarouselStrip extends StatefulWidget {
  const HomeCarouselStrip({
    super.key,
    required this.items,
    this.height = 140,
  });

  final List<HomeCarouselItem> items;
  final double height;

  @override
  State<HomeCarouselStrip> createState() => _HomeCarouselStripState();
}

class _HomeCarouselStripState extends State<HomeCarouselStrip> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant HomeCarouselStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _index = 0;
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (widget.items.length < 2) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;

      final next = (_index + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (value) {
              if (!mounted) return;
              setState(() => _index = value);
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: BCCard(
                  shadow: AppShadows.blue,
                  backgroundColor: AppColors.white,
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.white,
                            alignment: Alignment.center,
                            child: const Text('Image unavailable'),
                          ),
                        ),
                        if ((item.caption ?? '').trim().isNotEmpty)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              color: Colors.black.withValues(alpha: 0.55),
                              child: Text(
                                item.caption!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSM
                                    .copyWith(color: AppColors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (dotIndex) {
              final active = dotIndex == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? AppColors.ink : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
