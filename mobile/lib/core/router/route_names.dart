class RouteNames {
  RouteNames._();

  // Onboarding + Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelect = '/role-select';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Creator Portal
  static const String creatorHome = '/creator/home';
  static const String creatorCampaigns = '/creator/campaigns';
  static const String campaignDetail = '/creator/campaigns/:id';
  static const String myBids = '/creator/bids';
  static const String creatorRequests = '/creator/requests';
  static const String creatorCollabs = '/creator/collabs';
  static const String creatorEvents = '/creator/events';
  static const String creatorProfile = '/creator/profile';
  static const String creatorWallet = '/creator/wallet';
  static const String myTickets = '/creator/tickets';
  static const String ticketDetail = '/creator/tickets/:id';

  // Brand Portal
  static const String brandHome = '/brand/home';
  static const String brandCampaigns = '/brand/campaigns';
  static const String createCampaign = '/brand/campaigns/create';
  static const String campaignBids = '/brand/campaigns/:id/bids';
  static const String brandRequests = '/brand/requests';
  static const String brandCollabs = '/brand/collabs';
  static const String brandDiscover = '/brand/discover';
  static const String brandProfile = '/brand/profile';
  static const String brandCredits = '/brand/credits';
  static const String brandEvents = '/brand/events';
  static const String createEvent = '/brand/events/create';
  static const String eventInvites = '/brand/events/:id/invites';
  static const String savedCreators = '/brand/saved-creators';
  static const String brandAnalytics = '/brand/analytics';

  // Agency Portal
  static const String agencyHome = '/agency/home';
  static const String agencyDiscover = '/agency/discover';
  static const String agencyProfile = '/agency/profile';
  static const String agencyCredits = '/agency/credits';
  static const String agencyPartnered = '/agency/partnered';
  static const String agencyPitches = '/agency/pitches';
  static const String agencyBids = '/agency/bids';
  static const String agencySettings = '/agency/settings';
  static const String agencyDiscoverCreators = '/agency/discover/creators';
  static const String agencyDiscoverBrands = '/agency/discover/brands';
  static const String agencyPitchCreator = '/agency/pitch/creator';
  static const String agencyPitchBrand = '/agency/pitch/brand';

  // Shared
  static const String notifications = '/notifications';
  static const String collabDetail = '/collabs/:id';
  static const String collabMilestones = '/collabs/:id/milestones';
  static const String collabRating = '/collabs/:id/rate';
  static const String collabContract = '/collabs/:id/contract';
  static const String collabContractCreate = '/collabs/:id/contract/create';
  static const String collabContentSubmit = '/collabs/:id/content/submit';
  static const String collabContentReview = '/collabs/:id/content/review';
  static const String collabPaymentSetup = '/collabs/:id/payment/setup';
  static const String collabPaymentView = '/collabs/:id/payment/view';
  static const String partnerProfile = '/partner-profile';
  static const String settings = '/settings';
}
