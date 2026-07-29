import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.onRetry,
  });

  final Message message;
  final bool isMine;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isCreatorMessage = message.senderRole == 'creator';
    final bubbleColor = isMine ? AppColors.creatorDark : AppColors.white;
    final textColor = isMine ? AppColors.white : AppColors.creatorDark;
    final accentColor = isCreatorMessage ? AppColors.neon : AppColors.pink;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _onLongPress(context),
            onTap: message.isFailed ? onRetry : null,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMine
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isMine
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: Border.all(
                  color: isMine ? accentColor : AppColors.lightBorder,
                  width: isMine ? 1.2 : 1,
                ),
                boxShadow: isMine
                    ? [
                        BoxShadow(
                          color: AppColors.creatorDark.withValues(alpha: 0.15),
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMD.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: EdgeInsets.only(
              left: isMine ? 0 : AppSpacing.xs,
              right: isMine ? AppSpacing.xs : 0,
            ),
            child: Text(
              _metaText(),
              style: AppTypography.bodyXS.copyWith(
                color: message.isFailed ? AppColors.error : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _metaText() {
    if (message.isFailed) return 'Failed · Tap to retry';
    if (message.isPending) return '...';
    return Formatters.time(message.createdAt);
  }

  Future<void> _onLongPress(BuildContext context) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border(
              top: BorderSide(
                color: AppColors.creatorDark.withValues(alpha: 0.14),
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.creatorDark.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.neon.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.content_copy_rounded, size: 18, color: AppColors.creatorDark),
                  ),
                  title: Text('Copy', style: AppTypography.labelMD.copyWith(color: AppColors.creatorDark)),
                  onTap: () => Navigator.of(context).pop('copy'),
                ),
                if (isMine)
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    ),
                    title: Text('Delete', style: AppTypography.labelMD.copyWith(color: AppColors.error)),
                    onTap: () => Navigator.of(context).pop('delete'),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (value == 'copy') {
      await Clipboard.setData(ClipboardData(text: message.content));
    }
  }
}
