import 'package:flutter_test/flutter_test.dart';
import 'package:beyondc/data/models/creator_models.dart';
import 'package:beyondc/providers/creator_provider.dart';

void main() {
  group('CreatorCampaignFilters', () {
    test('default values are applied', () {
      const filters = CreatorCampaignFilters();
      expect(filters.niche, isNull);
      expect(filters.collabType, isNull);
      expect(filters.minBudget, isNull);
      expect(filters.maxBudget, isNull);
      expect(filters.includePanIndia, true);
    });

    test('copyWith updates single field', () {
      const filters = CreatorCampaignFilters();
      final updated = filters.copyWith(niche: 'fashion');
      expect(updated.niche, 'fashion');
      expect(updated.collabType, isNull);
      expect(updated.includePanIndia, true);
    });

    test('copyWith can set collabType', () {
      const filters = CreatorCampaignFilters();
      final updated = filters.copyWith(
        collabType: CampaignCollabType.barter,
      );
      expect(updated.collabType, CampaignCollabType.barter);
    });
  });

  group('CreatorCampaignsState', () {
    test('copyWith updates fields correctly', () {
      const state = CreatorCampaignsState(
        campaigns: [],
        page: 1,
        hasMore: true,
      );

      final updated = state.copyWith(
        page: 2,
        hasMore: false,
        isLoadingMore: true,
      );

      expect(updated.page, 2);
      expect(updated.hasMore, false);
      expect(updated.isLoadingMore, true);
    });
  });

  group('CreatorHomeData', () {
    test('activeBidsCount filters out withdrawn/rejected', () {
      const data = CreatorHomeData(
        profile: CreatorProfile(id: '1'),
        wallet: WalletData(balance: 1000, transactions: []),
        bids: [
          Bid(id: '1', campaignId: 'c1', status: 'pending'),
          Bid(id: '2', campaignId: 'c2', status: 'withdrawn'),
          Bid(id: '3', campaignId: 'c3', status: 'rejected'),
          Bid(id: '4', campaignId: 'c4', status: 'pending'),
        ],
        requests: [],
        activeCollabs: [],
        campaigns: [],
        carouselItems: [],
      );

      expect(data.activeBidsCount, 2);
    });

    test('hasBidForCampaign returns true when bid exists', () {
      const data = CreatorHomeData(
        profile: CreatorProfile(id: '1'),
        wallet: WalletData(balance: 0, transactions: []),
        bids: [
          Bid(id: '1', campaignId: 'campaign-1', status: 'pending'),
        ],
        requests: [],
        activeCollabs: [],
        campaigns: [],
        carouselItems: [],
      );

      expect(data.hasBidForCampaign('campaign-1'), true);
      expect(data.hasBidForCampaign('campaign-2'), false);
    });

    test('hasBidForCampaign ignores withdrawn bids', () {
      const data = CreatorHomeData(
        profile: CreatorProfile(id: '1'),
        wallet: WalletData(balance: 0, transactions: []),
        bids: [
          Bid(id: '1', campaignId: 'campaign-1', status: 'withdrawn'),
        ],
        requests: [],
        activeCollabs: [],
        campaigns: [],
        carouselItems: [],
      );

      expect(data.hasBidForCampaign('campaign-1'), false);
    });
  });
}
