import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brand_provider.dart';

final savedCreatorsProvider =
    AsyncNotifierProvider<SavedCreatorsNotifier, List<SavedCreator>>(
  SavedCreatorsNotifier.new,
);

class SavedCreatorsNotifier extends AsyncNotifier<List<SavedCreator>> {
  @override
  Future<List<SavedCreator>> build() async {
    return ref.read(brandRepositoryProvider).getSavedCreators();
  }

  Future<void> toggleSave(String creatorId) async {
    final current = state.valueOrNull ?? [];
    final isSaved = current.any((s) => s.creatorId == creatorId);

    if (isSaved) {
      state = AsyncData(current.where((s) => s.creatorId != creatorId).toList());
      await ref.read(brandRepositoryProvider).unsaveCreator(creatorId);
    } else {
      await ref.read(brandRepositoryProvider).saveCreator(creatorId);
      ref.invalidateSelf();
      await future;
    }
  }

  bool isSaved(String creatorId) {
    final current = state.valueOrNull ?? [];
    return current.any((s) => s.creatorId == creatorId);
  }
}
