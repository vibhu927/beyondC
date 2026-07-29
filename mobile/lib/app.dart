import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/router/pending_navigation.dart';
import 'core/router/route_names.dart';
import 'core/router/router_holder.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'features/chat/chat_modal.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/in_app_notification.dart';
import 'data/repositories/notification_repository.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class BeyondCApp extends ConsumerWidget {
  const BeyondCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        return;
      }

      final justLoggedIn = previous?.isAuthenticated != true;
      if (!justLoggedIn) return;

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
        final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: AppColors.ink,
            statusBarIconBrightness:
                isIOS ? Brightness.dark : Brightness.light,
            statusBarBrightness:
                isIOS ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: const Color(0xE6121A25),
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: const Color(0x00000000),
            systemNavigationBarContrastEnforced: false,
          ),
          child: _BackPressExitScope(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  const InAppNotificationOverlay(),
                  const _InAppNotificationToastHost(),
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

class _InAppNotificationToastHost extends ConsumerStatefulWidget {
  const _InAppNotificationToastHost();

  @override
  ConsumerState<_InAppNotificationToastHost> createState() =>
      _InAppNotificationToastHostState();
}

class _InAppNotificationToastHostState
    extends ConsumerState<_InAppNotificationToastHost> {
  OverlayEntry? _activeEntry;
  StreamSubscription<AppNotification>? _subscription;
  NotificationNotifier? _subscribedNotifier;

  @override
  void dispose() {
    _subscription?.cancel();
    _activeEntry?.remove();
    _activeEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resubscribe whenever the underlying notifier instance changes
    // (e.g. login/logout invalidates the provider, creating a new notifier).
    ref.listen<AsyncValue<List<AppNotification>>>(
      notificationProvider,
      (previous, next) {
        final currentNotifier = ref.read(notificationProvider.notifier);
        if (!identical(currentNotifier, _subscribedNotifier)) {
          _ensureSubscribed();
        }
      },
    );

    // Fallback: ensure first subscription is in place once after the first
    // build (ref.read in initState is allowed but we play it safe).
    if (_subscription == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureSubscribed();
      });
    }

    return const SizedBox.shrink();
  }

  void _ensureSubscribed() {
    final notifier = ref.read(notificationProvider.notifier);
    if (identical(notifier, _subscribedNotifier) && _subscription != null) {
      return;
    }
    _subscription?.cancel();
    _subscribedNotifier = notifier;
    _subscription = notifier.onNewNotification.listen(
      _show,
      onError: (_) {},
    );
  }

  void _show(AppNotification notification) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _activeEntry?.remove();
    _activeEntry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _InAppNotificationToast(
        notification: notification,
        onDismissed: () {
          if (entry.mounted) {
            entry.remove();
          }
          if (identical(_activeEntry, entry)) {
            _activeEntry = null;
          }
        },
        onMarkedRead: () {
          // Mark as read silently in the background; do not block dismissal.
          ref
              .read(notificationProvider.notifier)
              .markRead(notification.id);
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _InAppNotificationToast extends ConsumerStatefulWidget {
  const _InAppNotificationToast({
    required this.notification,
    required this.onDismissed,
    required this.onMarkedRead,
  });

  final AppNotification notification;
  final VoidCallback onDismissed;
  final VoidCallback onMarkedRead;

  @override
  ConsumerState<_InAppNotificationToast> createState() =>
      _InAppNotificationToastState();
}

class _InAppNotificationToastState
    extends ConsumerState<_InAppNotificationToast> {
  static const Duration _visibleDuration = Duration(milliseconds: 4200);
  static const Duration _animDuration = Duration(milliseconds: 320);

  bool _visible = false;
  bool _dismissing = false;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
    });

    _autoDismissTimer = Timer(_visibleDuration, _dismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted || _dismissing) return;
    setState(() {
      _dismissing = true;
      _visible = false;
    });
    Future<void>.delayed(_animDuration, () {
      if (!mounted) return;
      widget.onDismissed();
    });
  }

  void _onTap() {
    final notif = widget.notification;
    final role = ref.read(authProvider.select((s) => s.role)) ?? 'creator';
    final route = _routeForNotification(notif, role);
    final collabChat = notif.referenceType == 'collab' &&
        notif.referenceId != null &&
        notif.referenceId!.isNotEmpty;

    widget.onMarkedRead();
    _dismiss();

    if (collabChat) {
      openChatDrawer(context, notif.referenceId!);
      return;
    }
    if (route != null) {
      GoRouter.of(context).push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role =
        ref.watch(authProvider.select((s) => s.role)) ?? 'creator';
    final rolePrimary = _rolePrimary(role);
    final roleDark = _roleDark(role);
    final notif = widget.notification;
    final hasBody = notif.body.trim().isNotEmpty;
    final mediaPadding = MediaQuery.of(context).padding;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !_visible,
        child: Padding(
          padding: EdgeInsets.only(top: mediaPadding.top + 8),
          child: AnimatedSlide(
            offset: _visible ? Offset.zero : const Offset(0, -1.2),
            duration: _animDuration,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rolePrimary,
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rolePrimary.withValues(alpha: 0.28),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 4,
                                color: rolePrimary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                8,
                                12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: rolePrimary,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _typeIcon(notif.type),
                                      size: 20,
                                      color: roleDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notif.title,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: AppTypography.labelMD
                                                    .copyWith(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              timeago.format(
                                                notif.createdAt,
                                              ),
                                              style: AppTypography.labelXS
                                                  .copyWith(
                                                color: rolePrimary
                                                    .withValues(alpha: 0.85),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hasBody) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            notif.body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.bodyXS
                                                .copyWith(
                                              color: AppColors.darkMuted,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  _ToastCloseButton(
                                    onPressed: _dismiss,
                                    borderColor:
                                        roleDark.withValues(alpha: 0.45),
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCloseButton extends StatelessWidget {
  const _ToastCloseButton({required this.onPressed, required this.borderColor});

  final VoidCallback onPressed;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 18,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 14,
          color: AppColors.darkMuted,
        ),
      ),
    );
  }
}

String? _routeForNotification(AppNotification notification, String role) {
  final referenceId = notification.referenceId;
  switch (notification.referenceType) {
    case 'collab':
      return null;
    case 'bid':
      if (role == 'creator') return RouteNames.myBids;
      if (role == 'agency') return RouteNames.agencyBids;
      if (referenceId == null) return RouteNames.brandCampaigns;
      return RouteNames.campaignBids.replaceFirst(':id', referenceId);
    case 'event_invite':
      if (role == 'creator') return RouteNames.creatorEvents;
      if (referenceId == null) return RouteNames.brandEvents;
      return RouteNames.eventInvites.replaceFirst(':id', referenceId);
    case 'campaign':
      if (referenceId == null) return RouteNames.creatorCampaigns;
      return RouteNames.campaignDetail.replaceFirst(':id', referenceId);
    default:
      return null;
  }
}

Color _rolePrimary(String role) {
  switch (role) {
    case 'brand':
      return AppColors.brandPrimary;
    case 'agency':
      return AppColors.agencyPrimary;
    default:
      return AppColors.creatorPrimary;
  }
}

Color _roleDark(String role) {
  switch (role) {
    case 'brand':
      return AppColors.brandDark;
    case 'agency':
      return AppColors.agencyDark;
    default:
      return AppColors.creatorDark;
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'bid_received':
      return Symbols.assignment_rounded;
    case 'bid_accepted':
      return Symbols.check_circle_rounded;
    case 'event_invite':
      return Symbols.confirmation_number_rounded;
    case 'collab_matched':
      return Symbols.handshake_rounded;
    case 'request_received':
      return Symbols.mail_rounded;
    case 'new_message':
      return Symbols.chat_bubble_rounded;
    default:
      return Icons.notifications_rounded;
  }
}
