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
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.circular(14);

    final isCreatorMessage = message.senderRole == 'creator';
    final accentColor = isCreatorMessage ? AppColors.neon : AppColors.pink;
    const bubbleColor = AppColors.white;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: align,
          children: [
            GestureDetector(
              onLongPress: () => _onLongPress(context),
              onTap: message.isFailed ? onRetry : null,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border(
                          right: BorderSide(color: accentColor, width: 4),
                          bottom: BorderSide(color: accentColor, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.only(right: 2, bottom: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: radius,
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                    child: Text(
                      message.content,
                      style: AppTypography.bodyMD.copyWith(
                        color: const Color(0xFF0D0D0D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _metaText(),
              style: AppTypography.bodyXS.copyWith(
                color: message.isFailed ? AppColors.error : AppColors.lightMuted,
              ),
            ),
          ],
        ),
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
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copy'),
                onTap: () => Navigator.of(context).pop('copy'),
              ),
              if (isMine)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete'),
                  onTap: () => Navigator.of(context).pop('delete'),
                ),
            ],
          ),
        );
      },
    );

    if (value == 'copy') {
      await Clipboard.setData(ClipboardData(text: message.content));
    }
  }
}
