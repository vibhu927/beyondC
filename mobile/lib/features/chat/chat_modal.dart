import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/bc_empty_state.dart';
import '../../widgets/bc_error_state.dart';
import 'chat_screen.dart';
import 'widgets/archive_tile.dart';
import 'widgets/chat_list_tile.dart';

void openChatModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => const _ChatModalSheet(),
  );
}

class _ChatModalSheet extends ConsumerStatefulWidget {
  const _ChatModalSheet();

  @override
  ConsumerState<_ChatModalSheet> createState() => _ChatModalSheetState();
}

class _ChatModalSheetState extends ConsumerState<_ChatModalSheet> {
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  String _filter = 'all';

  static const double _minSheetSize = 0.5;
  static const double _maxSheetSize = 1.0;

  @override
  void dispose() {
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onHandleDragUpdate(DragUpdateDetails details) {
    if (!_sheetController.isAttached) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final delta = details.primaryDelta ?? 0;
    final next = (_sheetController.size - (delta / screenHeight))
        .clamp(_minSheetSize, _maxSheetSize);
    _sheetController.jumpTo(next);
  }

  void _onHandleDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached) return;

    final velocity = details.primaryVelocity ?? 0;
    double target;
    if (velocity.abs() > 280) {
      target = velocity < 0 ? _maxSheetSize : _minSheetSize;
    } else {
      target = _sheetController.size > 0.75 ? _maxSheetSize : _minSheetSize;
    }

    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.5, 1.0],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: AppShadows.neon,
          ),
          child: Column(
            children: [
              _ChatModalHeader(
                searchController: _searchController,
                filter: _filter,
                onSearchChanged: (_) => setState(() {}),
                onFilterChanged: (f) => setState(() => _filter = f),
                onClose: () => Navigator.of(context).pop(),
                onHandleDragUpdate: _onHandleDragUpdate,
                onHandleDragEnd: _onHandleDragEnd,
              ),
              Expanded(
                child: _ChatList(
                  scrollController: scrollController,
                  filter: _filter,
                  searchQuery: _searchController.text,
                  onOpenArchived: () => setState(() => _filter = 'archived'),
                  onChatTap: (collabId) {
                    openChatDrawer(context, collabId);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatModalHeader extends StatelessWidget {
  const _ChatModalHeader({
    required this.searchController,
    required this.filter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onClose,
    required this.onHandleDragUpdate,
    required this.onHandleDragEnd,
  });

  final TextEditingController searchController;
  final String filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClose;
  final GestureDragUpdateCallback onHandleDragUpdate;
  final GestureDragEndCallback onHandleDragEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: onHandleDragUpdate,
              onVerticalDragEnd: onHandleDragEnd,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.darkMuted,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Messages', style: AppTypography.displaySM),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkBorder, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 44,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.neon,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              padding: const EdgeInsets.only(right: 3, bottom: 3),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: AppTypography.bodySM.copyWith(color: AppColors.ink),
                cursorColor: AppColors.ink,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: AppTypography.bodySM.copyWith(
                    color: AppColors.muted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.ink,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: const BorderSide(color: AppColors.ink, width: 1.8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: const BorderSide(color: AppColors.ink, width: 1.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: const BorderSide(color: AppColors.ink, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  active: filter == 'all',
                  onTap: () => onFilterChanged('all'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Archived',
                  active: filter == 'archived',
                  onTap: () => onFilterChanged('archived'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.ink, width: 1.2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.neon : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _ChatList extends ConsumerWidget {
  const _ChatList({
    required this.scrollController,
    required this.filter,
    required this.searchQuery,
    required this.onOpenArchived,
    required this.onChatTap,
  });

  final ScrollController scrollController;
  final String filter;
  final String searchQuery;
  final VoidCallback onOpenArchived;
  final ValueChanged<String> onChatTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((a) => a.role)) ?? 'creator';

    return ref.watch(chatListProvider).when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.neon),
          ),
          error: (error, _) => BCErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(chatListProvider),
          ),
          data: (result) {
            final source = filter == 'archived' ? result.archived : result.active;
            final query = searchQuery.trim().toLowerCase();
            final chats = query.isEmpty
                ? source
                : source.where((c) {
                    final name = c.otherPartyName.toLowerCase();
                    final msg = (c.lastMessage ?? '').toLowerCase();
                    return name.contains(query) || msg.contains(query);
                  }).toList();

            if (chats.isEmpty) {
              return const BCEmptyState(
                emoji: '💬',
                message: 'No chats found.',
              );
            }

            return ListView.builder(
              controller: scrollController,
              itemCount: chats.length + (filter == 'all' && result.archived.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (filter == 'all' && result.archived.isNotEmpty && index == chats.length) {
                  return ArchiveTile(
                    count: result.archived.length,
                    onTap: onOpenArchived,
                  );
                }

                final chat = chats[index];
                return ChatListTile(
                  chat: chat,
                  role: role,
                  onTap: () => onChatTap(chat.id),
                );
              },
            );
          },
        );
  }
}
