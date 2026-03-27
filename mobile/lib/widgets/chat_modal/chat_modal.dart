import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_modal_provider.dart';
import '../../providers/creator_provider.dart';
import '../../providers/brand_provider.dart';
import '../chat_drawer/chat_drawer.dart';
import 'chat_list_tile.dart';
import 'chat_modal_header.dart';
import 'request_tile.dart';

void openChatModal(
  BuildContext context,
  {
  ChatModalTab initialTab = ChatModalTab.collabs,
}) {
  final container = ProviderScope.containerOf(context, listen: false);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => ChatModal(initialTab: initialTab),
  );

  container.read(chatModalProvider.notifier).refresh();
}

class ChatModal extends ConsumerStatefulWidget {
  const ChatModal({
    super.key,
    this.initialTab = ChatModalTab.collabs,
  });

  final ChatModalTab initialTab;

  @override
  ConsumerState<ChatModal> createState() => _ChatModalState();
}

class _ChatModalState extends ConsumerState<ChatModal> {
  late ChatModalTab _activeTab;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatModalProvider);
    final auth = ref.watch(authProvider);
    final role = auth.role ?? 'creator';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDark ? AppColors.darkBg : AppColors.lightBg;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.7,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const <double>[0.7, 1.0],
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            final expandedNow = notification.extent >= 0.98;
            if (expandedNow != _isExpanded && mounted) {
              setState(() => _isExpanded = expandedNow);
            }
            return false;
          },
          child: Material(
            color: modalBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXL),
            ),
            child: Column(
              children: [
                ChatModalHeader(
                  isExpanded: _isExpanded,
                  onClose: () => Navigator.of(context).pop(),
                  onSearchChanged: (value) {
                    ref.read(chatModalProvider.notifier).setSearchQuery(value);
                  },
                ),
                _TabRow(
                  activeTab: _activeTab,
                  onTabChanged: (tab) => setState(() => _activeTab = tab),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: chatAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.neon),
                    ),
                    error: (error, _) => Center(
                      child: Text(error.toString(), style: AppTypography.bodySM),
                    ),
                    data: (data) {
                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
                        children: [
                          if (_activeTab == ChatModalTab.collabs)
                            _buildCollabsTab(context, data),
                          if (_activeTab == ChatModalTab.requests)
                            _buildRequestsTab(context, role, data),
                          if (_activeTab == ChatModalTab.events)
                            _buildEventsTab(context, role, data),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollabsTab(BuildContext context, ChatModalState data) {
    if (data.filteredCollabs.isEmpty) {
      return const _EmptyTabState(
        message: '💬 No active chats yet.\nAccept a collab to start chatting!',
      );
    }

    return Column(
      children: data.filteredCollabs.map((chat) {
        return ChatListTile(
          chat: chat,
          onTap: () {
            ref.read(chatModalProvider.notifier).setOpenCollabId(chat.collabId);
            Navigator.of(context).pop();
            Future<void>.delayed(const Duration(milliseconds: 120), () {
              if (!mounted) return;
              openChatDrawer(context, chat.collabId);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRequestsTab(
    BuildContext context,
    String role,
    ChatModalState data,
  ) {
    if (data.filteredRequests.isEmpty) {
      return const _EmptyTabState(message: '📩 No requests yet.');
    }

    final isCreator = role == 'creator';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Column(
        key: ValueKey<int>(data.filteredRequests.length),
        children: data.filteredRequests.map((request) {
          return RequestTile(
            key: ValueKey<String>(request.id),
            request: request,
            isCreator: isCreator,
            onAccept: () async {
              await ref.read(chatModalProvider.notifier).handleRequestAction(
                    requestId: request.id,
                    action: 'accept',
                  );
              ref.invalidate(chatModalProvider);
              if (isCreator) {
                ref.invalidate(requestsProvider);
                ref.invalidate(creatorCollabsProvider);
              } else {
                ref.invalidate(brandProvider);
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Matched! 🎉 Chat is now available.')),
              );
              setState(() => _activeTab = ChatModalTab.collabs);
            },
            onReject: () async {
              await ref.read(chatModalProvider.notifier).handleRequestAction(
                    requestId: request.id,
                    action: 'reject',
                  );
            },
            onCancel: () async {
              await ref.read(chatModalProvider.notifier).cancelRequest(request.id);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventsTab(
    BuildContext context,
    String role,
    ChatModalState data,
  ) {
    if (data.filteredEvents.isEmpty) {
      return const _EmptyTabState(message: '🎟️ No event invites yet.');
    }

    final isCreator = role == 'creator';

    return Column(
      children: data.filteredEvents.map((invite) {
        final pending = invite.status.toLowerCase() == 'pending';
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.sm,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.eventName, style: AppTypography.labelLG),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${invite.brandName} • ${invite.status.toUpperCase()}',
                  style: AppTypography.bodySM,
                ),
                if (isCreator && pending) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(chatModalProvider.notifier)
                                .handleEventAction(
                                  inviteId: invite.id,
                                  action: 'accept',
                                );
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(chatModalProvider.notifier)
                                .handleEventAction(
                                  inviteId: invite.id,
                                  action: 'reject',
                                );
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.activeTab,
    required this.onTabChanged,
  });

  final ChatModalTab activeTab;
  final ValueChanged<ChatModalTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        scrollDirection: Axis.horizontal,
        children: [
          _TabPill(
            label: '💬 Collabs',
            isActive: activeTab == ChatModalTab.collabs,
            onTap: () => onTabChanged(ChatModalTab.collabs),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TabPill(
            label: '📩 Requests',
            isActive: activeTab == ChatModalTab.requests,
            onTap: () => onTabChanged(ChatModalTab.requests),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TabPill(
            label: '🎟️ Events',
            isActive: activeTab == ChatModalTab.events,
            onTap: () => onTabChanged(ChatModalTab.events),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.ink
              : (isDark ? AppColors.darkSurface : AppColors.white),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isActive
                ? AppColors.ink
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMD.copyWith(
            color: isActive
                ? AppColors.neon
                : (isDark ? AppColors.darkText : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.huge),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMD,
        ),
      ),
    );
  }
}
