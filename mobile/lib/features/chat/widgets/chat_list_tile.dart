import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/collab_chat.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.chat,
    required this.role,
    required this.onTap,
  });

  final CollabChat chat;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = chat.unreadForRole(role);
    final nameStyle = unread > 0
        ? AppTypography.labelMD.copyWith(fontWeight: FontWeight.w800)
        : AppTypography.labelMD;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.sm,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _Avatar(
                    label: chat.otherPartyName,
                    avatarUrl: chat.otherPartyAvatar,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.neon,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.ink, width: 1.2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.otherPartyName,
                            style: nameStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _timeLabel(chat.lastMessageAt),
                          style: AppTypography.bodyXS.copyWith(
                            color: unread > 0 ? AppColors.ink : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.campaignTitle?.trim().isNotEmpty == true
                                ? chat.campaignTitle!
                                : 'Campaign conversation',
                            style: AppTypography.bodySM.copyWith(
                              color: unread > 0 ? AppColors.ink : AppColors.muted,
                              fontWeight:
                                  unread > 0 ? FontWeight.w600 : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neon,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              border: Border.all(color: AppColors.darkGreen.withValues(alpha: 0.16)),
                            ),
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: AppTypography.labelXS.copyWith(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else if (chat.isArchived)
                          const Icon(
                            Symbols.archive_rounded,
                            size: 16,
                            color: AppColors.muted,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return '';
    return Formatters.timeAgo(date);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label, this.avatarUrl});

  final String label;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final image = avatarUrl?.trim();
    final hasImage = image != null && image.isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 1.6),
        color: AppColors.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: hasImage
            ? Image.network(image, fit: BoxFit.cover)
            : Center(
                child: Text(
                  _initial(label),
                  style: AppTypography.labelMD,
                ),
              ),
      ),
    );
  }

  String _initial(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return 'U';
    return cleaned.substring(0, 1).toUpperCase();
  }
}
