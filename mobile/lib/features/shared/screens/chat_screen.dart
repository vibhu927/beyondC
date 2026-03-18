import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/cards/bc_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  bool _isBriefExpanded = false;
  bool _didInitialScroll = false;
  int _lastRenderedMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final nearTop = position.pixels >= (position.maxScrollExtent - 120);
    if (nearTop) {
      ref.read(chatProvider(widget.collabId).notifier).loadMore();
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      await ref
          .read(chatProvider(widget.collabId).notifier)
          .sendMessage(content);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _scrollToBottomIfNeeded(int messageCount) {
    if (!_scrollController.hasClients) return;

    final shouldJump =
        !_didInitialScroll || messageCount != _lastRenderedMessageCount;
    if (!shouldJump) return;

    _didInitialScroll = true;
    _lastRenderedMessageCount = messageCount;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final role = authState.role ?? 'creator';

    final collabAsync = ref.watch(collabProvider(widget.collabId));
    final chatAsync = ref.watch(chatProvider(widget.collabId));

    final collab = collabAsync.valueOrNull;
    final otherPartyName = _otherPartyName(role, collab);
    final initials = _initials(otherPartyName);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: Text(initials, style: AppTypography.labelSM),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherPartyName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLG,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role == 'creator' ? 'Brand partner' : 'Creator partner',
                    style: AppTypography.bodyXS,
                  ),
                ],
              ),
            ),
            const BCBadge(label: 'Matched', variant: BCBadgeVariant.success),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
      body: Column(
        children: [
          if (collab != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: _BriefCard(
                collab: collab,
                isExpanded: _isBriefExpanded,
                onToggle: () =>
                    setState(() => _isBriefExpanded = !_isBriefExpanded),
                onViewMilestones: () => context.push(
                  RouteNames.collabMilestones
                      .replaceFirst(':id', widget.collabId),
                ),
              ),
            ),
          Expanded(
            child: chatAsync.when(
              loading: () => const _ChatShimmer(),
              error: (error, _) => BCErrorState(
                message: error.toString(),
                onRetry: () =>
                    ref.read(chatProvider(widget.collabId).notifier).refresh(),
              ),
              data: (chatState) {
                final messages = chatState.messages;
                _scrollToBottomIfNeeded(messages.length);

                if (messages.isEmpty) {
                  return const BCEmptyState(
                    emoji: '💬',
                    message: 'No messages yet. Start the conversation.',
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.md,
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                  ),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) {
                    final current = messages[index];
                    final next = index + 1 < messages.length
                        ? messages[index + 1]
                        : null;

                    if (next == null ||
                        !_isSameDay(current.createdAt, next.createdAt)) {
                      return _DateSeparator(date: current.createdAt);
                    }

                    return const SizedBox(height: AppSpacing.xs);
                  },
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderRole == role;
                    return _MessageBubble(message: message, isMine: isMine);
                  },
                );
              },
            ),
          ),
          _ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _otherPartyName(String role, dynamic collab) {
    if (role == 'creator') {
      return 'HealthPlus 🏢';
    }
    return 'Priya S. 🎨';
  }

  String _initials(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z ]'), '').trim();
    if (cleaned.isEmpty) return 'U';

    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({
    required this.collab,
    required this.isExpanded,
    required this.onToggle,
    required this.onViewMilestones,
  });

  final dynamic collab;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onViewMilestones;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.neon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${collab.brandCategory} Collab',
                  style: AppTypography.labelLG,
                ),
              ),
              BCBadge(
                label: _collabTypeLabel(collab.collabType),
                variant: BCBadgeVariant.pink,
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Agreed amount: ${Formatters.currency(collab.amount)}',
            style: AppTypography.bodySM.copyWith(color: AppColors.muted),
          ),
          if (isExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Status: ${collab.status}',
              style: AppTypography.bodySM,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Milestone: ${collab.milestoneStatus ?? 'brief_shared'}',
              style: AppTypography.bodySM,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Deliverables: Reel + Story mention',
              style: AppTypography.bodySM,
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewMilestones,
              child: Text(
                'View Milestones ->',
                style: AppTypography.labelMD.copyWith(color: AppColors.pink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _collabTypeLabel(dynamic type) {
    final raw = type.toString().split('.').last;
    if (raw == 'barter') return 'Barter';
    if (raw == 'hybrid') return 'Hybrid';
    return 'Paid';
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.pink : AppColors.neon;
    final textColor = isMine ? AppColors.white : AppColors.ink;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: message.isPending ? 0.72 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        isMine ? AppSpacing.radiusLG : AppSpacing.xs),
                    topRight: Radius.circular(
                        isMine ? AppSpacing.xs : AppSpacing.radiusLG),
                    bottomLeft: const Radius.circular(AppSpacing.radiusLG),
                    bottomRight: const Radius.circular(AppSpacing.radiusLG),
                  ),
                  border: Border.all(color: AppColors.ink, width: 1.2),
                ),
                child: Text(
                  message.content,
                  style: AppTypography.bodyMD.copyWith(color: textColor),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.isPending
                  ? 'Sending...'
                  : Formatters.time(message.createdAt),
              style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            Formatters.date(date),
            style: AppTypography.bodyXS,
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.controller.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            InkWell(
              onTap: canSend ? widget.onSend : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: canSend ? AppColors.neon : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.ink, width: 1.6),
                ),
                child: const Icon(Icons.send_rounded,
                    color: AppColors.ink, size: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: List.generate(6, (index) {
          final left = index.isEven;
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Align(
              alignment: left ? Alignment.centerLeft : Alignment.centerRight,
              child: Shimmer.fromColors(
                baseColor: AppColors.divider,
                highlightColor: AppColors.surfaceAlt,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.54,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
