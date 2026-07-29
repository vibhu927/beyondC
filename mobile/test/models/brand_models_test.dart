import 'package:flutter_test/flutter_test.dart';
import 'package:beyondc/data/models/brand_models.dart';

void main() {
  group('BrandProfile', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'brand-1',
        'brandName': 'Nike India',
        'brandCategory': 'Fashion',
        'description': 'Sportswear brand',
        'website': 'https://nike.in',
        'creditsBalance': 10,
        'totalCollabs': 25,
        'avgRating': 4.5,
        'verified': true,
        'portfolioLinks': ['https://nike.in/portfolio'],
      };

      final profile = BrandProfile.fromJson(json);
      expect(profile.brandName, 'Nike India');
      expect(profile.category, 'Fashion');
      expect(profile.creditsBalance, 10);
      expect(profile.totalCollabs, 25);
      expect(profile.avgRating, 4.5);
    });

    test('logoInitial returns first character', () {
      const profile = BrandProfile(id: 'b1', brandName: 'Adidas');
      expect(profile.logoInitial, 'A');
    });

    test('logoInitial defaults to B for empty name', () {
      const profile = BrandProfile(id: 'b1');
      expect(profile.logoInitial, 'B');
    });

    test('toJson produces correct map', () {
      const profile = BrandProfile(
        id: 'b1',
        brandName: 'Test Brand',
        creditsBalance: 5,
      );
      final json = profile.toJson();
      expect(json['id'], 'b1');
      expect(json['brandName'], 'Test Brand');
      expect(json['creditsBalance'], 5);
    });
  });

  group('CreatorDiscovery', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'creator-1',
        'firstName': 'John',
        'niches': ['fashion'],
        'tier': 'micro',
        'startingPrice': 5000,
        'avgRating': 4.2,
        'totalCollabs': 15,
        'followerRange': '10K-50K',
        'followersCount': 25000,
        'instagramVerified': true,
      };

      final creator = CreatorDiscovery.fromJson(json);
      expect(creator.firstName, 'John');
      expect(creator.followerRange, '10K-50K');
      expect(creator.avgCollabPrice, 5000);
      expect(creator.pastCollabs, 15);
    });

    test('initials returns first character', () {
      const creator = CreatorDiscovery(id: 'c1', firstName: 'Alice');
      expect(creator.initials, 'A');
    });
  });

  group('Campaign (brand)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'campaign-1',
        'title': 'Brand Campaign',
        'niche': ['tech', 'gaming'],
        'collabType': 'paid',
        'budgetMin': 10000,
        'budgetMax': 50000,
        'deliverables': ['1 post'],
        'status': 'active',
        'slots': 3,
      };

      final campaign = Campaign.fromJson(json);
      expect(campaign.title, 'Brand Campaign');
      expect(campaign.minBudget, 10000);
      expect(campaign.maxBudget, 50000);
      expect(campaign.slotsTotal, 3);
    });

    test('brandInitial returns first niche character', () {
      const campaign = Campaign(id: 'c1', niche: ['Fashion']);
      expect(campaign.brandInitial, 'F');
    });
  });

  group('Bid (brand)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'bid-1',
        'campaignId': 'campaign-1',
        'creatorId': 'creator-1',
        'bidAmount': 15000,
        'status': 'pending',
        'creatorFirstName': 'John',
        'tier': 'micro',
      };

      final bid = Bid.fromJson(json);
      expect(bid.amount, 15000);
      expect(bid.status, 'pending');
      expect(bid.tier, 'micro');
      expect(bid.creatorInitials, 'J');
    });

    test('followerRange returns correct range', () {
      const bid = Bid(
        id: 'b1',
        campaignId: 'c1',
        creatorId: 'cr1',
        followersCount: 75000,
      );
      expect(bid.followerRange, '50K-100K');
    });
  });

  group('CreditsData', () {
    test('fromJson parses correctly', () {
      final json = {
        'balance': 10,
        'transactions': [
          {
            'id': 'txn-1',
            'type': 'topup',
            'amount': 5,
            'reason': 'credit_purchase',
            'balanceAfter': 5,
          }
        ],
      };

      final data = CreditsData.fromJson(json);
      expect(data.balance, 10);
      expect(data.transactions.first.creditDelta, 5);
    });
  });

  group('ActiveCollabSummary', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'collab-1',
        'creatorId': 'creator-1',
        'creatorName': 'John Doe',
        'campaignId': 'campaign-1',
        'campaignTitle': 'Summer Campaign',
        'status': 'active',
        'agreedAmount': 25000,
      };

      final summary = ActiveCollabSummary.fromJson(json);
      expect(summary.creatorName, 'John Doe');
      expect(summary.campaignTitle, 'Summer Campaign');
      expect(summary.status, 'active');
      expect(summary.agreedAmount, 25000);
    });
  });

  group('BrandEvent', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'event-1',
        'title': 'Launch Party',
        'eventDate': '2026-07-15T18:00:00.000Z',
        'eventType': 'launch',
        'totalSlots': 50,
        'slotsFilled': 20,
        'status': 'upcoming',
      };

      final event = BrandEvent.fromJson(json);
      expect(event.title, 'Launch Party');
      expect(event.status, BrandEventStatus.upcoming);
      expect(event.totalSlots, 50);
    });
  });
}
