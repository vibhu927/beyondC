import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_modal_provider.dart';
import 'services/fcm_service.dart';
import 'widgets/chat_drawer/chat_drawer.dart';
import 'widgets/chat_modal/chat_modal.dart';

class BeyondCApp extends ConsumerWidget {
  const BeyondCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (!next.isAuthenticated) return;

      final pending = ref.read(pendingNavigationProvider);
      if (pending == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pending.type == PendingNavigationType.openChatDrawer) {
          final collabId = pending.collabId;
          if (collabId != null && collabId.isNotEmpty) {
            ref.read(chatModalProvider.notifier).setOpenCollabId(collabId);
            openChatDrawer(context, collabId);
          }
        }

        if (pending.type == PendingNavigationType.openChatRequests) {
          openChatModal(context, initialTab: ChatModalTab.requests);
        }

        ref.read(pendingNavigationProvider.notifier).state = null;
      });
    });

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'BeyondC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return SafeArea(
          top: true,
          bottom: false,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
