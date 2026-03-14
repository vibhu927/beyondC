class AppConstants {
  AppConstants._();

  // Credit costs for brands
  static const int creditCostDirectRequest = 1;
  static const int creditCostBidAccepted = 1;
  static const int creditCostEventInviteSent = 2;
  static const int creditCostEventInviteAccepted = 1;

  // Credit pack prices (in INR)
  static const Map<String, Map<String, int>> creditPacks = {
    'starter': {'credits': 5, 'price': 199},
    'growth':  {'credits': 15, 'price': 499},
    'scale':   {'credits': 35, 'price': 999},
  };

  // Collab fees for creators (in paise — ₹1 = 100 paise)
  static const Map<String, Map<String, int>> collabFees = {
    'micro': {'min': 1000, 'max': 3000},
    'mid':   {'min': 5000, 'max': 10000},
    'big':   {'min': 15000, 'max': 30000},
  };

  // Creator tiers
  static const Map<String, Map<String, dynamic>> creatorTiers = {
    'nano':  {'label': 'Nano Creator',    'emoji': '🌱', 'min': 0,      'max': 4999},
    'micro': {'label': 'Micro Creator',   'emoji': '🎨', 'min': 5000,   'max': 49999},
    'mid':   {'label': 'Rising Creator',  'emoji': '🚀', 'min': 50000,  'max': 499999},
    'macro': {'label': 'Top Creator',     'emoji': '⭐', 'min': 500000, 'max': null},
  };

  // Wallet top-up options (in INR)
  static const List<int> walletTopUpOptions = [99, 199, 499, 999, 1999];

  // Pagination
  static const int defaultPageSize = 20;

  // Request expiry
  static const int requestExpiryDays = 7;
}
