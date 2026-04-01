import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_models.freezed.dart';
part 'brand_models.g.dart';

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
}

enum EventInviteStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
}

enum BrandEventStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class BrandProfile with _$BrandProfile {
  const BrandProfile._();

  const factory BrandProfile({
    required String id,
    @Default('Brand') String brandName,
    @Default('General') String brandCategory,
    @Default('') String description,
    @Default('') String website,
    String? contactEmail,
    String? size,
    String? logoUrl,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool onboarded,
    @Default(0) int creditsBalance,
    @Default(false) bool verified,
    @Default(0) int totalCollabs,
    @Default(0) double avgRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BrandProfile;

  factory BrandProfile.fromJson(Map<String, dynamic> json) =>
      _$BrandProfileFromJson(json);

  String get category => brandCategory;

  String get logoInitial {
    final trimmed = brandName.trim();
    if (trimmed.isEmpty) return 'B';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

@freezed
class CreatorDiscovery with _$CreatorDiscovery {
  const CreatorDiscovery._();

  const factory CreatorDiscovery({
    required String id,
    @Default('Creator') String firstName,
    String? avatarUrl,
    @Default(<String>[]) List<String> niches,
    @Default(<String>[]) List<String> contentTypes,
    @Default('micro') String tier,
    @Default(0) int startingPrice,
    @Default(0) double avgRating,
    @Default(0) int totalCollabs,
    @Default(0) double engagementRate,
    @Default('') String bio,
    @Default(<String>[]) List<String> portfolioLinks,
    @Default('1K-5K') String followerRange,
    @Default(0) int followersCount,
    @Default(false) bool instagramVerified,
  }) = _CreatorDiscovery;

  factory CreatorDiscovery.fromJson(Map<String, dynamic> json) =>
      _$CreatorDiscoveryFromJson(json);

  String get initials {
    final trimmed = firstName.trim();
    if (trimmed.isEmpty) return 'C';
    return trimmed.substring(0, 1).toUpperCase();
  }

  int? get avgCollabPrice => startingPrice;

  int? get pastCollabs => totalCollabs;
}

typedef CreatorPreview = CreatorDiscovery;

@freezed
class CollabRequest with _$CollabRequest {
  const factory CollabRequest({
    required String id,
    required String brandId,
    required String creatorId,
    String? creatorFirstName,
    String? creatorFullName,
    String? creatorInstagramHandle,
    String? creatorTier,
    String? collabId,
    String? message,
    int? budget,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    @Default(<String>[]) List<String> deliverables,
    @Default('pending') String status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CollabRequest;

  factory CollabRequest.fromJson(Map<String, dynamic> json) =>
      _$CollabRequestFromJson(json);
}

@freezed
class Campaign with _$Campaign {
  const Campaign._();

  const factory Campaign({
    required String id,
    @Default('Campaign') String title,
    @Default('') String description,
    @Default(<String>[]) List<String> niche,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    int? budget,
    int? budgetMin,
    int? budgetMax,
    @Default(<String>[]) List<String> deliverables,
    @Default('') String requirements,
    DateTime? deadline,
    @Default(CampaignStatus.active) CampaignStatus status,
    @Default(1) int slots,
    @Default(0) int slotsFilled,
    @Default(0) int bidCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);

  String get brandCategory => niche.isEmpty ? 'General' : niche.first;

  String get brandInitial {
    final category = brandCategory.trim();
    if (category.isEmpty) return 'B';
    return category.substring(0, 1).toUpperCase();
  }

  int get minBudget => budgetMin ?? budget ?? 0;

  int get maxBudget => budgetMax ?? budget ?? 0;

  int get slotsTotal => slots;
}

@freezed
class Bid with _$Bid {
  const Bid._();

  const factory Bid({
    required String id,
    required String campaignId,
    required String creatorId,
    @Default(0) int bidAmount,
    @Default('') String deliverables,
    String? message,
    @Default('pending') String status,
    @Default(false) bool includeBarter,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default('Creator') String creatorFirstName,
    @Default('Creator') String creatorFullName,
    @Default('') String creatorHandle,
    @Default('micro') String tier,
    @Default(0) int followersCount,
    @Default(0) double engagementRate,
    @Default(<String>[]) List<String> niches,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    @Default(false) bool isUnlocked,
    @Default(false) bool isAccepted,
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

  String get creatorInitials {
    final trimmed = creatorFirstName.trim();
    if (trimmed.isNotEmpty) return trimmed.substring(0, 1).toUpperCase();
    if (creatorId.isEmpty) return 'C';
    return creatorId.substring(0, 1).toUpperCase();
  }

  String get followerRange {
    if (followersCount >= 500000) return '500K+';
    if (followersCount >= 100000) return '100K-500K';
    if (followersCount >= 50000) return '50K-100K';
    if (followersCount >= 10000) return '10K-50K';
    if (followersCount >= 5000) return '5K-10K';
    return '1K-5K';
  }

  int get amount => bidAmount;

  String? get pitch => message;
}

typedef CampaignBid = Bid;

@freezed
class CreditTransaction with _$CreditTransaction {
  const CreditTransaction._();

  const factory CreditTransaction({
    required String id,
    @Default('deduct') String type,
    @Default(0) int amount,
    @Default('') String reason,
    String? referenceId,
    @Default(0) int balanceAfter,
    DateTime? createdAt,
  }) = _CreditTransaction;

  factory CreditTransaction.fromJson(Map<String, dynamic> json) =>
      _$CreditTransactionFromJson(json);

  int get creditDelta => type == 'topup' ? amount : -amount;

  String get description {
    if (reason.trim().isNotEmpty) {
      return reason.replaceAll('_', ' ');
    }
    return type == 'topup' ? 'Credits added' : 'Credits used';
  }
}

@freezed
class CreditsData with _$CreditsData {
  const factory CreditsData({
    @Default(0) int balance,
    @Default(<CreditTransaction>[]) List<CreditTransaction> transactions,
  }) = _CreditsData;

  factory CreditsData.fromJson(Map<String, dynamic> json) =>
      _$CreditsDataFromJson(json);
}

@freezed
class BrandEvent with _$BrandEvent {
  const BrandEvent._();

  const factory BrandEvent({
    required String id,
    @Default('Event') String title,
    @Default('') String description,
    @Default('other') String eventType,
    required DateTime eventDate,
    String? location,
    String? imageUrl,
    String? venueName,
    String? venueAddress,
    String? city,
    @Default(false) bool isVirtual,
    String? virtualLink,
    @Default(10) int totalSlots,
    @Default(0) int slotsFilled,
    @Default('') String whatCreatorsGet,
    @Default(<String>[]) List<String> targetNiche,
    @Default(<String>[]) List<String> targetTier,
    @Default(BrandEventStatus.upcoming) BrandEventStatus status,
    @Default(0) int invitesSent,
    @Default(0) int invitesAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BrandEvent;

  factory BrandEvent.fromJson(Map<String, dynamic> json) =>
      _$BrandEventFromJson(json);

  String get name => title;

  DateTime get dateTime => eventDate;

  List<String> get targetNiches => targetNiche;

  List<String> get targetTiers => targetTier;

  int get filledSlots => slotsFilled;
}

@freezed
class EventInvite with _$EventInvite {
  const EventInvite._();

  const factory EventInvite({
    required String id,
    required String eventId,
    required String creatorId,
    @Default(EventInviteStatus.pending) EventInviteStatus status,
    String? ticketCode,
    DateTime? ticketGeneratedAt,
    DateTime? acceptedAt,
    DateTime? createdAt,
    @Default('Creator') String creatorFirstName,
    @Default('micro') String tier,
    @Default(<String>[]) List<String> creatorNiches,
    @Default(0) int creatorFollowersCount,
    @Default(0) double creatorAvgRating,
    @Default('') String creatorBio,
  }) = _EventInvite;

  factory EventInvite.fromJson(Map<String, dynamic> json) =>
      _$EventInviteFromJson(json);

  String get creatorInitials {
    final trimmed = creatorFirstName.trim();
    if (trimmed.isEmpty) return 'C';
    return trimmed.substring(0, 1).toUpperCase();
  }

  DateTime get sentAt => createdAt ?? DateTime.now();
}

@freezed
class RazorpayOrder with _$RazorpayOrder {
  const factory RazorpayOrder({
    required String orderId,
    required int amount,
    @Default('INR') String currency,
    int? credits,
    String? keyId,
  }) = _RazorpayOrder;

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) =>
      _$RazorpayOrderFromJson(json);
}

class ActiveCollabSummary {
  const ActiveCollabSummary({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.campaignId,
    required this.campaignTitle,
    required this.status,
    this.agreedAmount,
    this.startedAt,
  });

  final String id;
  final String creatorId;
  final String creatorName;
  final String? campaignId;
  final String campaignTitle;
  final String status;
  final int? agreedAmount;
  final DateTime? startedAt;

  factory ActiveCollabSummary.fromJson(Map<String, dynamic> json) {
    return ActiveCollabSummary(
      id: (json['id'] ?? '').toString(),
      creatorId: (json['creatorId'] ?? '').toString(),
      creatorName: (json['creatorName'] ?? 'Creator').toString(),
      campaignId: json['campaignId']?.toString(),
      campaignTitle: (json['campaignTitle'] ?? 'Campaign').toString(),
      status: (json['status'] ?? 'active').toString(),
      agreedAmount: json['agreedAmount'] is int
          ? json['agreedAmount'] as int
          : int.tryParse('${json['agreedAmount'] ?? ''}'),
      startedAt: DateTime.tryParse('${json['startedAt'] ?? ''}'),
    );
  }
}
