import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class EventInvitesScreen extends ConsumerStatefulWidget {
  const EventInvitesScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  ConsumerState<EventInvitesScreen> createState() => _EventInvitesScreenState();
}

class _EventInvitesScreenState extends ConsumerState<EventInvitesScreen> {
  int _tabIndex = 0;
  bool _locationFilter = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(brandProvider.notifier).fetchBrandHome();
      if (!mounted) return;
      await ref.read(brandProvider.notifier).fetchEvents();
      if (!mounted) return;
      await ref.read(brandProvider.notifier).fetchEventInvites(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandProvider);
    final event = state.events
        .where((item) => item.id == widget.id)
        .cast<BrandEvent?>()
        .firstOrNull;

    if (event == null && (state.isLoading || state.isEventsLoading)) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text('Event Invites', style: AppTypography.displaySM),
        ),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: _InvitesShimmerList(),
        ),
      );
    }

    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    final invites = ref.read(brandProvider.notifier).invitesForEvent(widget.id);
    final invitedCreatorIds = invites.map((e) => e.creatorId).toSet();

    var eligibleCreators = state.creators.where((creator) {
      final nicheMatch =
          creator.niches.any((niche) => event.targetNiches.contains(niche));
      final tierMatch = event.targetTiers.contains(creator.tier);
      return nicheMatch && tierMatch && !invitedCreatorIds.contains(creator.id);
    }).toList();

    if (_locationFilter && (event.city ?? '').trim().isNotEmpty) {
      eligibleCreators.sort((a, b) {
        final aScore = ((a.city ?? '').toLowerCase() ==
                    (event.city ?? '').toLowerCase()
                ? 2
                : 0) +
            ((a.state ?? '').toLowerCase() ==
                    (event.state ?? '').toLowerCase()
                ? 1
                : 0);
        final bScore = ((b.city ?? '').toLowerCase() ==
                    (event.city ?? '').toLowerCase()
                ? 2
                : 0) +
            ((b.state ?? '').toLowerCase() ==
                    (event.state ?? '').toLowerCase()
                ? 1
                : 0);
        return bScore.compareTo(aScore);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displaySM,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            BCBadge(
              label: DateFormat('d MMM').format(event.dateTime),
              variant: BCBadgeVariant.purple,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        children: [
          BCCard(
            shadow: AppShadows.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('d MMM yyyy, h:mm a').format(event.dateTime)}',
                  style: AppTypography.labelMD,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  event.isVirtual
                      ? 'Venue: Virtual'
                      : 'Venue: ${event.venueName ?? '-'}, ${event.city ?? ''}',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Slots: ${event.filledSlots} / ${event.totalSlots}',
                  style: AppTypography.bodySM,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_tabIndex == 0 && (event.city ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BCCard(
                shadow: AppShadows.purple,
                child: Row(
                  children: [
                    const Icon(Symbols.location_on_rounded,
                        color: AppColors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationFilter
                            ? 'Showing creators from ${event.city} first'
                            : 'Showing all creators',
                        style: AppTypography.bodySM,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _locationFilter = !_locationFilter);
                      },
                      child: Text(
                        _locationFilter ? 'Show All' : 'Prioritize City',
                        style: const TextStyle(color: AppColors.pink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _tabPill(
                  label: 'Invite Creators',
                  active: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _tabPill(
                  label: 'Sent Invites',
                  active: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_tabIndex == 0)
            _InviteTab(
              creators: eligibleCreators,
              onInvite: (creator) => _inviteCreator(event.id, creator),
            )
          else
            _SentInvitesTab(invites: invites),
        ],
      ),
    );
  }

  Future<void> _inviteCreator(String eventId, CreatorPreview creator) async {
    final confirmed = await _showNeoConfirmDialog(
      context,
      title: 'Invite ${creator.firstName}?',
      subtitle: '2 credits will be deducted for this invite.',
      confirmLabel: 'Invite',
    );

    if (!confirmed || !mounted) return;

    final ok = await ref.read(brandProvider.notifier).sendEventInvite(
          eventId: eventId,
          creator: creator,
        );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to send invite. Check credits.')),
      );
      return;
    }

    setState(() => _tabIndex = 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite sent to ${creator.firstName}.')),
    );
  }

  Widget _tabPill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.neon : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _InviteTab extends StatelessWidget {
  const _InviteTab({
    required this.creators,
    required this.onInvite,
  });

  final List<CreatorPreview> creators;
  final ValueChanged<CreatorPreview> onInvite;

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: Text(
          'No more matching creators to invite.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
        ),
      );
    }

    return Column(
      children: creators
          .map(
            (creator) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BCCard(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        creator.initials,
                        style: AppTypography.labelSM
                            .copyWith(color: AppColors.neon),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(creator.firstName, style: AppTypography.labelLG),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${creator.tier} • ${creator.niches.join(', ')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySM
                                .copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '2 credits per invite',
                            style: AppTypography.bodyXS,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    BCPrimaryButton.neon(
                      label: 'Invite →',
                      isFullWidth: false,
                      onPressed: () => onInvite(creator),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SentInvitesTab extends StatelessWidget {
  const _SentInvitesTab({required this.invites});

  final List<EventInvite> invites;

  @override
  Widget build(BuildContext context) {
    if (invites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: Text(
          'No invites sent yet.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMD.copyWith(color: AppColors.muted),
        ),
      );
    }

    return Column(
      children: invites
          .map(
            (invite) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BCCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(invite.creatorFirstName,
                              style: AppTypography.labelLG),
                        ),
                        BCBadge(
                          label: _statusLabel(invite.status),
                          variant: _statusVariant(invite.status),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${invite.tier} tier • Sent ${DateFormat('d MMM').format(invite.sentAt)}',
                      style:
                          AppTypography.bodySM.copyWith(color: AppColors.muted),
                    ),
                    if (invite.status == EventInviteStatus.accepted) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '🎟️ Ticket generated',
                        style: AppTypography.bodySM
                            .copyWith(color: AppColors.success),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      BCPrimaryButton.neon(
                        label: 'View Ticket QR',
                        isFullWidth: false,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ticket QR coming soon.')),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

String _statusLabel(EventInviteStatus status) {
  switch (status) {
    case EventInviteStatus.pending:
      return 'Pending';
    case EventInviteStatus.accepted:
      return 'Accepted';
    case EventInviteStatus.declined:
      return 'Declined';
  }
}

BCBadgeVariant _statusVariant(EventInviteStatus status) {
  switch (status) {
    case EventInviteStatus.pending:
      return BCBadgeVariant.warning;
    case EventInviteStatus.accepted:
      return BCBadgeVariant.neon;
    case EventInviteStatus.declined:
      return BCBadgeVariant.error;
  }
}

Future<bool> _showNeoConfirmDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: BCCard(
          shadow: AppShadows.ink,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.ink, width: 2),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BCPrimaryButton.neon(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _InvitesShimmerList extends StatelessWidget {
  const _InvitesShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
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
                  Container(height: 16, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 14, color: AppColors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 38, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
