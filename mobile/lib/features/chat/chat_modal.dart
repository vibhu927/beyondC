import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/bc_app_loader.dart';
import '../../widgets/bc_empty_state.dart';
import '../../widgets/bc_error_state.dart';
import '../../widgets/buttons/bc_back_button.dart';
import 'chat_screen.dart';
import 'widgets/archive_tile.dart';
import 'widgets/chat_list_tile.dart';
import '../creator/shared/widgets/creator_design_system.dart';

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
            color: const Color(0xFFE7EDF7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.ink.withValues(alpha: 0.14),
              width: 1.2,
            ),
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
              BCBackButton(
                onPressed: onClose,
                icon: Icons.close_rounded,
                iconColor: AppColors.ink,
                backgroundColor: Colors.white.withValues(alpha: 0.92),
                borderColor: AppColors.ink.withValues(alpha: 0.16),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 44,
            child: GlassPanel(
              accentColor: AppColors.neon,
              radius: 999,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                    Symbols.search_rounded,
                    color: AppColors.ink,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
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
          color: active
              ? AppColors.ink.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: uniformBorder(
            active ? AppColors.ink : AppColors.blue,
            width: 1.1,
          ),
          boxShadow: neoShadows(
            active ? AppColors.ink : AppColors.blue,
            alpha: 0.1,
            offset: 2.5,
            blurRadius: 8,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.neon : AppColors.ink,
            fontWeight: FontWeight.w800,
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
          loading: () => const Center(child: BCAppLoader()),
          error: (error, _) => BCErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(chatListProvider),
          ),
          data: (result) {
            final source =
                filter == 'archived' ? result.archived : result.active;
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
              itemCount: chats.length +
                  (filter == 'all' && result.archived.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (filter == 'all' &&
                    result.archived.isNotEmpty &&
                    index == chats.length) {
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
