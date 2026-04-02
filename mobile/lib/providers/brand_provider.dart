import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/credit_guard.dart';
import '../data/models/brand_models.dart';
import '../data/models/paginated_result.dart';
import '../data/repositories/brand_repository.dart';
import '../data/services/api_service.dart';
import 'chat_provider.dart';

export '../data/models/brand_models.dart';

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return BrandRepository(ref.read(apiServiceProvider));
});

class CreatorDiscoveryFilters {
  const CreatorDiscoveryFilters({
    this.niche,
    this.tier,
    this.minFollowers,
    this.maxPrice,
    this.platform,
  });

  final String? niche;
  final String? tier;
  final int? minFollowers;
  final int? maxPrice;
  final String? platform;

  CreatorDiscoveryFilters copyWith({
    Object? niche = _sentinel,
    Object? tier = _sentinel,
    Object? minFollowers = _sentinel,
    Object? maxPrice = _sentinel,
    Object? platform = _sentinel,
  }) {
    return CreatorDiscoveryFilters(
      niche: identical(niche, _sentinel) ? this.niche : niche as String?,
      tier: identical(tier, _sentinel) ? this.tier : tier as String?,
      minFollowers: identical(minFollowers, _sentinel)
          ? this.minFollowers
          : minFollowers as int?,
      maxPrice:
          identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as int?,
      platform:
          identical(platform, _sentinel) ? this.platform : platform as String?,
    );
  }
}

class CreatorDiscoveryState {
  const CreatorDiscoveryState({
    required this.creators,
    required this.page,
    required this.hasMore,
    required this.filters,
    this.isLoadingMore = false,
  });

  final List<CreatorDiscovery> creators;
  final int page;
  final bool hasMore;
  final CreatorDiscoveryFilters filters;
  final bool isLoadingMore;

  CreatorDiscoveryState copyWith({
    List<CreatorDiscovery>? creators,
    int? page,
    bool? hasMore,
    CreatorDiscoveryFilters? filters,
    bool? isLoadingMore,
  }) {
    return CreatorDiscoveryState(
      creators: creators ?? this.creators,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      filters: filters ?? this.filters,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class BrandProfileNotifier extends AsyncNotifier<BrandProfile> {
  @override
  Future<BrandProfile> build() async {
    return ref.read(brandRepositoryProvider).getProfile();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<BrandProfile> updateProfile(Map<String, dynamic> data) async {
    final profile = await ref.read(brandRepositoryProvider).updateProfile(data);
    state = AsyncData(profile);
    return profile;
  }
}

class CreatorDiscoveryNotifier extends AsyncNotifier<CreatorDiscoveryState> {
  static const int _pageSize = 20;

  @override
  Future<CreatorDiscoveryState> build() async {
    final result = await _fetchPage(
      page: 1,
      filters: const CreatorDiscoveryFilters(),
    );

    return CreatorDiscoveryState(
      creators: result.items,
      page: result.page,
      hasMore: result.hasMore,
      filters: const CreatorDiscoveryFilters(),
    );
  }

  Future<void> refresh() async {
    final filters =
        state.valueOrNull?.filters ?? const CreatorDiscoveryFilters();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _fetchPage(page: 1, filters: filters);
      return CreatorDiscoveryState(
        creators: result.items,
        page: result.page,
        hasMore: result.hasMore,
        filters: filters,
      );
    });
  }

  Future<void> applyFilters(CreatorDiscoveryFilters filters) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _fetchPage(page: 1, filters: filters);
      return CreatorDiscoveryState(
        creators: result.items,
        page: result.page,
        hasMore: result.hasMore,
        filters: filters,
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
        creators: [...current.creators, ...nextResult.items],
        page: nextResult.page,
        hasMore: nextResult.hasMore,
        isLoadingMore: false,
      );
    });

    state = result;
  }

  Future<PaginatedResult<CreatorDiscovery>> _fetchPage({
    required int page,
    required CreatorDiscoveryFilters filters,
  }) {
    return ref.read(brandRepositoryProvider).getCreators(
          niche: filters.niche,
          tier: filters.tier,
          minFollowers: filters.minFollowers,
          maxPrice: filters.maxPrice,
          platform: filters.platform,
          page: page,
          limit: _pageSize,
        );
  }
}

class BrandRequestsNotifier extends AsyncNotifier<List<CollabRequest>> {
  @override
  Future<List<CollabRequest>> build() async {
    return ref.read(brandRepositoryProvider).getRequests();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<CollabRequest> sendRequest(Map<String, dynamic> data) async {
    final request = await ref.read(brandRepositoryProvider).sendRequest(data);
    final current = state.valueOrNull ?? const <CollabRequest>[];
    state = AsyncData([request, ...current]);
    ref.invalidateSelf();
    return request;
  }

  Future<void> cancelRequest(String requestId) async {
    await ref.read(brandRepositoryProvider).cancelRequest(requestId);
    final current = state.valueOrNull ?? const <CollabRequest>[];
    state = AsyncData(current.where((item) => item.id != requestId).toList());
  }
}

class BrandCampaignsNotifier extends AsyncNotifier<List<Campaign>> {
  @override
  Future<List<Campaign>> build() async {
    return ref.read(brandRepositoryProvider).getCampaigns();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Campaign> postCampaign(Map<String, dynamic> data) async {
    final campaign = await ref.read(brandRepositoryProvider).postCampaign(data);
    final current = state.valueOrNull ?? const <Campaign>[];
    state = AsyncData([campaign, ...current]);
    return campaign;
  }

  Future<Campaign> updateCampaign(String id, Map<String, dynamic> data) async {
    final updated =
        await ref.read(brandRepositoryProvider).updateCampaign(id, data);
    final current = state.valueOrNull ?? const <Campaign>[];
    state = AsyncData(
      current
          .map((campaign) => campaign.id == id ? updated : campaign)
          .toList(),
    );
    return updated;
  }
}

class CampaignBidsNotifier extends FamilyAsyncNotifier<List<Bid>, String> {
  @override
  Future<List<Bid>> build(String campaignId) async {
    return ref.read(brandRepositoryProvider).getCampaignBids(campaignId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Bid> respondToBid(String bidId, String action) async {
    final campaignId = arg;
    final isAccept = action == 'accept';

    if (isAccept) {
      await ref.read(creditsProvider.notifier).deductLocally(1);
    }

    try {
      final response = await ref
          .read(brandRepositoryProvider)
          .respondToBid(campaignId, bidId, action);

      final current = state.valueOrNull ?? const <Bid>[];
      final next = current.map((bid) {
        if (bid.id != bidId) return bid;
        return bid.copyWith(
          status: response.status,
          isAccepted: isAccept,
          isUnlocked: isAccept,
        );
      }).toList();

      state = AsyncData(next);

      if (isAccept) {
        ref.invalidate(brandCampaignsProvider);
        ref.invalidate(chatListProvider);
      }

      return response;
    } catch (_) {
      if (isAccept) {
        await ref.read(creditsProvider.notifier).deductLocally(-1);
      }
      rethrow;
    }
  }
}

class CreditsNotifier extends AsyncNotifier<CreditsData> {
  @override
  Future<CreditsData> build() async {
    return ref.read(brandRepositoryProvider).getCredits();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> setData(CreditsData data) async {
    state = AsyncData(data);
  }

  Future<void> deductLocally(int amount) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final nextBalance = (current.balance - amount).clamp(0, 999999).toInt();
    final transaction = CreditTransaction(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      type: amount > 0 ? 'deduct' : 'topup',
      amount: amount.abs(),
      reason: amount > 0 ? 'optimistic_deduct' : 'optimistic_revert',
      balanceAfter: nextBalance,
      createdAt: DateTime.now(),
    );

    state = AsyncData(
      current.copyWith(
        balance: nextBalance,
        transactions: [transaction, ...current.transactions],
      ),
    );
  }

  Future<RazorpayOrder> initiateCreditPurchase(String pack) async {
    return ref.read(brandRepositoryProvider).initiateCreditPurchase(pack);
  }

  Future<void> verifyCreditPurchase(Map<String, String> paymentData) async {
    await ref.read(brandRepositoryProvider).verifyCreditPurchase(paymentData);
    await refresh();
  }
}

class BrandEventsNotifier extends AsyncNotifier<List<BrandEvent>> {
  @override
  Future<List<BrandEvent>> build() async {
    return ref.read(brandRepositoryProvider).getEvents();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<BrandEvent> createEvent(Map<String, dynamic> data) async {
    final event = await ref.read(brandRepositoryProvider).createEvent(data);
    final current = state.valueOrNull ?? const <BrandEvent>[];
    state = AsyncData([event, ...current]);
    return event;
  }
}

class EventInvitesNotifier
    extends FamilyAsyncNotifier<List<EventInvite>, String> {
  StreamSubscription<dynamic>? _inviteSubscription;

  @override
  Future<List<EventInvite>> build(String eventId) async {
    final invites =
        await ref.read(brandRepositoryProvider).getEventInvites(eventId);

    final stream = Supabase.instance.client
        .from('event_invites')
        .stream(primaryKey: const ['id']).eq('event_id', eventId);

    _inviteSubscription = stream.listen((dynamic rows) {
      final current = state.valueOrNull;
      if (current == null || rows is! List) return;

      final tableRows = rows
          .whereType<Map>()
          .map((entry) => entry.map((k, v) => MapEntry(k.toString(), v)))
          .toList();

      final updated = current.map((invite) {
        final row =
            tableRows.where((item) => item['id'] == invite.id).firstOrNull;
        if (row == null) return invite;

        return invite.copyWith(
          status:
              _inviteStatusFromString(row['status']?.toString() ?? 'pending'),
          ticketCode: row['ticket_code']?.toString(),
          acceptedAt: DateTime.tryParse(row['accepted_at']?.toString() ?? ''),
        );
      }).toList();

      state = AsyncData(updated);
    });

    ref.onDispose(() {
      _inviteSubscription?.cancel();
    });

    return invites;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<EventInvite> sendInvite(String creatorId) async {
    await ref.read(creditsProvider.notifier).deductLocally(2);

    try {
      final invite = await ref
          .read(brandRepositoryProvider)
          .sendEventInvite(arg, creatorId);

      final current = state.valueOrNull ?? const <EventInvite>[];
      final alreadyExists = current.any((item) => item.id == invite.id);
      if (!alreadyExists) {
        state = AsyncData([invite, ...current]);
      }

      ref.invalidate(brandEventsProvider);
      return invite;
    } catch (_) {
      await ref.read(creditsProvider.notifier).deductLocally(-2);
      rethrow;
    }
  }
}

class BrandState {
  const BrandState({
    this.brandProfile,
    this.creators = const <CreatorPreview>[],
    this.campaigns = const <Campaign>[],
    this.activeCollabs = const <ActiveCollabSummary>[],
    this.events = const <BrandEvent>[],
    this.creditBalance = 0,
    this.creditTransactions = const <CreditTransaction>[],
    this.bidsByCampaign = const <String, List<CampaignBid>>{},
    this.invitesByEvent = const <String, List<EventInvite>>{},
    this.activeFilter = 'All',
    this.isLoading = false,
    this.isDiscoveryLoading = false,
    this.isBidsLoading = false,
    this.isEventsLoading = false,
    this.isCreditsLoading = false,
    this.lastHomeSyncedAt,
    this.error,
  });

  final BrandProfile? brandProfile;
  final List<CreatorPreview> creators;
  final List<Campaign> campaigns;
  final List<ActiveCollabSummary> activeCollabs;
  final List<BrandEvent> events;
  final int creditBalance;
  final List<CreditTransaction> creditTransactions;
  final Map<String, List<CampaignBid>> bidsByCampaign;
  final Map<String, List<EventInvite>> invitesByEvent;
  final String activeFilter;
  final bool isLoading;
  final bool isDiscoveryLoading;
  final bool isBidsLoading;
  final bool isEventsLoading;
  final bool isCreditsLoading;
  final DateTime? lastHomeSyncedAt;
  final String? error;

  List<CreatorPreview> get filteredCreators {
    final filter = activeFilter.trim().toLowerCase();
    if (filter.isEmpty || filter == 'all') return creators;

    return creators.where((creator) {
      final inNiche =
          creator.niches.map((item) => item.toLowerCase()).contains(filter);
      return inNiche;
    }).toList();
  }

  int get activeCampaignCount {
    return campaigns
        .where((campaign) => campaign.status == CampaignStatus.active)
        .length;
  }

  List<BrandEvent> get upcomingEvents {
    final now = DateTime.now();
    final items = events.where((event) {
      final hasEnded = event.dateTime.isBefore(now) ||
          event.status == BrandEventStatus.completed ||
          event.status == BrandEventStatus.cancelled;
      return !hasEnded;
    }).toList();
    items.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return items;
  }

  List<BrandEvent> get pastEvents {
    final now = DateTime.now();
    final items = events.where((event) {
      final hasEnded = event.dateTime.isBefore(now) ||
          event.status == BrandEventStatus.completed ||
          event.status == BrandEventStatus.cancelled;
      return hasEnded;
    }).toList();
    items.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return items;
  }

  BrandState copyWith({
    Object? brandProfile = _sentinel,
    List<CreatorPreview>? creators,
    List<Campaign>? campaigns,
    List<ActiveCollabSummary>? activeCollabs,
    List<BrandEvent>? events,
    int? creditBalance,
    List<CreditTransaction>? creditTransactions,
    Map<String, List<CampaignBid>>? bidsByCampaign,
    Map<String, List<EventInvite>>? invitesByEvent,
    String? activeFilter,
    bool? isLoading,
    bool? isDiscoveryLoading,
    bool? isBidsLoading,
    bool? isEventsLoading,
    bool? isCreditsLoading,
    Object? lastHomeSyncedAt = _sentinel,
    Object? error = _sentinel,
  }) {
    return BrandState(
      brandProfile: identical(brandProfile, _sentinel)
          ? this.brandProfile
          : brandProfile as BrandProfile?,
      creators: creators ?? this.creators,
      campaigns: campaigns ?? this.campaigns,
      activeCollabs: activeCollabs ?? this.activeCollabs,
      events: events ?? this.events,
      creditBalance: creditBalance ?? this.creditBalance,
      creditTransactions: creditTransactions ?? this.creditTransactions,
      bidsByCampaign: bidsByCampaign ?? this.bidsByCampaign,
      invitesByEvent: invitesByEvent ?? this.invitesByEvent,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      isDiscoveryLoading: isDiscoveryLoading ?? this.isDiscoveryLoading,
      isBidsLoading: isBidsLoading ?? this.isBidsLoading,
      isEventsLoading: isEventsLoading ?? this.isEventsLoading,
      isCreditsLoading: isCreditsLoading ?? this.isCreditsLoading,
      lastHomeSyncedAt: identical(lastHomeSyncedAt, _sentinel)
          ? this.lastHomeSyncedAt
          : lastHomeSyncedAt as DateTime?,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class BrandNotifier extends Notifier<BrandState> {
  final Map<String, StreamSubscription<dynamic>> _inviteSubscriptions =
      <String, StreamSubscription<dynamic>>{};

  BrandRepository get _repo => ref.read(brandRepositoryProvider);

  @override
  BrandState build() {
    ref.onDispose(() {
      for (final subscription in _inviteSubscriptions.values) {
        subscription.cancel();
      }
      _inviteSubscriptions.clear();
    });

    return const BrandState();
  }

  Future<void> fetchBrandHome({
    bool showLoader = false,
    bool force = false,
  }) async {
    final now = DateTime.now();
    final hasCachedHome = _hasCachedHomeData(state);
    final recentlySynced = state.lastHomeSyncedAt != null &&
        now.difference(state.lastHomeSyncedAt!) < const Duration(seconds: 45);

    if (!force && hasCachedHome && recentlySynced) {
      return;
    }

    final shouldShowLoader = showLoader || !hasCachedHome;
    if (shouldShowLoader) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }

    final profileFuture = _safe(() => _repo.getProfile());
    final creatorsFuture = _safe(() => _repo.getCreators(page: 1, limit: 40));
    final campaignsFuture = _safe(() => _repo.getCampaigns());
    final activeCollabsFuture = _safe(() => _repo.getActiveCollabs());
    final creditsFuture = _safe(() => _repo.getCredits());

    final profileResult = await profileFuture;
    final creatorsResult = await creatorsFuture;
    final campaignsResult = await campaignsFuture;
    final activeCollabsResult = await activeCollabsFuture;
    final creditsResult = await creditsFuture;

    final firstError = profileResult.error ??
        creatorsResult.error ??
        campaignsResult.error ??
        activeCollabsResult.error ??
        creditsResult.error;

    final profile = profileResult.data;
    final creators = creatorsResult.data;
    final campaigns = campaignsResult.data;
    final activeCollabs = activeCollabsResult.data;
    final credits = creditsResult.data;

    state = state.copyWith(
      brandProfile: profile ?? state.brandProfile,
      creators: creators?.items ?? state.creators,
      campaigns: campaigns ?? state.campaigns,
      activeCollabs: activeCollabs ?? state.activeCollabs,
      creditBalance: credits?.balance ?? state.creditBalance,
      creditTransactions: credits?.transactions ?? state.creditTransactions,
      isLoading: false,
      lastHomeSyncedAt: now,
      error: firstError?.toString(),
    );

    if (credits != null) {
      await ref.read(creditsProvider.notifier).setData(credits);
    }
  }

  Future<void> refreshBrandHome() async {
    await fetchBrandHome(force: true);
  }

  bool _hasCachedHomeData(BrandState current) {
    return current.brandProfile != null;
  }

  Future<_SafeResult<T>> _safe<T>(Future<T> Function() run) async {
    try {
      final data = await run();
      return _SafeResult<T>(data: data);
    } catch (error) {
      return _SafeResult<T>(error: error);
    }
  }

  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> fetchDiscovery() async {
    final shouldShowLoader = state.creators.isEmpty;
    state = state.copyWith(
      isDiscoveryLoading: shouldShowLoader,
      error: null,
    );

    try {
      final niche =
          state.activeFilter.toLowerCase() == 'all' ? null : state.activeFilter;

      final result = await _repo.getCreators(
        niche: niche,
        page: 1,
        limit: 40,
      );

      state = state.copyWith(
        creators: result.items,
        isDiscoveryLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDiscoveryLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchCampaignBids(String campaignId) async {
    final shouldShowLoader = (state.bidsByCampaign[campaignId] ?? const <CampaignBid>[]).isEmpty;
    state = state.copyWith(
      isBidsLoading: shouldShowLoader,
      error: null,
    );

    try {
      final bids = await _repo.getCampaignBids(campaignId);
      final nextBids = Map<String, List<CampaignBid>>.from(state.bidsByCampaign)
        ..[campaignId] = bids;

      state = state.copyWith(
        bidsByCampaign: nextBids,
        isBidsLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isBidsLoading: false,
        error: e.toString(),
      );
    }
  }

  Campaign? campaignById(String campaignId) {
    return state.campaigns.where((item) => item.id == campaignId).firstOrNull;
  }

  List<CampaignBid> bidsForCampaign(String campaignId) {
    return state.bidsByCampaign[campaignId] ?? const <CampaignBid>[];
  }

  Future<bool> sendDirectRequest({
    required String creatorId,
    required String creatorName,
  }) async {
    try {
      await _repo.sendRequest({
        'creator_id': creatorId,
        'message': 'Interested in collaborating with you, $creatorName.',
        'collab_type': 'paid',
      });

      ref.invalidate(brandRequestsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> postCampaign({
    required String title,
    required String description,
    required String category,
    required CampaignCollabType collabType,
    required int minBudget,
    required int maxBudget,
    required List<String> deliverables,
    required String requirements,
    required DateTime deadline,
    required int slotsAvailable,
  }) async {
    try {
      final campaign = await _repo.postCampaign({
        'title': title,
        'description': description,
        'niche': <String>[category],
        'collab_type': _collabTypeToApi(collabType),
        'budget_min': minBudget,
        'budget_max': maxBudget,
        'deliverables': deliverables,
        'requirements': requirements,
        'deadline': deadline.toIso8601String(),
        'slots': slotsAvailable,
      });

      state = state.copyWith(campaigns: [campaign, ...state.campaigns]);
      ref.invalidate(brandCampaignsProvider);
      ref.invalidate(chatListProvider);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> acceptBid({
    required String campaignId,
    required String bidId,
  }) async {
    try {
      await runWithCreditGuard<void>(
        availableCredits: state.creditBalance,
        cost: 1,
        applyOptimisticDelta: (delta) {
          return _applyCreditDelta(
            delta,
            spendReason: 'accept_bid',
            refundReason: 'accept_bid_rollback',
          );
        },
        action: () async {
          final response =
              await _repo.respondToBid(campaignId, bidId, 'accept');

          final existing =
              state.bidsByCampaign[campaignId] ?? const <CampaignBid>[];
          final nextBids = existing.map((bid) {
            if (bid.id != bidId) return bid;
            return bid.copyWith(
              status: response.status,
              isAccepted: true,
              isUnlocked: true,
            );
          }).toList();

          final bidsByCampaign =
              Map<String, List<CampaignBid>>.from(state.bidsByCampaign)
                ..[campaignId] = nextBids;

          state = state.copyWith(
            bidsByCampaign: bidsByCampaign,
            campaigns: state.campaigns
                .map((campaign) => campaign.id == campaignId
                    ? campaign.copyWith(bidCount: campaign.bidCount)
                    : campaign)
                .toList(),
          );
        },
      );

      ref.invalidate(brandCampaignsProvider);
      return true;
    } on InsufficientCreditsException {
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> fetchCredits() async {
    final shouldShowLoader = state.creditTransactions.isEmpty;
    state = state.copyWith(
      isCreditsLoading: shouldShowLoader,
      error: null,
    );

    try {
      final credits = await _repo.getCredits();
      state = state.copyWith(
        creditBalance: credits.balance,
        creditTransactions: credits.transactions,
        isCreditsLoading: false,
      );

      await ref.read(creditsProvider.notifier).setData(credits);
    } catch (e) {
      state = state.copyWith(
        isCreditsLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchEvents() async {
    final shouldShowLoader = state.events.isEmpty;
    state = state.copyWith(
      isEventsLoading: shouldShowLoader,
      error: null,
    );

    try {
      final events = await _repo.getEvents();
      state = state.copyWith(
        events: events,
        isEventsLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isEventsLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<String?> createEvent({
    required String eventName,
    required String eventType,
    required DateTime eventDate,
    required bool isVirtual,
    required int totalSlots,
    required List<String> targetNiches,
    required List<String> targetTiers,
    required String? venueName,
    required String? venueAddress,
    required String? city,
    required String? virtualLink,
    String? whatCreatorsGet,
  }) async {
    try {
      final event = await _repo.createEvent({
        'title': eventName,
        'event_name': eventName,
        'event_type': eventType.toLowerCase().replaceAll(' ', '_'),
        'event_date': eventDate.toIso8601String(),
        'eventDate': eventDate.toIso8601String(),
        'is_virtual': isVirtual,
        'total_slots': totalSlots,
        'target_niche': targetNiches,
        'target_tier': targetTiers.map((tier) => tier.toLowerCase()).toList(),
        'venue_name': venueName,
        'venue_address': venueAddress,
        'city': city,
        'virtual_link': virtualLink,
        'what_creators_get': whatCreatorsGet,
        'description': whatCreatorsGet,
      });

      state = state.copyWith(events: [event, ...state.events]);
      ref.invalidate(brandEventsProvider);
      return event.id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> fetchEventInvites(String eventId) async {
    try {
      final invites = await _repo.getEventInvites(eventId);
      final nextInvites =
          Map<String, List<EventInvite>>.from(state.invitesByEvent)
            ..[eventId] = invites;
      state = state.copyWith(invitesByEvent: nextInvites);

      _inviteSubscriptions[eventId]?.cancel();
      final stream = Supabase.instance.client
          .from('event_invites')
          .stream(primaryKey: const ['id']).eq('event_id', eventId);

      _inviteSubscriptions[eventId] = stream.listen((dynamic rows) {
        if (rows is! List) return;

        final rowMaps = rows
            .whereType<Map>()
            .map((entry) => entry.map((k, v) => MapEntry(k.toString(), v)))
            .toList();

        final current = state.invitesByEvent[eventId] ?? const <EventInvite>[];
        final updated = current.map((invite) {
          final row =
              rowMaps.where((item) => item['id'] == invite.id).firstOrNull;
          if (row == null) return invite;

          return invite.copyWith(
            status:
                _inviteStatusFromString(row['status']?.toString() ?? 'pending'),
            ticketCode: row['ticket_code']?.toString(),
            acceptedAt: DateTime.tryParse(row['accepted_at']?.toString() ?? ''),
          );
        }).toList();

        final updatedInvites =
            Map<String, List<EventInvite>>.from(state.invitesByEvent)
              ..[eventId] = updated;
        state = state.copyWith(invitesByEvent: updatedInvites);
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<EventInvite> invitesForEvent(String eventId) {
    return state.invitesByEvent[eventId] ?? const <EventInvite>[];
  }

  Future<bool> sendEventInvite({
    required String eventId,
    required CreatorPreview creator,
  }) async {
    try {
      final invite = await runWithCreditGuard<EventInvite>(
        availableCredits: state.creditBalance,
        cost: 2,
        applyOptimisticDelta: (delta) {
          return _applyCreditDelta(
            delta,
            spendReason: 'send_event_invite',
            refundReason: 'send_event_invite_rollback',
          );
        },
        action: () {
          return _repo.sendEventInvite(eventId, creator.id);
        },
      );

      final currentInvites =
          state.invitesByEvent[eventId] ?? const <EventInvite>[];
      final alreadyExists = currentInvites.any((item) => item.id == invite.id);
      final nextInvites = alreadyExists
          ? currentInvites
          : [
              invite.copyWith(creatorFirstName: creator.firstName),
              ...currentInvites
            ];

      final updatedInvites =
          Map<String, List<EventInvite>>.from(state.invitesByEvent)
            ..[eventId] = nextInvites;

      final updatedEvents = state.events.map((event) {
        if (event.id != eventId) return event;
        return event.copyWith(invitesSent: event.invitesSent + 1);
      }).toList();

      state = state.copyWith(
        invitesByEvent: updatedInvites,
        events: updatedEvents,
      );

      ref.invalidate(brandEventsProvider);
      return true;
    } on InsufficientCreditsException {
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> _applyCreditDelta(
    int delta, {
    required String spendReason,
    required String refundReason,
  }) async {
    final nextBalance = (state.creditBalance - delta).clamp(0, 999999).toInt();
    final transaction = CreditTransaction(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      type: delta > 0 ? 'deduct' : 'topup',
      amount: delta.abs(),
      reason: delta > 0 ? spendReason : refundReason,
      balanceAfter: nextBalance,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      creditBalance: nextBalance,
      creditTransactions: [transaction, ...state.creditTransactions],
    );

    await ref.read(creditsProvider.notifier).deductLocally(delta);
  }
}

final brandProfileProvider =
    AsyncNotifierProvider<BrandProfileNotifier, BrandProfile>(
  BrandProfileNotifier.new,
);

final creatorDiscoveryProvider =
    AsyncNotifierProvider<CreatorDiscoveryNotifier, CreatorDiscoveryState>(
  CreatorDiscoveryNotifier.new,
);

final brandRequestsProvider =
    AsyncNotifierProvider<BrandRequestsNotifier, List<CollabRequest>>(
  BrandRequestsNotifier.new,
);

final brandCampaignsProvider =
    AsyncNotifierProvider<BrandCampaignsNotifier, List<Campaign>>(
  BrandCampaignsNotifier.new,
);

final campaignBidsProvider =
    AsyncNotifierProviderFamily<CampaignBidsNotifier, List<Bid>, String>(
  CampaignBidsNotifier.new,
);

final creditsProvider = AsyncNotifierProvider<CreditsNotifier, CreditsData>(
  CreditsNotifier.new,
);

final brandEventsProvider =
    AsyncNotifierProvider<BrandEventsNotifier, List<BrandEvent>>(
  BrandEventsNotifier.new,
);

final eventInvitesProvider = AsyncNotifierProviderFamily<EventInvitesNotifier,
    List<EventInvite>, String>(
  EventInvitesNotifier.new,
);

final brandProvider = NotifierProvider<BrandNotifier, BrandState>(
  BrandNotifier.new,
);

String _collabTypeToApi(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'paid';
    case CampaignCollabType.barter:
      return 'barter';
    case CampaignCollabType.hybrid:
      return 'hybrid';
  }
}

EventInviteStatus _inviteStatusFromString(String statusRaw) {
  switch (statusRaw) {
    case 'accepted':
    case 'attended':
      return EventInviteStatus.accepted;
    case 'declined':
      return EventInviteStatus.declined;
    default:
      return EventInviteStatus.pending;
  }
}

const _sentinel = Object();

class _SafeResult<T> {
  const _SafeResult({this.data, this.error});

  final T? data;
  final Object? error;
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
