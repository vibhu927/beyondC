import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/collab_chat.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/in_app_notification_provider.dart';
import '../../widgets/bc_app_loader.dart';
import '../../widgets/buttons/bc_back_button.dart';
import '../../widgets/bc_empty_state.dart';
import '../../widgets/bc_error_state.dart';
import 'profile_view_sheet.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';
import '../creator/shared/widgets/creator_design_system.dart';

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

      ref
          .read(chatRepositoryProvider)
          .markAsRead(widget.collabId, role)
          .then((_) {
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
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE1E8F4),
                      Color(0xFFE9EFF8),
                      Color(0xFFF5F7FB),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: -54,
              child: AmbientGlow(
                size: 164,
                color: AppColors.neon.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: 220,
              left: -42,
              child: AmbientGlow(
                size: 126,
                color: AppColors.pink.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    chat: chat,
                    onClose: () => Navigator.of(context).pop(),
                    onInfo: () => openProfileViewSheet(context, widget.collabId),
                  ),
                  Expanded(
                    child: ref.watch(chatProvider(widget.collabId)).when(
                      loading: () => const Center(child: BCAppLoader()),
                      error: (error, _) => BCErrorState(
                        message: error.toString(),
                        onRetry: () =>
                            ref.invalidate(chatProvider(widget.collabId)),
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
                            final previous = index + 1 < messages.length
                                ? messages[index + 1]
                                : null;
                            final showDateSeparator = previous == null ||
                                !_isSameDay(
                                    current.createdAt, previous.createdAt);

                            final mine = current.senderRole == role;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MessageBubble(
                                  message: current,
                                  isMine: mine,
                                  onRetry: () {
                                    ref
                                        .read(chatProvider(widget.collabId)
                                            .notifier)
                                        .retryMessage(current);
                                  },
                                ),
                                if (showDateSeparator)
                                  Center(
                                    child: InlineTonePill(
                                      label: _dayLabel(current.createdAt),
                                      accent: AppColors.ink,
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
                      ref
                          .read(chatProvider(widget.collabId).notifier)
                          .sendMessage(text);
                    },
                  ),
                ],
              ),
            ),
          ],
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
    final avatarUrl = (chat?.otherPartyAvatar ?? '').trim();

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
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDF7).withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: AppColors.ink.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          BCBackButton(
            onPressed: onClose,
            icon: Icons.close_rounded,
            iconColor: AppColors.ink,
            tooltip: 'Close',
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neon.withValues(alpha: 0.8),
                width: 1.6,
              ),
            ),
            alignment: Alignment.center,
            child: avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        (chat?.otherPartyName ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        style:
                            AppTypography.labelSM.copyWith(color: AppColors.white),
                      ),
                    ),
                  )
                : Text(
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
                  style: AppTypography.labelLG.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodyXS
                      .copyWith(color: AppColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onInfo,
            icon: const Icon(
              Icons.info_rounded,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
