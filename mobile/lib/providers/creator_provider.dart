import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'campaign_provider.dart';

enum WalletTransactionType { topUp, feeDeduction }

class CreatorPastCollab {
  const CreatorPastCollab({
    required this.id,
    required this.brandCategory,
    required this.collabType,
    required this.rating,
    required this.amountPaise,
  });

  final String id;
  final String brandCategory;
  final CampaignCollabType collabType;
  final int rating;
  final int amountPaise;
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amountPaise,
    required this.createdAt,
    this.brandCategory,
  });

  final String id;
  final WalletTransactionType type;
  final int amountPaise;
  final DateTime createdAt;
  final String? brandCategory;
}

class CreatorProfile {
  const CreatorProfile({
    required this.firstName,
    required this.fullName,
    required this.tier,
    required this.followers,
    required this.engagementRate,
    required this.avgCollabPaise,
    required this.bio,
    required this.niches,
    required this.contentTypes,
    required this.startingPricePaise,
    required this.instagramConnected,
    required this.youtubeConnected,
    required this.walletBalance,
    required this.walletBalancePaise,
    required this.activeBidsCount,
  });

  final String firstName;
  final String fullName;
  final String tier;
  final int followers;
  final double engagementRate;
  final int avgCollabPaise;
  final String bio;
  final List<String> niches;
  final List<String> contentTypes;
  final int startingPricePaise;
  final bool instagramConnected;
  final bool youtubeConnected;
  final int walletBalance;
  final int walletBalancePaise;
  final int activeBidsCount;

  CreatorProfile copyWith({
    String? firstName,
    String? fullName,
    String? tier,
    int? followers,
    double? engagementRate,
    int? avgCollabPaise,
    String? bio,
    List<String>? niches,
    List<String>? contentTypes,
    int? startingPricePaise,
    bool? instagramConnected,
    bool? youtubeConnected,
    int? walletBalance,
    int? walletBalancePaise,
    int? activeBidsCount,
  }) {
    return CreatorProfile(
      firstName: firstName ?? this.firstName,
      fullName: fullName ?? this.fullName,
      tier: tier ?? this.tier,
      followers: followers ?? this.followers,
      engagementRate: engagementRate ?? this.engagementRate,
      avgCollabPaise: avgCollabPaise ?? this.avgCollabPaise,
      bio: bio ?? this.bio,
      niches: niches ?? this.niches,
      contentTypes: contentTypes ?? this.contentTypes,
      startingPricePaise: startingPricePaise ?? this.startingPricePaise,
      instagramConnected: instagramConnected ?? this.instagramConnected,
      youtubeConnected: youtubeConnected ?? this.youtubeConnected,
      walletBalance: walletBalance ?? this.walletBalance,
      walletBalancePaise: walletBalancePaise ?? this.walletBalancePaise,
      activeBidsCount: activeBidsCount ?? this.activeBidsCount,
    );
  }
}

class CreatorRequest {
  const CreatorRequest({
    required this.id,
    required this.brandInitial,
    required this.brandCategory,
    required this.budget,
    required this.collabType,
    required this.receivedAt,
  });

  final String id;
  final String brandInitial;
  final String brandCategory;
  final int budget;
  final CampaignCollabType collabType;
  final DateTime receivedAt;
}

class ActiveCollab {
  const ActiveCollab({
    required this.id,
    required this.brandCategory,
    required this.amount,
    required this.currentStep,
  });

  final String id;
  final String brandCategory;
  final int amount;
  final int currentStep;
}

class CreatorState {
  const CreatorState({
    this.creatorProfile,
    this.walletBalance = 0,
    this.walletBalancePaise = 0,
    this.activeBidsCount = 0,
    this.requests = const [],
    this.activeCollabs = const [],
    this.myBidCampaignIds = const [],
    this.pastCollabs = const [],
    this.transactions = const [],
    this.isLoading = false,
    this.isPastCollabsLoading = false,
    this.isWalletLoading = false,
    this.error,
  });

  final CreatorProfile? creatorProfile;
  final int walletBalance;
  final int walletBalancePaise;
  final int activeBidsCount;
  final List<CreatorRequest> requests;
  final List<ActiveCollab> activeCollabs;
  final List<String> myBidCampaignIds;
  final List<CreatorPastCollab> pastCollabs;
  final List<WalletTransaction> transactions;
  final bool isLoading;
  final bool isPastCollabsLoading;
  final bool isWalletLoading;
  final String? error;

  bool hasBidForCampaign(String campaignId) {
    return myBidCampaignIds.contains(campaignId);
  }

  CreatorState copyWith({
    CreatorProfile? creatorProfile,
    int? walletBalance,
    int? walletBalancePaise,
    int? activeBidsCount,
    List<CreatorRequest>? requests,
    List<ActiveCollab>? activeCollabs,
    List<String>? myBidCampaignIds,
    List<CreatorPastCollab>? pastCollabs,
    List<WalletTransaction>? transactions,
    bool? isLoading,
    bool? isPastCollabsLoading,
    bool? isWalletLoading,
    Object? error = _sentinel,
  }) {
    return CreatorState(
      creatorProfile: creatorProfile ?? this.creatorProfile,
      walletBalance: walletBalance ?? this.walletBalance,
      walletBalancePaise: walletBalancePaise ?? this.walletBalancePaise,
      activeBidsCount: activeBidsCount ?? this.activeBidsCount,
      requests: requests ?? this.requests,
      activeCollabs: activeCollabs ?? this.activeCollabs,
      myBidCampaignIds: myBidCampaignIds ?? this.myBidCampaignIds,
      pastCollabs: pastCollabs ?? this.pastCollabs,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isPastCollabsLoading: isPastCollabsLoading ?? this.isPastCollabsLoading,
      isWalletLoading: isWalletLoading ?? this.isWalletLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class CreatorNotifier extends Notifier<CreatorState> {
  @override
  CreatorState build() => const CreatorState();

  Future<void> fetchCreatorHome() async {
    if (state.isLoading || state.creatorProfile != null) return;
    await _loadCreatorHome();
  }

  Future<void> fetchCreatorProfile() async {
    if (state.creatorProfile == null) {
      await _loadCreatorHome();
      return;
    }

    if (state.pastCollabs.isNotEmpty || state.isPastCollabsLoading) return;

    state = state.copyWith(isPastCollabsLoading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      isPastCollabsLoading: false,
      pastCollabs: _mockPastCollabs,
      error: null,
    );
  }

  Future<void> fetchWallet() async {
    if (state.creatorProfile == null) {
      await _loadCreatorHome();
      return;
    }

    if (state.transactions.isNotEmpty || state.isWalletLoading) return;

    state = state.copyWith(isWalletLoading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(
      isWalletLoading: false,
      transactions: _mockTransactions,
      error: null,
    );
  }

  Future<void> refreshCreatorHome() async {
    await _loadCreatorHome();
  }

  Future<void> refreshCreatorProfile() async {
    state = state.copyWith(isPastCollabsLoading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isPastCollabsLoading: false,
      pastCollabs: _mockPastCollabs,
      error: null,
    );
  }

  Future<void> refreshWallet() async {
    state = state.copyWith(isWalletLoading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    state = state.copyWith(
      isWalletLoading: false,
      transactions: _mockTransactions,
      error: null,
    );
  }

  Future<void> submitBid({
    required String campaignId,
  }) async {
    if (state.myBidCampaignIds.contains(campaignId)) return;
    final ids = [...state.myBidCampaignIds, campaignId];
    final nextCount = state.activeBidsCount + 1;
    state = state.copyWith(
      myBidCampaignIds: ids,
      activeBidsCount: nextCount,
      creatorProfile: state.creatorProfile?.copyWith(activeBidsCount: nextCount),
    );
  }

  Future<void> withdrawBid(String campaignId) async {
    if (!state.myBidCampaignIds.contains(campaignId)) return;
    final ids = state.myBidCampaignIds.where((id) => id != campaignId).toList();
    final nextCount = (state.activeBidsCount - 1).clamp(0, 99999);
    state = state.copyWith(
      myBidCampaignIds: ids,
      activeBidsCount: nextCount,
      creatorProfile: state.creatorProfile?.copyWith(activeBidsCount: nextCount),
    );
  }

  void toggleInstagramConnection() {
    final profile = state.creatorProfile;
    if (profile == null) return;
    state = state.copyWith(
      creatorProfile: profile.copyWith(
        instagramConnected: !profile.instagramConnected,
      ),
    );
  }

  void toggleYouTubeConnection() {
    final profile = state.creatorProfile;
    if (profile == null) return;
    state = state.copyWith(
      creatorProfile: profile.copyWith(
        youtubeConnected: !profile.youtubeConnected,
      ),
    );
  }

  void topUpWallet(int amountInr) {
    final addedPaise = amountInr * 100;
    final nextPaise = state.walletBalancePaise + addedPaise;
    final nextInr = nextPaise ~/ 100;
    final nextTransactions = [
      WalletTransaction(
        id: 'txn-topup-${DateTime.now().millisecondsSinceEpoch}',
        type: WalletTransactionType.topUp,
        amountPaise: addedPaise,
        createdAt: DateTime.now(),
      ),
      ...state.transactions,
    ];

    state = state.copyWith(
      walletBalancePaise: nextPaise,
      walletBalance: nextInr,
      transactions: nextTransactions,
      creatorProfile: state.creatorProfile?.copyWith(
        walletBalancePaise: nextPaise,
        walletBalance: nextInr,
      ),
    );
  }

  Future<void> _loadCreatorHome() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future<void>.delayed(const Duration(seconds: 1));

    final authState = ref.read(authProvider);
    final metadata = authState.user?.userMetadata ?? const <String, dynamic>{};
    final email = authState.user?.email;
    final rawEmailPrefix =
        email != null && email.contains('@') ? email.split('@').first : email;
    final displayName =
        (metadata['display_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['display_name'] as String).trim()
            : null;
    final emailPrefix = rawEmailPrefix?.trim().isNotEmpty == true
        ? rawEmailPrefix!.trim()
        : null;
    final firstName =
        (metadata['first_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['first_name'] as String).trim()
            : (displayName ?? emailPrefix ?? 'Creator');
    final fullName =
        (metadata['full_name'] as String?)?.trim().isNotEmpty == true
            ? (metadata['full_name'] as String).trim()
            : (displayName ?? firstName);

    const walletBalance = 240;
    const walletBalancePaise = 24000;
    const activeBidsCount = 8;

    state = state.copyWith(
      isLoading: false,
      creatorProfile: CreatorProfile(
        firstName: firstName,
        fullName: fullName,
        tier: 'Rising Creator',
        followers: 82300,
        engagementRate: 4.7,
        avgCollabPaise: 480000,
        bio:
            'I create high-retention lifestyle and fashion content with a strong save/share audience pattern.',
        niches: const ['Fashion', 'Beauty', 'Lifestyle'],
        contentTypes: const ['Reels', 'Stories', 'YouTube Shorts'],
        startingPricePaise: 350000,
        instagramConnected: true,
        youtubeConnected: false,
        walletBalance: walletBalance,
        walletBalancePaise: walletBalancePaise,
        activeBidsCount: activeBidsCount,
      ),
      walletBalance: walletBalance,
      walletBalancePaise: walletBalancePaise,
      activeBidsCount: activeBidsCount,
      requests: [
        CreatorRequest(
          id: 'req-1',
          brandInitial: 'H',
          brandCategory: 'Health',
          budget: 2200,
          collabType: CampaignCollabType.paid,
          receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        CreatorRequest(
          id: 'req-2',
          brandInitial: 'F',
          brandCategory: 'Fashion',
          budget: 3200,
          collabType: CampaignCollabType.hybrid,
          receivedAt: DateTime.now().subtract(const Duration(hours: 9)),
        ),
      ],
      activeCollabs: const [
        ActiveCollab(
          id: 'collab-1',
          brandCategory: 'Beauty',
          amount: 4500,
          currentStep: 2,
        ),
        ActiveCollab(
          id: 'collab-2',
          brandCategory: 'Tech',
          amount: 5800,
          currentStep: 3,
        ),
      ],
      myBidCampaignIds: const ['glow-drop-02'],
      pastCollabs: _mockPastCollabs,
      transactions: _mockTransactions,
      isPastCollabsLoading: false,
      isWalletLoading: false,
      error: null,
    );
  }
}

final _mockPastCollabs = <CreatorPastCollab>[
  const CreatorPastCollab(
    id: 'past-1',
    brandCategory: 'Beauty',
    collabType: CampaignCollabType.hybrid,
    rating: 5,
    amountPaise: 620000,
  ),
  const CreatorPastCollab(
    id: 'past-2',
    brandCategory: 'Tech',
    collabType: CampaignCollabType.paid,
    rating: 4,
    amountPaise: 510000,
  ),
  const CreatorPastCollab(
    id: 'past-3',
    brandCategory: 'Food',
    collabType: CampaignCollabType.barter,
    rating: 5,
    amountPaise: 280000,
  ),
];

final _mockTransactions = <WalletTransaction>[
  WalletTransaction(
    id: 'txn-1',
    type: WalletTransactionType.topUp,
    amountPaise: 19900,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
  ),
  WalletTransaction(
    id: 'txn-2',
    type: WalletTransactionType.feeDeduction,
    amountPaise: 2500,
    brandCategory: 'Beauty',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 7)),
  ),
  WalletTransaction(
    id: 'txn-3',
    type: WalletTransactionType.topUp,
    amountPaise: 9900,
    createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
  ),
];

const _sentinel = Object();

final creatorProvider = NotifierProvider<CreatorNotifier, CreatorState>(
  CreatorNotifier.new,
);
