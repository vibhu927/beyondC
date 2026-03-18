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
    @Default(0) int startingPricePaise,
    String? instagramHandle,
    String? youtubeHandle,
    @Default(0) int walletBalancePaise,
  }) = _CreatorProfile;

  factory CreatorProfile.fromJson(Map<String, dynamic> json) =>
      _$CreatorProfileFromJson(json);

  int get followers => followersCount;
  int get walletBalance => walletBalancePaise ~/ 100;
  bool get instagramConnected => (instagramHandle ?? '').trim().isNotEmpty;
  bool get youtubeConnected => (youtubeHandle ?? '').trim().isNotEmpty;
}

@freezed
class Campaign with _$Campaign {
  const factory Campaign({
    required String id,
    @Default('Campaign') String title,
    @Default('General') String brandCategory,
    @Default('B') String brandInitial,
    String? brandSize,
    @Default(0) int minBudget,
    @Default(0) int maxBudget,
    @Default(CampaignCollabType.paid) CampaignCollabType collabType,
    @Default(<String>[]) List<String> deliverables,
    @Default(0) int bidCount,
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
