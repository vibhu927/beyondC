import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/creator_models.dart';
import 'creator_provider.dart';

final creatorEarningsProvider =
    AsyncNotifierProvider<CreatorEarningsNotifier, CreatorEarnings>(
  CreatorEarningsNotifier.new,
);

class CreatorEarningsNotifier extends AsyncNotifier<CreatorEarnings> {
  @override
  Future<CreatorEarnings> build() async {
    return ref.read(creatorRepositoryProvider).getEarnings();
  }
}
