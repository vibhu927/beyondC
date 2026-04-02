import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/collab_chat.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/cards/bc_card.dart';

void openProfileViewSheet(BuildContext context, String collabId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProfileViewSheet(collabId: collabId),
  );
}

class ProfileViewSheet extends ConsumerWidget {
  const ProfileViewSheet({super.key, required this.collabId});

  final String collabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((a) => a.role)) ?? 'creator';
    final state = ref.watch(chatListProvider).valueOrNull;
    final chat = _findChat(state, collabId);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 1,
      minChildSize: 0.55,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: role == 'brand' ? AppColors.neon : AppColors.pink,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          (chat?.otherPartyName ?? 'U').substring(0, 1).toUpperCase(),
                          style: AppTypography.displaySM,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      chat?.otherPartyFullName ?? chat?.otherPartyName ?? 'Profile',
                      style: AppTypography.labelLG.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      chat?.otherPartyInstagramUsername != null
                          ? '@${chat!.otherPartyInstagramUsername}'
                          : role == 'brand'
                              ? 'Creator'
                              : 'Brand',
                      style: AppTypography.bodySM.copyWith(color: AppColors.darkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BCCard(
                shadow: AppShadows.neon,
                child: Row(
                  children: [
                    Expanded(
                      child: _miniStat('Amount', Formatters.currencyFromINR((chat?.agreedAmount ?? 0))),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _miniStat('Type', (chat?.collabType ?? 'paid').toUpperCase()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BCCard(
                shadow: AppShadows.pink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About', style: AppTypography.labelMD),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      chat?.otherPartyNiche?.trim().isNotEmpty == true
                          ? chat!.otherPartyNiche!
                          : (chat?.otherPartyCategory?.trim().isNotEmpty == true)
                              ? chat!.otherPartyCategory!
                              : 'No additional profile details available yet.',
                      style: AppTypography.bodySM,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(
                    RouteNames.partnerProfile,
                    extra: {
                      'id': chat?.otherPartyId,
                      'collabId': chat?.id,
                      'name': chat?.otherPartyFullName ?? chat?.otherPartyName ?? 'Partner',
                      'role': role == 'brand' ? 'creator' : 'brand',
                      'viewerRole': role,
                      'tier': chat?.otherPartyNiche,
                      'bio': chat?.otherPartyCategory,
                      'followers': null,
                      'readOnly': true,
                    },
                  );
                },
                child: const Text('View Full Profile ->'),
              ),
            ],
          ),
        );
      },
    );
  }

  CollabChat? _findChat(ChatListResult? state, String id) {
    if (state == null) return null;
    for (final item in state.active) {
      if (item.id == id) return item;
    }
    for (final item in state.archived) {
      if (item.id == id) return item;
    }
    return null;
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyXS.copyWith(color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTypography.labelMD),
      ],
    );
  }
}
