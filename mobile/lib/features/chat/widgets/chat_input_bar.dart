import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.role,
  });

  final ValueChanged<String> onSend;
  final String role;

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
    final normalizedRole = widget.role.trim().toLowerCase();
    final isBrand = normalizedRole == 'brand';
    final accentColor = isBrand ? AppColors.error : AppColors.neon;
    final buttonFillColor = canSend
        ? accentColor
        : accentColor.withValues(alpha: 0.38);
    final buttonShadow = <BoxShadow>[
          const BoxShadow(
        color: Colors.black,
            offset: Offset(3, 3),
        blurRadius: 0,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _focusNode.hasFocus ? AppColors.neon : AppColors.ink,
                  width: 2,
                ),
                boxShadow: _focusNode.hasFocus ? AppShadows.neon : AppShadows.blue,
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
                cursorColor: AppColors.ink,
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
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                color: buttonFillColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.ink,
                  width: 2,
                ),
                boxShadow: buttonShadow,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: AppColors.ink.withValues(alpha: canSend ? 1 : 0.62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
