import 'package:flutter_test/flutter_test.dart';
import 'package:beyondc/data/models/creator_models.dart';

void main() {
  group('CreatorProfile', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'test-id',
        'firstName': 'John',
        'fullName': 'John Doe',
        'tier': 'Nano Creator',
        'followersCount': 5000,
        'engagementRate': 3.5,
        'bio': 'Test bio',
        'niches': ['fashion', 'lifestyle'],
        'state': 'Maharashtra',
        'city': 'Mumbai',
        'portfolioLinks': ['https://example.com'],
        'startingPricePaise': 500000,
        'instagramUsername': '@johndoe',
        'instagramVerified': true,
        'walletBalancePaise': 100000,
      };

      final profile = CreatorProfile.fromJson(json);

      expect(profile.id, 'test-id');
      expect(profile.firstName, 'John');
      expect(profile.followers, 5000);
      expect(profile.followersCount, 5000);
      expect(profile.engagementRate, 3.5);
      expect(profile.walletBalance, 1000); // 100000 paise / 100
      expect(profile.instagramConnected, true);
    });

    test('toJson produces correct map', () {
      const profile = CreatorProfile(
        id: 'test-id',
        firstName: 'Jane',
        fullName: 'Jane Doe',
        followersCount: 10000,
        walletBalancePaise: 50000,
        instagramVerified: true,
      );

      final json = profile.toJson();
      expect(json['id'], 'test-id');
      expect(json['firstName'], 'Jane');
      expect(json['followersCount'], 10000);
      expect(json['walletBalancePaise'], 50000);
    });

    test('default values are applied', () {
      const profile = CreatorProfile(id: 'minimal');
      expect(profile.firstName, 'Creator');
      expect(profile.tier, 'Rising Creator');
      expect(profile.followersCount, 0);
      expect(profile.engagementRate, 0);
      expect(profile.niches, isEmpty);
      expect(profile.portfolioLinks, isEmpty);
      expect(profile.instagramConnected, false);
      expect(profile.youtubeConnected, false);
    });
  });

  group('Campaign (creator)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'campaign-1',
        'title': 'Test Campaign',
        'description': 'A test',
        'brandCategory': 'Fashion',
        'niche': ['fashion'],
        'minBudget': 10000,
        'maxBudget': 50000,
        'collabType': 'paid',
        'deliverables': ['1 post', '1 story'],
        'bidCount': 5,
        'slotsTotal': 3,
        'slotsFilled': 1,
        'deadline': '2026-07-01T00:00:00.000Z',
        'status': 'active',
      };

      final campaign = Campaign.fromJson(json);
      expect(campaign.title, 'Test Campaign');
      expect(campaign.collabType, CampaignCollabType.paid);
      expect(campaign.status, CampaignStatus.active);
      expect(campaign.bidCount, 5);
      expect(campaign.slotsTotal, 3);
      expect(campaign.slotsFilled, 1);
    });
  });

  group('Bid (creator)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'bid-1',
        'campaignId': 'campaign-1',
        'status': 'pending',
        'message': 'Interested!',
      };

      final bid = Bid.fromJson(json);
      expect(bid.id, 'bid-1');
      expect(bid.campaignId, 'campaign-1');
      expect(bid.status, 'pending');
    });
  });

  group('CollabRequest (creator)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'req-1',
        'brandId': 'brand-1',
        'brandName': 'Nike',
        'budgetPaise': 50000,
        'collabType': 'paid',
        'deliverables': ['1 post'],
        'status': 'pending',
      };

      final request = CollabRequest.fromJson(json);
      expect(request.brandName, 'Nike');
      expect(request.budget, 50000);
      expect(request.collabType, CampaignCollabType.paid);
      expect(request.status, 'pending');
    });
  });

  group('Collab (creator)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'collab-1',
        'brandId': 'brand-1',
        'creatorId': 'creator-1',
        'agreedAmountPaise': 25000,
        'collabType': 'paid',
        'status': 'in_progress',
      };

      final collab = Collab.fromJson(json);
      expect(collab.amount, 25000);
      expect(collab.status, 'in_progress');
    });

    test('currentStep maps milestone status correctly', () {
      const collab = Collab(
        id: 'c1',
        brandId: 'b1',
        creatorId: 'cr1',
        milestoneStatus: 'draft_submitted',
      );
      expect(collab.currentStep, 2);
    });

    test('currentStep defaults to 1 for null/active', () {
      const collab = Collab(id: 'c1', brandId: 'b1', creatorId: 'cr1');
      expect(collab.currentStep, 1);
    });
  });

  group('WalletData and WalletTransaction', () {
    test('WalletData fromJson parses correctly', () {
      final json = {
        'balance': 50000,
        'transactions': [
          {
            'id': 'txn-1',
            'type': 'topup',
            'amount': 50000,
            'reason': 'wallet_topup',
            'balanceAfter': 50000,
          }
        ],
      };

      final data = WalletData.fromJson(json);
      expect(data.balance, 50000);
      expect(data.transactions.length, 1);
      expect(data.transactions.first.type, 'topup');
    });
  });

  group('RazorpayOrder (creator)', () {
    test('fromJson parses correctly', () {
      final json = {
        'orderId': 'order_test_123',
        'amountPaise': 100000,
        'currency': 'INR',
        'keyId': 'rzp_test_key',
      };

      final order = RazorpayOrder.fromJson(json);
      expect(order.orderId, 'order_test_123');
      expect(order.amountPaise, 100000);
    });
  });
}
