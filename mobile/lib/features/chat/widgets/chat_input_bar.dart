import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../creator/shared/widgets/creator_design_system.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDF7).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: AppColors.ink.withValues(alpha: 0.12)),
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
            child: GlassPanel(
              accentColor: _focusNode.hasFocus ? AppColors.neon : AppColors.blue,
              radius: 999,
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
                color: accentColor.withValues(alpha: canSend ? 0.2 : 0.09),
                borderRadius: BorderRadius.circular(999),
                border: uniformBorder(accentColor, width: 1.2),
                boxShadow: neoShadows(
                  accentColor,
                  alpha: 0.2,
                  offset: 2.5,
                  blurRadius: 8,
                ),
              ),
              child: Icon(
                Symbols.send_rounded,
                size: 20,
                color: accentColor.withValues(alpha: canSend ? 1 : 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
