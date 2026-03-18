import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/creator_models.dart';
import '../data/repositories/collab_repository.dart';
import '../data/services/api_service.dart';
import 'auth_provider.dart';

final collabRepositoryProvider = Provider<CollabRepository>((ref) {
  return CollabRepository(ref.read(apiServiceProvider));
});

class CollabNotifier extends FamilyAsyncNotifier<Collab, String> {
  @override
  Future<Collab> build(String collabId) async {
    return ref.read(collabRepositoryProvider).getCollab(collabId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateMilestone(String milestone) async {
    final role = ref.read(authProvider).role;
    if (role != 'creator' && role != 'brand') {
      throw StateError('Missing account role. Please sign in again.');
    }

    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Collab not loaded.');
    }

    state = await AsyncValue.guard(() async {
      final repository = ref.read(collabRepositoryProvider);
      final updated = role == 'creator'
          ? await repository.updateCreatorMilestone(arg, milestone)
          : await repository.updateBrandMilestone(arg, milestone);

      return updated;
    });
  }

  Future<void> submitRating(
    String ratedUserId,
    int score,
    String? review,
  ) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Collab not loaded.');
    }

    if (current.status != 'completed') {
      throw StateError('Rating is available after the collab is completed.');
    }

    if (current.rating != null) {
      throw StateError('You have already rated this collab.');
    }

    if (score < 1 || score > 5) {
      throw StateError('Rating score must be between 1 and 5.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(collabRepositoryProvider).submitRating(
            arg,
            ratedUserId,
            score,
            review,
          );

      return current.copyWith(rating: score);
    });
  }
}

final collabProvider =
    AsyncNotifierProviderFamily<CollabNotifier, Collab, String>(
  CollabNotifier.new,
);
