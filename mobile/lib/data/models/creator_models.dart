import 'package:freezed_annotation/freezed_annotation.dart';

part 'creator_models.freezed.dart';
part 'creator_models.g.dart';

enum CampaignCollabType {
  @JsonValue('paid')
  paid,
  @JsonValue('barter')
  barter,
  @JsonValue('hybrid')
  hybrid,
}

enum CampaignStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('draft')
  draft,
  @JsonValue('in_progress')
  inProgress,
}

@freezed
class CreatorProfile with _$CreatorProfile {
  const CreatorProfile._();

  const factory CreatorProfile({
    required String id,
    @Default('Creator') String firstName,
    @Default('Creator') String fullName,
    String? displayName,
    @Default('Rising Creator') String tier,
    @Default(0) int followersCount,
    @Default(0) double engagementRate,
    @Default(0) int avgCollabPaise,
    @Default('') String bio,
    @Default(<String>[]) List<String> niches,
    @Default(<String>[]) List<String> contentTypes,
    String? state,
    String? city,
    @Default(<String>[]) List<String> portfolioLinks,
    @Default(0) int startingPricePaise,
    String? instagramUsername,
    @Default(false) bool instagramVerified,
    int? followingCount,
    int? postsCount,
    int? highestVideoViews,
    int? avgVideoViews,
    int? avgLikes,
    int? avgComments,
    DateTime? statsFetchedAt,
    @Default(false) bool isDiscoverable,
    String? youtubeHandle,
    @Default(0) int walletBalancePaise,
  }) = _CreatorProfile;

  factory CreatorProfile.fromJson(Map<String, dynamic> json) =>
      _$CreatorProfileFromJson(json);

  int get followers => followersCount;
  int get walletBalance => walletBalancePaise ~/ 100;
  bool get instagramConnected => instagramVerified;
  bool get youtubeConnected => (youtubeHandle ?? '').trim().isNotEmpty;
}

@freezed
class Campaign with _$Campaign {
  const factory Campaign({
    required String id,
    @Default('Campaign') String title,
    @Default('') String description,
    @Default('General') String brandCategory,
    @Default('B') String brandInitial,
    String? brandSize,
    @Default(<String>[]) List<String> niche,
    @Default('') String requirements,
    @Default(0) int minBudget,
    @Default(0) int maxBudget,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    @Default(<String>[]) List<String> deliverables,
    @Default(0) int bidCount,
    String? targetState,
    String? targetCity,
    @Default(1) int slotsTotal,
    @Default(0) int slotsFilled,
    required DateTime deadline,
    @Default(CampaignStatus.active) CampaignStatus status,
    DateTime? createdAt,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);
}

@freezed
class Bid with _$Bid {
  const factory Bid({
    required String id,
    required String campaignId,
    String? creatorId,
    @Default('pending') String status,
    String? message,
    DateTime? createdAt,
    Campaign? campaign,
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
}

@freezed
class CollabRequest with _$CollabRequest {
  const CollabRequest._();

  const factory CollabRequest({
    required String id,
    required String brandId,
    @Default('Brand') String brandName,
    @Default('General') String brandCategory,
    @Default('B') String brandInitial,
    @Default(0) int budgetPaise,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    @Default(<String>[]) List<String> deliverables,
    @Default('pending') String status,
    DateTime? createdAt,
    String? campaignId,
  }) = _CollabRequest;

  factory CollabRequest.fromJson(Map<String, dynamic> json) =>
      _$CollabRequestFromJson(json);

  int get budget => budgetPaise;
  DateTime get receivedAt => createdAt ?? DateTime.now();
}

@freezed
class Collab with _$Collab {
  const Collab._();

  const factory Collab({
    required String id,
    required String brandId,
    required String creatorId,
    @Default('General') String brandCategory,
    @Default(0) int agreedAmountPaise,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    @Default('in_progress') String status,
    String? milestoneStatus,
    DateTime? createdAt,
    DateTime? completedAt,
    int? rating,
    @Default('started') String collabStatus,
    DateTime? statusUpdatedAt,
    String? statusUpdateMessage,
    Map<String, dynamic>? contractTerms,
    @Default(false) bool creatorContractAccepted,
    @Default(false) bool brandContractAccepted,
    DateTime? creatorContractAcceptedAt,
    DateTime? brandContractAcceptedAt,
    @Default('full_upfront') String paymentStructure,
  }) = _Collab;

  factory Collab.fromJson(Map<String, dynamic> json) => _$CollabFromJson(json);

  int get amount => agreedAmountPaise;

  int get currentStep {
    switch (milestoneStatus) {
      case 'brief_reviewed':
        return 1;
      case 'draft_submitted':
        return 2;
      case 'content_posted':
        return 4;
      default:
        return 1;
    }
  }
}

@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    @Default('topup') String type,
    @Default(0) int amount,
    @Default('') String reason,
    String? referenceId,
    @Default(0) int balanceAfter,
    DateTime? createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}

@freezed
class WalletData with _$WalletData {
  const factory WalletData({
    @Default(0) int balance,
    @Default(<WalletTransaction>[]) List<WalletTransaction> transactions,
  }) = _WalletData;

  factory WalletData.fromJson(Map<String, dynamic> json) =>
      _$WalletDataFromJson(json);
}

@freezed
class EventInvite with _$EventInvite {
  const factory EventInvite({
    required String id,
    required String eventId,
    @Default('pending') String status,
    String? qrCodeData,
    DateTime? createdAt,
    @Default('Event') String eventTitle,
    DateTime? eventDate,
    String? location,
    String? brandName,
    String? brandLogoUrl,
  }) = _EventInvite;

  factory EventInvite.fromJson(Map<String, dynamic> json) =>
      _$EventInviteFromJson(json);
}

@freezed
class EventTicket with _$EventTicket {
  const factory EventTicket({
    required String id,
    String? ticketCode,
    String? qrCodeData,
    @Default('accepted') String status,
    DateTime? createdAt,
    required String eventId,
    @Default('Event') String eventTitle,
    String? eventDescription,
    DateTime? eventDate,
    String? location,
    String? imageUrl,
    String? brandName,
    String? brandLogoUrl,
  }) = _EventTicket;

  factory EventTicket.fromJson(Map<String, dynamic> json) =>
      _$EventTicketFromJson(json);
}

@freezed
class RazorpayOrder with _$RazorpayOrder {
  const factory RazorpayOrder({
    required String orderId,
    required int amountPaise,
    @Default('INR') String currency,
    String? keyId,
  }) = _RazorpayOrder;

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) =>
      _$RazorpayOrderFromJson(json);
}

class CreatorEarnings {
  const CreatorEarnings({
    required this.totalEarnedPaise,
    required this.collabsCompleted,
    required this.avgRating,
    required this.totalRatings,
    required this.recentCollabs,
  });

  final int totalEarnedPaise;
  final int collabsCompleted;
  final double avgRating;
  final int totalRatings;
  final List<RecentCollab> recentCollabs;

  factory CreatorEarnings.fromJson(Map<String, dynamic> json) {
    return CreatorEarnings(
      totalEarnedPaise: json['total_earned_paise'] ?? 0,
      collabsCompleted: json['collabs_completed'] ?? 0,
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      recentCollabs: (json['recent_collabs'] as List?)
              ?.map((e) => RecentCollab.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RecentCollab {
  const RecentCollab({
    required this.id,
    required this.brandName,
    required this.campaignTitle,
    required this.amountPaise,
    this.rating,
    this.completedAt,
  });

  final String id;
  final String brandName;
  final String campaignTitle;
  final int amountPaise;
  final int? rating;
  final DateTime? completedAt;

  factory RecentCollab.fromJson(Map<String, dynamic> json) {
    return RecentCollab(
      id: (json['id'] ?? '').toString(),
      brandName: (json['brand_name'] ?? 'Brand').toString(),
      campaignTitle: (json['campaign_title'] ?? 'Campaign').toString(),
      amountPaise: json['amount_paise'] ?? 0,
      rating: json['rating'],
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
    );
  }
}
