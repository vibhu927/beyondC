import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/collab_chat.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/in_app_notification_provider.dart';
import '../../widgets/bc_empty_state.dart';
import '../../widgets/bc_error_state.dart';
import 'profile_view_sheet.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

void openChatDrawer(BuildContext context, String collabId) {
  final container = ProviderScope.containerOf(context, listen: false);
  container.read(inAppNotificationProvider.notifier).setCurrentChat(collabId);

  Navigator.of(context)
      .push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => ChatScreen(collabId: collabId),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    ),
  )
      .then((_) {
    container.read(inAppNotificationProvider.notifier).setCurrentChat(null);
  });
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final role = ref.read(authProvider).role;
      if (role == null) return;

      ref.read(chatRepositoryProvider).markAsRead(widget.collabId, role).then((_) {
        if (!mounted) return;
        ref.invalidate(chatListProvider);
      });
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 120;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(chatProvider(widget.collabId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider.select((a) => a.role)) ?? 'creator';
    final chatList = ref.watch(chatListProvider).valueOrNull;

    final chat = _findChat(chatList, widget.collabId);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                chat: chat,
                onClose: () => Navigator.of(context).pop(),
                onInfo: () => openProfileViewSheet(context, widget.collabId),
              ),
              Expanded(
                child: ref.watch(chatProvider(widget.collabId)).when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.neon),
                      ),
                      error: (error, _) => BCErrorState(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(chatProvider(widget.collabId)),
                      ),
                      data: (messages) {
                        if (messages.isEmpty) {
                          return const BCEmptyState(
                            emoji: '💬',
                            message: 'No messages yet. Start the conversation.',
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final current = messages[index];
                            final previous = index + 1 < messages.length ? messages[index + 1] : null;
                            final showDateSeparator = previous == null ||
                                !_isSameDay(current.createdAt, previous.createdAt);

                            final mine = current.senderRole == role;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MessageBubble(
                                  message: current,
                                  isMine: mine,
                                  onRetry: () {
                                    ref.read(chatProvider(widget.collabId).notifier).retryMessage(current);
                                  },
                                ),
                                if (showDateSeparator)
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightDivider,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        _dayLabel(current.createdAt),
                                        style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
              ),
              ChatInputBar(
                role: role,
                onSend: (text) {
                  ref.read(chatProvider(widget.collabId).notifier).sendMessage(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(DateTime date) {
    final today = DateTime.now();
    if (_isSameDay(date, today)) return 'Today';
    return '${date.day}/${date.month}/${date.year}';
  }

  CollabChat? _findChat(ChatListResult? state, String collabId) {
    if (state == null) return null;
    for (final chat in state.active) {
      if (chat.id == collabId) return chat;
    }
    for (final chat in state.archived) {
      if (chat.id == collabId) return chat;
    }
    return null;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.chat,
    required this.onClose,
    required this.onInfo,
  });

  final CollabChat? chat;
  final VoidCallback onClose;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final subtitle = (chat?.otherPartyNiche?.trim().isNotEmpty == true)
        ? chat!.otherPartyNiche!
        : (chat?.otherPartyCategory?.trim().isNotEmpty == true)
            ? chat!.otherPartyCategory!
            : 'Matched on BeyondC';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(bottom: BorderSide(color: Color(0x33FFFFFF))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 1.6),
            ),
            alignment: Alignment.center,
            child: Text(
              (chat?.otherPartyName ?? 'U').substring(0, 1).toUpperCase(),
              style: AppTypography.labelSM.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat?.otherPartyName ?? 'Chat',
                  style: AppTypography.labelLG.copyWith(color: AppColors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyXS
                      .copyWith(color: AppColors.white.withValues(alpha: 0.82)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onInfo,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
