import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/collab_chat.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../creator/shared/widgets/creator_design_system.dart';

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
    required String this.collabId,
  })  : preview = null;

  const ProfileViewSheet.fromPreview({
    super.key,
    required ProfileSheetPreviewData this.preview,
  })  : collabId = null;

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
    final avatarUrl = preview?.avatarUrl ?? chat?.otherPartyAvatar;
    final partnerRole = preview?.partnerRole ?? (role == 'brand' ? 'creator' : 'brand');
    final profileTier = preview?.tier ?? partnerNiche;
    final profileBio = partnerNiche?.trim().isNotEmpty == true
        ? partnerNiche
        : partnerCategory;

    final isBrandView = role == 'brand';
    final accentColor = isBrandView ? AppColors.pink : AppColors.neon;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 1,
      minChildSize: 0.55,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(
              color: AppColors.creatorDark.withValues(alpha: 0.14),
              width: 1.2,
            ),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.creatorDark.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.creatorDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor,
                          width: 2.4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.transparent,
                        backgroundImage: (avatarUrl ?? '').trim().isNotEmpty
                            ? NetworkImage(avatarUrl!.trim())
                            : null,
                        child: (avatarUrl ?? '').trim().isNotEmpty
                            ? null
                            : Text(
                                partnerName.isNotEmpty
                                    ? partnerName.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      partnerFullName,
                      style: AppTypography.labelLG.copyWith(
                        color: AppColors.creatorDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InlineTonePill(
                      label: partnerUsername != null &&
                              partnerUsername.trim().isNotEmpty
                          ? '@$partnerUsername'
                          : role == 'brand'
                              ? 'Creator'
                              : 'Brand',
                      accent: AppColors.creatorDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.creatorDark.withValues(alpha: 0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.creatorDark.withValues(alpha: 0.06),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.creatorDark.withValues(alpha: 0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.creatorDark.withValues(alpha: 0.06),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: AppTypography.labelMD.copyWith(color: AppColors.creatorDark)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      partnerNiche?.trim().isNotEmpty == true
                          ? partnerNiche!
                          : (partnerCategory?.trim().isNotEmpty == true)
                              ? partnerCategory!
                              : 'No additional profile details available yet.',
                      style: AppTypography.bodySM.copyWith(color: AppColors.creatorDark),
                    ),
                  ],
                ),
              ),
              if ((partnerState ?? '').trim().isNotEmpty ||
                  (partnerCity ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.creatorDark.withValues(alpha: 0.14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.creatorDark.withValues(alpha: 0.06),
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.creatorDark.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (partnerCity ?? '').trim().isNotEmpty
                              ? '$partnerCity, ${partnerState ?? ''}'
                              : (partnerState ?? ''),
                          style: AppTypography.bodySM.copyWith(color: AppColors.creatorDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.creatorDark,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'View Full Profile',
                    style: AppTypography.labelMD.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
        Text(
          label,
          style: AppTypography.bodyXS.copyWith(
            color: AppColors.creatorDark.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.labelMD.copyWith(
            color: AppColors.creatorDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
