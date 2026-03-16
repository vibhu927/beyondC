import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CampaignCollabType { paid, barter, hybrid }

enum CampaignStatus { active, paused, completed }

class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.brandCategory,
    required this.brandInitial,
    required this.minBudget,
    required this.maxBudget,
    required this.collabType,
    required this.deliverables,
    required this.bidCount,
    required this.deadline,
    required this.status,
  });

  final String id;
  final String title;
  final String brandCategory;
  final String brandInitial;
  final int minBudget;
  final int maxBudget;
  final CampaignCollabType collabType;
  final List<String> deliverables;
  final int bidCount;
  final DateTime deadline;
  final CampaignStatus status;
}

class CampaignState {
  const CampaignState({
    this.campaigns = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Campaign> campaigns;
  final bool isLoading;
  final String? error;

  CampaignState copyWith({
    List<Campaign>? campaigns,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return CampaignState(
      campaigns: campaigns ?? this.campaigns,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class CampaignNotifier extends Notifier<CampaignState> {
  @override
  CampaignState build() => const CampaignState();

  Future<void> fetchCampaigns() async {
    if (state.isLoading || state.campaigns.isNotEmpty) return;
    await _loadCampaigns();
  }

  Future<void> refreshCampaigns() async {
    await _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future<void>.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    state = state.copyWith(
      isLoading: false,
      campaigns: [
        Campaign(
          id: 'fit-burst-01',
          title: 'Spring Fitness Challenge',
          brandCategory: 'Fitness',
          brandInitial: 'F',
          minBudget: 1500,
          maxBudget: 3000,
          collabType: CampaignCollabType.paid,
          deliverables: const ['1 Reel', '3 Stories', 'Usage rights'],
          bidCount: 12,
          deadline: now.add(const Duration(days: 3)),
          status: CampaignStatus.active,
        ),
        Campaign(
          id: 'glow-drop-02',
          title: 'Glow Serum Launch',
          brandCategory: 'Beauty',
          brandInitial: 'B',
          minBudget: 2500,
          maxBudget: 5000,
          collabType: CampaignCollabType.hybrid,
          deliverables: const ['2 Reels', '1 Carousel', 'Product unboxing'],
          bidCount: 9,
          deadline: now.add(const Duration(days: 5)),
          status: CampaignStatus.active,
        ),
        Campaign(
          id: 'crunch-box-03',
          title: 'Healthy Snack Push',
          brandCategory: 'Food',
          brandInitial: 'S',
          minBudget: 1200,
          maxBudget: 2200,
          collabType: CampaignCollabType.barter,
          deliverables: const ['1 Reel', '2 Story frames'],
          bidCount: 6,
          deadline: now.add(const Duration(days: 2)),
          status: CampaignStatus.active,
        ),
        Campaign(
          id: 'wander-drop-04',
          title: 'Weekend Travel Edit',
          brandCategory: 'Travel',
          brandInitial: 'T',
          minBudget: 4000,
          maxBudget: 6500,
          collabType: CampaignCollabType.paid,
          deliverables: const ['1 Vlog', '1 Reel', '5 photo assets'],
          bidCount: 18,
          deadline: now.add(const Duration(days: 7)),
          status: CampaignStatus.active,
        ),
        Campaign(
          id: 'gear-grid-05',
          title: 'Creator Desk Refresh',
          brandCategory: 'Tech',
          brandInitial: 'G',
          minBudget: 3000,
          maxBudget: 7000,
          collabType: CampaignCollabType.hybrid,
          deliverables: const [
            '1 Review Reel',
            '1 Long caption post',
            '2 stories'
          ],
          bidCount: 21,
          deadline: now.add(const Duration(days: 4)),
          status: CampaignStatus.active,
        ),
      ],
      error: null,
    );
  }
}

const _sentinel = Object();

final campaignProvider = NotifierProvider<CampaignNotifier, CampaignState>(
  CampaignNotifier.new,
);
