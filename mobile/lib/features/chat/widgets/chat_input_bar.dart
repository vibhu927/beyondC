import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
  });

  final ValueChanged<String> onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AppColors.creatorDark.withValues(alpha: 0.14),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.neon.withValues(alpha: 0.5)
                      : AppColors.creatorDark.withValues(alpha: 0.1),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 1,
                minLines: 1,
                onChanged: (_) => setState(() {}),
                onTap: () => setState(() {}),
                style: AppTypography.bodyMD,
                cursorColor: AppColors.creatorDark,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          InkWell(
            onTap: canSend
                ? () {
                    final text = _controller.text.trim();
                    _controller.clear();
                    setState(() {});
                    widget.onSend(text);
                  }
                : null,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: canSend ? AppColors.creatorDark : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Symbols.send_rounded,
                size: 20,
                color: canSend ? AppColors.neon : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
