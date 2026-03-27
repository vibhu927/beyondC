import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/chat_modal_repository.dart';
import '../badges/bc_badge.dart';
import '../buttons/bc_primary_button.dart';
import '../cards/bc_card.dart';

class RequestTile extends StatelessWidget {
  const RequestTile({
    super.key,
    required this.request,
    required this.isCreator,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
  });

  final ChatModalRequest request;
  final bool isCreator;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final status = request.status.toLowerCase();
    final showCreatorActions = isCreator && request.isIncoming && status == 'pending';
    final showBrandCancel = !isCreator && !request.isIncoming && status == 'pending';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: BCCard(
        shadow: request.isIncoming ? AppShadows.neon : const <BoxShadow>[],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(request.name, style: AppTypography.labelLG),
                ),
                BCBadge(
                  label: request.tier.toUpperCase(),
                  variant: BCBadgeVariant.outline,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                BCBadge(
                  label: Formatters.currency(request.budget),
                  variant: BCBadgeVariant.neon,
                ),
                BCBadge(
                  label: request.collabType,
                  variant: BCBadgeVariant.pink,
                ),
                BCBadge(
                  label: _statusLabel(status),
                  variant: _statusVariant(status),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySM,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.createdAt == null ? 'Just now' : timeago.format(request.createdAt!),
              style: AppTypography.bodyXS,
            ),
            if (showCreatorActions) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: BCPrimaryButton.neon(
                      label: 'Accept ✓',
                      onPressed: () => onAccept(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BCPrimaryButton(
                      label: 'Reject ✗',
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.error,
                      shadow: const <BoxShadow>[],
                      onPressed: () => onReject(),
                    ),
                  ),
                ],
              ),
            ],
            if (showBrandCancel) ...[
              const SizedBox(height: AppSpacing.md),
              BCPrimaryButton(
                label: 'Cancel',
                backgroundColor: Colors.transparent,
                textColor: AppColors.error,
                shadow: const <BoxShadow>[],
                onPressed: () => onCancel(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
      case 'declined':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  BCBadgeVariant _statusVariant(String status) {
    switch (status) {
      case 'accepted':
        return BCBadgeVariant.success;
      case 'rejected':
      case 'declined':
        return BCBadgeVariant.error;
      default:
        return BCBadgeVariant.warning;
    }
  }
}
