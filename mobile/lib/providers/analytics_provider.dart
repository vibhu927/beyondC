import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brand_provider.dart';

final brandAnalyticsProvider =
    AsyncNotifierProvider<BrandAnalyticsNotifier, BrandAnalytics>(
  BrandAnalyticsNotifier.new,
);

class BrandAnalyticsNotifier extends AsyncNotifier<BrandAnalytics> {
  @override
  Future<BrandAnalytics> build() async {
    return ref.read(brandRepositoryProvider).getAnalytics();
  }
}
