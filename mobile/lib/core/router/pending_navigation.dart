import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PendingNavigationType {
  openChatDrawer,
  openChatRequests,
}

class PendingNavigation {
  const PendingNavigation({
    required this.type,
    this.collabId,
  });

  final PendingNavigationType type;
  final String? collabId;
}

final pendingNavigationProvider =
    StateProvider<PendingNavigation?>((ref) => null);
