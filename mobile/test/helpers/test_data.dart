import 'package:beyondc/data/models/creator_models.dart' as c;
import 'package:beyondc/data/models/brand_models.dart' as b;

c.CreatorProfile createMockCreatorProfile({
  String id = 'creator-test-1',
  String firstName = 'Test Creator',
  int followers = 15000,
  int walletBalance = 100000,
}) {
  return c.CreatorProfile(
    id: id,
    firstName: firstName,
    fullName: firstName,
    followersCount: followers,
    walletBalancePaise: walletBalance,
    engagementRate: 4.5,
    bio: 'Test bio',
    niches: const ['fashion', 'lifestyle'],
    contentTypes: const ['instagram'],
    state: 'Maharashtra',
    city: 'Mumbai',
    instagramVerified: true,
    isDiscoverable: true,
  );
}

b.CreatorDiscovery createMockCreator({
  String id = 'creator-disc-1',
  String firstName = 'Discoverable Creator',
}) {
  return b.CreatorDiscovery(
    id: id,
    firstName: firstName,
    niches: const ['fashion'],
    tier: 'micro',
    startingPrice: 5000,
    avgRating: 4.5,
    totalCollabs: 10,
    followerRange: '10K-50K',
    followersCount: 25000,
    instagramVerified: true,
  );
}

b.BrandProfile createMockBrandProfile({
  String id = 'brand-test-1',
  String name = 'Test Brand',
}) {
  return b.BrandProfile(
    id: id,
    brandName: name,
    brandCategory: 'Fashion',
    description: 'A test brand',
    creditsBalance: 10,
    totalCollabs: 5,
    avgRating: 4.2,
    verified: true,
  );
}

c.Collab createMockCollab({
  String id = 'collab-test-1',
  String status = 'in_progress',
}) {
  return c.Collab(
    id: id,
    brandId: 'brand-test-1',
    creatorId: 'creator-test-1',
    brandCategory: 'Fashion',
    agreedAmountPaise: 25000,
    collabType: c.CampaignCollabType.paid,
    status: status,
    createdAt: DateTime.now(),
  );
}

c.WalletData createMockWalletData({int balance = 50000}) {
  return c.WalletData(
    balance: balance,
    transactions: [
      c.WalletTransaction(
        id: 'txn-1',
        type: 'topup',
        amount: balance,
        reason: 'wallet_topup',
        balanceAfter: balance,
        createdAt: DateTime.now(),
      ),
    ],
  );
}
