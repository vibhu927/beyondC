import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/in_app_notification_provider.dart';
import '../../widgets/buttons/bc_back_button.dart';
import 'chat_screen.dart';

class InAppNotificationOverlay extends ConsumerWidget {
  const InAppNotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(inAppNotificationProvider);

    return IgnorePointer(
      ignoring: !notif.isVisible,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: notif.isVisible ? MediaQuery.of(context).padding.top + 8 : -120,
            left: 16,
            right: 16,
            child: notif.isVisible
                ? _NotificationToast(
                    title: notif.chatTitle ?? '',
                    message: notif.message?.content ?? '',
                    collabId: notif.collabId ?? '',
                    onTap: () {
                      ref.read(inAppNotificationProvider.notifier).hide();
                      final id = notif.collabId;
                      if (id != null && id.isNotEmpty) {
                        openChatDrawer(context, id);
                      }
                    },
                    onDismiss: () =>
                        ref.read(inAppNotificationProvider.notifier).hide(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NotificationToast extends StatelessWidget {
  const _NotificationToast({
    required this.title,
    required this.message,
    required this.collabId,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final String collabId;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.ink,
            border: Border.all(color: AppColors.neon, width: 2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.neon,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Symbols.chat_bubble_rounded,
                  color: AppColors.ink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMD.copyWith(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      message,
                      style: AppTypography.bodyXS.copyWith(color: AppColors.darkMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BCBackButton(
                onPressed: onDismiss,
                icon: Icons.close_rounded,
                iconSize: 14,
                buttonSize: 24,
                iconColor: AppColors.darkMuted,
                backgroundColor: AppColors.darkSurface,
                borderColor: AppColors.darkBorder,
                tooltip: 'Close',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
