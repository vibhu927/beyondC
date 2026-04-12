import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
import '../../widgets/buttons/bc_primary_button.dart';
import '../../widgets/cards/bc_card.dart';

void openProfileViewSheet(BuildContext context, String collabId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProfileViewSheet.fromCollab(collabId: collabId),
  );
}

void openProfilePreviewSheet(
  BuildContext context, {
  required ProfileSheetPreviewData preview,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProfileViewSheet.fromPreview(preview: preview),
  );
}

class ProfileSheetPreviewData {
  const ProfileSheetPreviewData({
    required this.partnerId,
    required this.viewerRole,
    required this.partnerRole,
    required this.name,
    this.fullName,
    this.avatarUrl,
    this.instagramUsername,
    this.amountInr,
    this.collabType,
    this.niche,
    this.category,
    this.state,
    this.city,
    this.tier,
    this.followers,
  });

  final String partnerId;
  final String viewerRole;
  final String partnerRole;
  final String name;
  final String? fullName;
  final String? avatarUrl;
  final String? instagramUsername;
  final int? amountInr;
  final String? collabType;
  final String? niche;
  final String? category;
  final String? state;
  final String? city;
  final String? tier;
  final int? followers;
}

class ProfileViewSheet extends ConsumerWidget {
  const ProfileViewSheet.fromCollab({
    super.key,
    required String collabId,
  })  : collabId = collabId,
        preview = null;

  const ProfileViewSheet.fromPreview({
    super.key,
    required ProfileSheetPreviewData preview,
  })  : preview = preview,
        collabId = null;

  final String? collabId;
  final ProfileSheetPreviewData? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = preview?.viewerRole ?? ref.watch(authProvider.select((a) => a.role)) ?? 'creator';
    final chatState = ref.watch(chatListProvider).valueOrNull;
    final chat = collabId == null ? null : _findChat(chatState, collabId!);

    final partnerId = preview?.partnerId ?? chat?.otherPartyId;
    final partnerName = preview?.name ?? chat?.otherPartyName ?? 'Profile';
    final partnerFullName = preview?.fullName ?? chat?.otherPartyFullName ?? partnerName;
    final partnerUsername = preview?.instagramUsername ?? chat?.otherPartyInstagramUsername;
    final partnerNiche = preview?.niche ?? chat?.otherPartyNiche;
    final partnerCategory = preview?.category ?? chat?.otherPartyCategory;
    final partnerState = preview?.state ?? chat?.otherPartyState;
    final partnerCity = preview?.city ?? chat?.otherPartyCity;
    final amountInr = preview?.amountInr ?? chat?.agreedAmount;
    final collabType = preview?.collabType ?? chat?.collabType;
    final avatarUrl = preview?.avatarUrl;
    final partnerRole = preview?.partnerRole ?? (role == 'brand' ? 'creator' : 'brand');
    final profileTier = preview?.tier ?? partnerNiche;
    final profileBio = partnerNiche?.trim().isNotEmpty == true
        ? partnerNiche
        : partnerCategory;

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
                        backgroundImage: (avatarUrl ?? '').trim().isNotEmpty
                            ? NetworkImage(avatarUrl!.trim())
                            : null,
                        child: (avatarUrl ?? '').trim().isNotEmpty
                            ? null
                            : Text(
                                partnerName.isNotEmpty
                                    ? partnerName.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: AppTypography.displaySM,
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      partnerFullName,
                      style: AppTypography.labelLG.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      partnerUsername != null && partnerUsername.trim().isNotEmpty
                          ? '@$partnerUsername'
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
                      child: _miniStat('Amount', Formatters.currencyFromINR((amountInr ?? 0))),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _miniStat('Type', (collabType ?? 'paid').toUpperCase()),
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
                      partnerNiche?.trim().isNotEmpty == true
                          ? partnerNiche!
                          : (partnerCategory?.trim().isNotEmpty == true)
                              ? partnerCategory!
                              : 'No additional profile details available yet.',
                      style: AppTypography.bodySM,
                    ),
                  ],
                ),
              ),
              if ((partnerState ?? '').trim().isNotEmpty ||
                  (partnerCity ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                BCCard(
                  shadow: AppShadows.blue,
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.location_on_rounded,
                        size: 14,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (partnerCity ?? '').trim().isNotEmpty
                              ? '$partnerCity, ${partnerState ?? ''}'
                              : (partnerState ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              BCPrimaryButton.dark(
                label: 'View Full Profile ->',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(
                    RouteNames.partnerProfile,
                    extra: {
                      'id': partnerId,
                      'collabId': chat?.id,
                      'name': partnerFullName,
                      'full_name': partnerFullName,
                      'avatar_url': avatarUrl,
                      'avatarUrl': avatarUrl,
                      'role': partnerRole,
                      'viewerRole': role,
                      'tier': profileTier,
                      'bio': profileBio,
                      'followers': preview?.followers,
                      'readOnly': true,
                    },
                  );
                },
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
