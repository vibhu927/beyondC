import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/router/router_holder.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'services/fcm_service.dart';
import 'features/chat/chat_modal.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/in_app_notification.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
OverlayEntry? _activeNotificationOverlay;
final Set<String> _seenNotificationIds = <String>{};
bool _notificationFeedHydrated = false;

class BeyondCApp extends ConsumerWidget {
  const BeyondCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        _seenNotificationIds.clear();
        _notificationFeedHydrated = false;
        return;
      }

      final justLoggedIn = previous?.isAuthenticated != true;
      if (justLoggedIn) {
        _seenNotificationIds.clear();
        _notificationFeedHydrated = false;
      }

      final pending = ref.read(pendingNavigationProvider);
      if (pending == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pending.type == PendingNavigationType.openChatDrawer) {
          final collabId = pending.collabId;
          if (collabId != null && collabId.isNotEmpty) {
            openChatDrawer(context, collabId);
          }
        }

        if (pending.type == PendingNavigationType.openChatRequests) {
          openChatModal(context);
        }

        ref.read(pendingNavigationProvider.notifier).state = null;
      });
    });

    ref.listen(notificationProvider, (previous, next) {
      final nextList = next.valueOrNull;

      if (nextList == null || nextList.isEmpty) return;

      // First successful load is hydration; mark existing IDs as seen and skip toast.
      if (!_notificationFeedHydrated) {
        _seenNotificationIds
          ..clear()
          ..addAll(nextList.map((item) => item.id));
        _notificationFeedHydrated = true;
        return;
      }

      final newItems = nextList
          .where((item) => !_seenNotificationIds.contains(item.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (newItems.isEmpty) return;

      _seenNotificationIds.addAll(newItems.map((item) => item.id));

      final latest = newItems.first;
      final body = latest.body.trim();

      _showInAppNotificationToast(
        title: latest.title,
        description: body,
      );
    });

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'BeyondC',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColors.ink,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Color(0xE6121A25),
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Color(0x00000000),
            systemNavigationBarContrastEnforced: false,
          ),
          child: _BackPressExitScope(
            child: SafeArea(
              top: true,
              bottom: false,
              child: Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  const InAppNotificationOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackPressExitScope extends StatefulWidget {
  const _BackPressExitScope({required this.child});

  final Widget child;

  @override
  State<_BackPressExitScope> createState() => _BackPressExitScopeState();
}

class _BackPressExitScopeState extends State<_BackPressExitScope> {
  DateTime? _lastBackPressAt;

  Future<void> _onBackAttempt() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final navigator = RouterHolder.rootNavigatorKey?.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return;
    }

    final now = DateTime.now();
    final shouldExit = _lastBackPressAt != null &&
        now.difference(_lastBackPressAt!) <= const Duration(seconds: 2);

    if (shouldExit) {
      await SystemNavigator.pop();
      return;
    }

    _lastBackPressAt = now;
    final messenger = appScaffoldMessengerKey.currentState;
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Press back again to exit'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBackAttempt();
      },
      child: widget.child,
    );
  }
}

void _showInAppNotificationToast({
  required String title,
  required String description,
}) {
  final context = RouterHolder.rootNavigatorKey?.currentContext ??
      appScaffoldMessengerKey.currentContext;
  if (context == null) return;

  final overlay = RouterHolder.rootNavigatorKey?.currentState?.overlay ??
      Overlay.maybeOf(context, rootOverlay: true) ??
      Overlay.maybeOf(context);

  if (overlay == null) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger != null) {
      final body = description.trim();
      final message = body.isEmpty ? title : '$title\n$body';
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }

  _activeNotificationOverlay?.remove();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _InAppNotificationToast(
      title: title,
      description: description,
      onDismissed: () {
        if (entry.mounted) {
          entry.remove();
        }
        if (identical(_activeNotificationOverlay, entry)) {
          _activeNotificationOverlay = null;
        }
      },
    ),
  );

  _activeNotificationOverlay = entry;
  overlay.insert(entry);
}

class _InAppNotificationToast extends StatefulWidget {
  const _InAppNotificationToast({
    required this.title,
    required this.description,
    required this.onDismissed,
  });

  final String title;
  final String description;
  final VoidCallback onDismissed;

  @override
  State<_InAppNotificationToast> createState() =>
      _InAppNotificationToastState();
}

class _InAppNotificationToastState extends State<_InAppNotificationToast> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });

    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _visible = false);
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (mounted) {
          widget.onDismissed();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.description.trim().isNotEmpty;

    return IgnorePointer(
      ignoring: true,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              bottom: AppSpacing.lg,
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, 1.2),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neon, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Symbols.notifications_active_rounded,
                              color: AppColors.neon,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelLG.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (hasDescription) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySM.copyWith(
                                      color: AppColors.white
                                          .withValues(alpha: 0.92),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
