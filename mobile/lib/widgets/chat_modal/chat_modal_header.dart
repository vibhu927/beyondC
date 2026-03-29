import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ChatModalHeader extends StatelessWidget {
  const ChatModalHeader({
    super.key,
    required this.isExpanded,
    required this.onClose,
    required this.onSearchChanged,
  });

  final bool isExpanded;
  final VoidCallback onClose;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: isExpanded
                      ? IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: isDark ? AppColors.darkText : AppColors.ink,
                          splashRadius: 20,
                        )
                      : null,
                ),
                Expanded(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isExpanded ? 0 : 1,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                  color: isDark ? AppColors.darkText : AppColors.ink,
                  splashRadius: 20,
                  tooltip: 'Close chat',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Messages', style: AppTypography.displaySM),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search chats...',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              filled: true,
              fillColor:
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
