import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/creator_models.dart';
import '../data/models/home_carousel_item.dart';
import '../data/models/paginated_result.dart';
import '../data/repositories/creator_repository.dart';
import '../data/services/api_service.dart';
import 'chat_provider.dart';

final creatorRepositoryProvider = Provider<CreatorRepository>((ref) {
  return CreatorRepository(ref.read(apiServiceProvider));
});

class CreatorCampaignFilters {
  const CreatorCampaignFilters({
    this.niche,
    this.collabType,
    this.minBudget,
    this.maxBudget,
    this.state,
    this.city,
    this.includePanIndia = true,
  });

  final String? niche;
  final CampaignCollabType? collabType;
  final int? minBudget;
  final int? maxBudget;
  final String? state;
  final String? city;
  final bool includePanIndia;

  CreatorCampaignFilters copyWith({
    Object? niche = _sentinel,
    Object? collabType = _sentinel,
    Object? minBudget = _sentinel,
    Object? maxBudget = _sentinel,
    Object? state = _sentinel,
    Object? city = _sentinel,
    Object? includePanIndia = _sentinel,
  }) {
    return CreatorCampaignFilters(
      niche: identical(niche, _sentinel) ? this.niche : niche as String?,
      collabType: identical(collabType, _sentinel)
          ? this.collabType
          : collabType as CampaignCollabType?,
      minBudget:
          identical(minBudget, _sentinel) ? this.minBudget : minBudget as int?,
      maxBudget:
          identical(maxBudget, _sentinel) ? this.maxBudget : maxBudget as int?,
      state: identical(state, _sentinel) ? this.state : state as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
      includePanIndia: identical(includePanIndia, _sentinel)
          ? this.includePanIndia
          : includePanIndia as bool,
    );
  }
}

class CreatorCampaignsState {
  const CreatorCampaignsState({
    required this.campaigns,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.filters = const CreatorCampaignFilters(),
  });

  final List<Campaign> campaigns;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final CreatorCampaignFilters filters;

  CreatorCampaignsState copyWith({
    List<Campaign>? campaigns,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    CreatorCampaignFilters? filters,
  }) {
    return CreatorCampaignsState(
      campaigns: campaigns ?? this.campaigns,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
    );
  }
}

class CreatorHomeData {
  const CreatorHomeData({
    required this.profile,
    required this.wallet,
    required this.bids,
    required this.requests,
    required this.activeCollabs,
    required this.campaigns,
    required this.carouselItems,
  });

  final CreatorProfile profile;
  final WalletData wallet;
  final List<Bid> bids;
  final List<CollabRequest> requests;
  final List<Collab> activeCollabs;
  final List<Campaign> campaigns;
  final List<HomeCarouselItem> carouselItems;

  int get activeBidsCount => bids
      .where((bid) => bid.status != 'withdrawn' && bid.status != 'rejected')
      .length;

  bool hasBidForCampaign(String campaignId) {
    return bids.any(
      (bid) => bid.campaignId == campaignId && bid.status != 'withdrawn',
    );
  }
}

class CreatorProfileNotifier extends AsyncNotifier<CreatorProfile> {
  StreamSubscription<List<Map<String, dynamic>>>? _profileStreamSub;
  bool _seenInitialRealtimeSnapshot = false;
  String? _lastRealtimeSnapshotSignature;

  @override
  Future<CreatorProfile> build() async {
    _attachRealtimeListener();
    return ref.read(creatorRepositoryProvider).fetchCreatorProfile();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated =
          await ref.read(creatorRepositoryProvider).updateProfile(data);
      return updated;
    });
    ref.invalidate(walletProvider);
    ref.invalidate(creatorHomeProvider);
  }

  Future<void> updateStartingPrice(int pricePaise) {
    return updateProfile({'starting_price': pricePaise});
  }

  void _attachRealtimeListener() {
    if (_profileStreamSub != null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _profileStreamSub = Supabase.instance.client
        .from('creator_profiles')
        .stream(primaryKey: const ['id'])
        .eq('id', userId)
        .listen((rows) {
          final firstRow =
              rows.isNotEmpty ? rows.first : const <String, dynamic>{};
          final signature = _stableSnapshotSignature(firstRow);

          // The stream emits an initial snapshot right after subscription.
          // We already fetched profile data in build(), so skip this first emit.
          if (!_seenInitialRealtimeSnapshot) {
            _seenInitialRealtimeSnapshot = true;
            _lastRealtimeSnapshotSignature = signature;
            return;
          }

          if (_lastRealtimeSnapshotSignature == signature) {
            return;
          }

          _lastRealtimeSnapshotSignature = signature;
          ref.invalidateSelf();
        });

    ref.onDispose(() {
      _profileStreamSub?.cancel();
      _profileStreamSub = null;
    });
  }

  String _stableSnapshotSignature(Map<String, dynamic> row) {
    dynamic normalize(dynamic value) {
      if (value is Map) {
        final entries = value.entries.toList()
          ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
        return {
          for (final entry in entries)
            entry.key.toString(): normalize(entry.value),
        };
      }

      if (value is List) {
        return value.map(normalize).toList();
      }

      return value;
    }

    return jsonEncode(normalize(row));
  }
}

class MyBidsNotifier extends AsyncNotifier<List<Bid>> {
  @override
  Future<List<Bid>> build() async {
    return ref.read(creatorRepositoryProvider).fetchMyBids();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class RequestsNotifier extends AsyncNotifier<List<CollabRequest>> {
  @override
  Future<List<CollabRequest>> build() async {
    return ref.read(creatorRepositoryProvider).fetchRequests();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class CreatorCollabsNotifier extends AsyncNotifier<List<Collab>> {
  @override
  Future<List<Collab>> build() async {
    return ref.read(creatorRepositoryProvider).fetchCreatorCollabs();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class WalletNotifier extends AsyncNotifier<WalletData> {
  @override
  Future<WalletData> build() async {
    return ref.read(creatorRepositoryProvider).fetchWallet();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class EventInvitesNotifier extends AsyncNotifier<List<EventInvite>> {
  @override
  Future<List<EventInvite>> build() async {
    return ref.read(creatorRepositoryProvider).fetchEventInvites();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class TicketsNotifier extends AsyncNotifier<List<EventTicket>> {
  @override
  Future<List<EventTicket>> build() async {
    return ref.read(creatorRepositoryProvider).fetchTickets();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

class CreatorCampaignsNotifier extends AsyncNotifier<CreatorCampaignsState> {
  static const int _pageSize = 20;

  @override
  Future<CreatorCampaignsState> build() async {
    final result = await _fetchPage(
      page: 1,
      filters: const CreatorCampaignFilters(),
    );

    return CreatorCampaignsState(
      campaigns: result.items,
      page: result.page,
      hasMore: result.hasMore,
      filters: const CreatorCampaignFilters(),
    );
  }

  Future<void> refresh() async {
    final currentFilters =
        state.valueOrNull?.filters ?? const CreatorCampaignFilters();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _fetchPage(page: 1, filters: currentFilters);
      return CreatorCampaignsState(
        campaigns: result.items,
        page: result.page,
        hasMore: result.hasMore,
        filters: currentFilters,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final result = await AsyncValue.guard(() async {
      final nextPage = current.page + 1;
      final nextResult =
          await _fetchPage(page: nextPage, filters: current.filters);
      return current.copyWith(
        campaigns: [...current.campaigns, ...nextResult.items],
        page: nextResult.page,
        hasMore: nextResult.hasMore,
        isLoadingMore: false,
      );
    });

    state = result;
  }

  Future<void> applyFilters(CreatorCampaignFilters filters) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _fetchPage(page: 1, filters: filters);
      return CreatorCampaignsState(
        campaigns: result.items,
        page: result.page,
        hasMore: result.hasMore,
        filters: filters,
      );
    });
  }

  Future<PaginatedResult<Campaign>> _fetchPage({
    required int page,
    required CreatorCampaignFilters filters,
  }) {
    return ref.read(creatorRepositoryProvider).fetchCampaigns(
          page: page,
          limit: _pageSize,
          niche: filters.niche,
          collabType: filters.collabType,
          minBudget: filters.minBudget,
          maxBudget: filters.maxBudget,
          state: filters.state,
          city: filters.city,
          includePanIndia: filters.includePanIndia,
        );
  }
}

class CreatorHomeNotifier extends AsyncNotifier<CreatorHomeData> {
  @override
  Future<CreatorHomeData> build() async {
    return _fetchHomeData();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> refreshSilently() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final next = await AsyncValue.guard(_fetchHomeData);
    if (next.hasValue) {
      state = next;
    }
  }

  Future<CreatorHomeData> _fetchHomeData() async {
    final repository = ref.read(creatorRepositoryProvider);

    final profileFuture = repository.fetchCreatorProfile();
    final walletFuture = repository.fetchWallet();
    final bidsFuture = repository.fetchMyBids();
    final requestsFuture = repository.fetchRequests();
    final collabsFuture = repository.fetchCreatorCollabs();
    final campaignsFuture = repository.fetchCampaigns(limit: 10);
    final carouselFuture = repository.fetchHomeCarouselItems();

    final profile = await profileFuture;
    final wallet = await walletFuture;
    final bids = await bidsFuture;
    final requests = await requestsFuture;
    final collabs = await collabsFuture;
    final campaigns = await campaignsFuture;
    final carouselItems = await carouselFuture;

    return CreatorHomeData(
      profile: profile,
      wallet: wallet,
      bids: bids,
      requests: requests,
      activeCollabs: collabs,
      campaigns: campaigns.items,
      carouselItems: carouselItems,
    );
  }
}

class CreatorActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitBid({
    required String campaignId,
    int? bidAmount,
    String? deliverables,
    bool includeBarter = false,
    required String message,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(creatorRepositoryProvider).placeBid(
            campaignId: campaignId,
            bidAmount: bidAmount,
            deliverables: deliverables,
            includeBarter: includeBarter,
            message: message,
          );
      _invalidateBidRelated();
    });
  }

  Future<void> withdrawBid(String bidId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(creatorRepositoryProvider).withdrawBid(bidId);
      _invalidateBidRelated();
    });
  }

  Future<void> respondToRequest({
    required String requestId,
    required String action,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(creatorRepositoryProvider)
          .respondToRequest(requestId: requestId, action: action);
      ref.invalidate(requestsProvider);
      ref.invalidate(creatorCollabsProvider);
      ref.invalidate(chatListProvider);
      ref.invalidate(walletProvider);
      ref.invalidate(creatorHomeProvider);
    });
  }

  Future<void> updateMilestone({
    required String collabId,
    required String milestone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(creatorRepositoryProvider)
          .updateCollabMilestone(collabId: collabId, milestone: milestone);
      ref.invalidate(creatorCollabsProvider);
      ref.invalidate(creatorHomeProvider);
    });
  }

  Future<RazorpayOrder> topUpWallet(int amountPaise) async {
    final order = await ref
        .read(creatorRepositoryProvider)
        .createWalletTopupOrder(amountPaise);
    return order;
  }

  Future<int> verifyWalletTopup({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final newBalance =
        await ref.read(creatorRepositoryProvider).verifyWalletTopup(
              orderId: orderId,
              paymentId: paymentId,
              signature: signature,
            );
    ref.invalidate(walletProvider);
    ref.invalidate(creatorProfileProvider);
    ref.invalidate(creatorHomeProvider);
    return newBalance;
  }

  Future<void> respondToEventInvite({
    required String inviteId,
    required String action,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(creatorRepositoryProvider)
          .respondToEventInvite(inviteId: inviteId, action: action);
      ref.invalidate(eventInvitesProvider);
      ref.invalidate(ticketsProvider);
      ref.invalidate(creatorHomeProvider);
    });
  }

  void _invalidateBidRelated() {
    ref.invalidate(myBidsProvider);
    ref.invalidate(creatorCampaignsProvider);
    ref.invalidate(creatorProfileProvider);
    ref.invalidate(creatorHomeProvider);
  }
}

final creatorProfileProvider =
    AsyncNotifierProvider<CreatorProfileNotifier, CreatorProfile>(
  CreatorProfileNotifier.new,
);

final myBidsProvider = AsyncNotifierProvider<MyBidsNotifier, List<Bid>>(
  MyBidsNotifier.new,
);

final requestsProvider =
    AsyncNotifierProvider<RequestsNotifier, List<CollabRequest>>(
  RequestsNotifier.new,
);

final creatorCollabsProvider =
    AsyncNotifierProvider<CreatorCollabsNotifier, List<Collab>>(
  CreatorCollabsNotifier.new,
);

class CreatorCompletedCollabsNotifier extends AsyncNotifier<List<Collab>> {
  @override
  Future<List<Collab>> build() async {
    return ref.read(creatorRepositoryProvider).fetchCreatorCompletedCollabs();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final creatorCompletedCollabsProvider =
    AsyncNotifierProvider<CreatorCompletedCollabsNotifier, List<Collab>>(
  CreatorCompletedCollabsNotifier.new,
);

final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletData>(
  WalletNotifier.new,
);

final eventInvitesProvider =
    AsyncNotifierProvider<EventInvitesNotifier, List<EventInvite>>(
  EventInvitesNotifier.new,
);

final ticketsProvider =
    AsyncNotifierProvider<TicketsNotifier, List<EventTicket>>(
  TicketsNotifier.new,
);

final creatorCampaignsProvider =
    AsyncNotifierProvider<CreatorCampaignsNotifier, CreatorCampaignsState>(
  CreatorCampaignsNotifier.new,
);

final creatorHomeProvider =
    AsyncNotifierProvider<CreatorHomeNotifier, CreatorHomeData>(
  CreatorHomeNotifier.new,
);

final creatorActionsProvider =
    AsyncNotifierProvider<CreatorActionsNotifier, void>(
  CreatorActionsNotifier.new,
);

final campaignDetailProvider =
    FutureProvider.family<Campaign?, String>((ref, id) async {
  final existing = ref.watch(creatorCampaignsProvider).valueOrNull;
  if (existing != null) {
    final fromList =
        existing.campaigns.where((campaign) => campaign.id == id).toList();
    if (fromList.isNotEmpty) {
      return fromList.first;
    }
  }

  final page = await ref
      .read(creatorRepositoryProvider)
      .fetchCampaigns(page: 1, limit: 50);
  final matches = page.items.where((campaign) => campaign.id == id).toList();
  return matches.isEmpty ? null : matches.first;
});

const _sentinel = Object();
