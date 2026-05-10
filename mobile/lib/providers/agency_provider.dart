import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/agency_repository.dart';
import '../data/services/api_service.dart';
import '../data/models/brand_models.dart';

export '../data/models/brand_models.dart';

final agencyRepositoryProvider = Provider<AgencyRepository>((ref) {
  return AgencyRepository(ref.read(apiServiceProvider));
});

final agencyProfileProvider =
    AsyncNotifierProvider<AgencyProfileNotifier, Map<String, dynamic>>(
  () => AgencyProfileNotifier(),
);

class AgencyProfileNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(agencyRepositoryProvider).getProfile();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final profile = await ref.read(agencyRepositoryProvider).updateProfile(data);
    state = AsyncData(profile);
    return profile;
  }
}

class AgencyDiscoveryFilters {
  const AgencyDiscoveryFilters({
    this.niche,
    this.state,
    this.city,
  });

  final String? niche;
  final String? state;
  final String? city;

  AgencyDiscoveryFilters copyWith({
    Object? niche = _sentinel,
    Object? state = _sentinel,
    Object? city = _sentinel,
  }) {
    return AgencyDiscoveryFilters(
      niche: identical(niche, _sentinel) ? this.niche : niche as String?,
      state: identical(state, _sentinel) ? this.state : state as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
    );
  }
}

const _sentinel = Object();

final agencyDiscoveryProvider =
    AsyncNotifierProvider<AgencyDiscoveryNotifier, AgencyDiscoveryState>(
  () => AgencyDiscoveryNotifier(),
);

class AgencyDiscoveryState {
  const AgencyDiscoveryState({
    required this.creators,
    required this.page,
    required this.hasMore,
    required this.filters,
    this.isLoadingMore = false,
  });

  final List<Map<String, dynamic>> creators;
  final int page;
  final bool hasMore;
  final AgencyDiscoveryFilters filters;
  final bool isLoadingMore;

  AgencyDiscoveryState copyWith({
    List<Map<String, dynamic>>? creators,
    int? page,
    bool? hasMore,
    AgencyDiscoveryFilters? filters,
    bool? isLoadingMore,
  }) {
    return AgencyDiscoveryState(
      creators: creators ?? this.creators,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      filters: filters ?? this.filters,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class AgencyDiscoveryNotifier extends AsyncNotifier<AgencyDiscoveryState> {
  static const int _pageSize = 20;

  @override
  Future<AgencyDiscoveryState> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    try {
      final creators = await repo.getCreators(params: {'page': 1, 'limit': _pageSize});
      return AgencyDiscoveryState(
        creators: creators.cast<Map<String, dynamic>>(),
        page: 1,
        hasMore: creators.length == _pageSize,
        filters: const AgencyDiscoveryFilters(),
      );
    } catch (_) {
      return const AgencyDiscoveryState(
        creators: <Map<String, dynamic>>[],
        page: 1,
        hasMore: false,
        filters: AgencyDiscoveryFilters(),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(agencyRepositoryProvider);
      final creators = await repo.getCreators(params: {'page': 1, 'limit': _pageSize});
      return AgencyDiscoveryState(
        creators: creators.cast<Map<String, dynamic>>(),
        page: 1,
        hasMore: creators.length == _pageSize,
        filters: const AgencyDiscoveryFilters(),
      );
    });
  }
}

final agencyInvitesProvider = AsyncNotifierProvider<AgencyInvitesNotifier, List<Map<String, dynamic>>>(
  () => AgencyInvitesNotifier(),
);

class AgencyInvitesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    final invites = await repo.getInvites();
    return invites.cast<Map<String, dynamic>>();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final agencyRosterProvider = AsyncNotifierProvider<AgencyRosterNotifier, List<Map<String, dynamic>>>(
  () => AgencyRosterNotifier(),
);

class AgencyRosterNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    final roster = await repo.getRoster();
    return roster.cast<Map<String, dynamic>>();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final agencyPitchesProvider = AsyncNotifierProvider<AgencyPitchesNotifier, List<Map<String, dynamic>>>(
  () => AgencyPitchesNotifier(),
);

class AgencyPitchesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    final pitches = await repo.getPitches();
    return pitches.cast<Map<String, dynamic>>();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final agencyBidsProvider = AsyncNotifierProvider<AgencyBidsNotifier, List<Map<String, dynamic>>>(
  () => AgencyBidsNotifier(),
);

class AgencyBidsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    final bids = await repo.getBids();
    return bids.cast<Map<String, dynamic>>();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class AgencyCreditsNotifier extends AsyncNotifier<AgencyCreditsState> {
  @override
  Future<AgencyCreditsState> build() async {
    final profile = await ref.read(agencyRepositoryProvider).getProfile();
    return AgencyCreditsState(
      balance: profile['credit_balance'] ?? 0,
      transactions: [],
    );
  }

  Future<RazorpayOrder> initiateCreditPurchase(String pack) async {
    final repo = ref.read(agencyRepositoryProvider);
    return repo.initiateCreditPurchase(pack);
  }

  Future<void> verifyCreditPurchase(Map<String, String> paymentData) async {
    final repo = ref.read(agencyRepositoryProvider);
    await repo.verifyCreditPurchase(paymentData);
    ref.invalidateSelf();
  }
}

class AgencyCreditsState {
  const AgencyCreditsState({
    required this.balance,
    required this.transactions,
  });

  final int balance;
  final List<dynamic> transactions;
}

final agencyCreditsProvider =
    AsyncNotifierProvider<AgencyCreditsNotifier, AgencyCreditsState>(
  () => AgencyCreditsNotifier(),
);

final agencyBrandsProvider =
    AsyncNotifierProvider<AgencyBrandsNotifier, AgencyBrandsState>(
  () => AgencyBrandsNotifier(),
);

class AgencyBrandsState {
  const AgencyBrandsState({
    required this.brands,
    required this.page,
    required this.hasMore,
  });

  final List<Map<String, dynamic>> brands;
  final int page;
  final bool hasMore;
}

class AgencyBrandsNotifier extends AsyncNotifier<AgencyBrandsState> {
  static const int _pageSize = 20;

  @override
  Future<AgencyBrandsState> build() async {
    final repo = ref.read(agencyRepositoryProvider);
    try {
      final brands = await repo.getBrands(params: {'page': 1, 'limit': _pageSize});
      return AgencyBrandsState(
        brands: brands.cast<Map<String, dynamic>>(),
        page: 1,
        hasMore: brands.length == _pageSize,
      );
    } catch (_) {
      return const AgencyBrandsState(
        brands: <Map<String, dynamic>>[],
        page: 1,
        hasMore: false,
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(agencyRepositoryProvider);
      final brands = await repo.getBrands(params: {'page': 1, 'limit': _pageSize});
      return AgencyBrandsState(
        brands: brands.cast<Map<String, dynamic>>(),
        page: 1,
        hasMore: brands.length == _pageSize,
      );
    });
  }
}