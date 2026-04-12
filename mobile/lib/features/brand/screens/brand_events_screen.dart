import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class BrandEventsScreen extends ConsumerStatefulWidget {
  const BrandEventsScreen({super.key});

  @override
  ConsumerState<BrandEventsScreen> createState() => _BrandEventsScreenState();
}

class _BrandEventsScreenState extends ConsumerState<BrandEventsScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(brandProvider.notifier).fetchBrandHome();
      if (!mounted) return;
      await ref.read(brandProvider.notifier).fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandProvider);
    final upcoming = state.upcomingEvents;
    final past = state.pastEvents;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Events', style: AppTypography.displaySM),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.createEvent),
            icon: const Icon(Symbols.add_rounded, color: AppColors.ink),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.createEvent),
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        child: const Icon(Symbols.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        children: [
          const Text('Upcoming Events', style: AppTypography.displaySM),
          const SizedBox(height: AppSpacing.md),
          if (state.isEventsLoading)
            const _EventsShimmerList()
          else if (upcoming.isEmpty && past.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
              child: Text(
                '🎟️ No events yet.\nHost your first brand event!',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
              ),
            )
          else ...[
            for (final event in upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _EventCard(
                  event: event,
                  isPast: false,
                  onManageInvites: () => context.push(
                    RouteNames.eventInvites.replaceFirst(':id', event.id),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Past Events', style: AppTypography.displaySM),
            const SizedBox(height: AppSpacing.md),
            for (final event in past)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _EventCard(
                  event: event,
                  isPast: true,
                  onManageInvites: () => context.push(
                    RouteNames.eventInvites.replaceFirst(':id', event.id),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.isPast,
    required this.onManageInvites,
  });

  final BrandEvent event;
  final bool isPast;
  final VoidCallback onManageInvites;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: isPast ? const [] : AppShadows.purple,
      backgroundColor: isPast ? AppColors.surfaceAlt : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(event.name, style: AppTypography.labelLG),
              ),
              if (isPast)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: const Text('Completed', style: AppTypography.labelXS),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    event.eventType,
                    style:
                        AppTypography.labelXS.copyWith(color: AppColors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${DateFormat('d MMM, h:mm a').format(event.dateTime)}  •  ${event.city ?? 'Virtual'}',
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Container(
              height: 8,
              color: AppColors.ink,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: event.totalSlots == 0
                    ? 0
                    : event.filledSlots / event.totalSlots,
                child: const ColoredBox(color: AppColors.neon),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${event.filledSlots} / ${event.totalSlots} slots filled',
            style: AppTypography.bodyXS,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${event.invitesSent} invites sent · ${event.invitesAccepted} accepted',
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: isPast
                ? BCPrimaryButton.neon(
                    label: 'View Invites →',
                    isFullWidth: false,
                    onPressed: onManageInvites,
                  )
                : OutlinedButton(
                    onPressed: onManageInvites,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.purple, width: 2),
                      foregroundColor: AppColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMD),
                      ),
                    ),
                    child: const Text('Manage Invites →'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventsShimmerList extends StatelessWidget {
  const _EventsShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightDivider,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceAlt
                : AppColors.lightSurfaceAlt,
            child: BCCard(
              child: Column(
                children: [
                  Container(height: 18, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 14, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 8, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 32, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
