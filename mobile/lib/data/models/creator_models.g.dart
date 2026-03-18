// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatorProfileImpl _$$CreatorProfileImplFromJson(Map<String, dynamic> json) =>
    _$CreatorProfileImpl(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? 'Creator',
      fullName: json['fullName'] as String? ?? 'Creator',
      displayName: json['displayName'] as String?,
      tier: json['tier'] as String? ?? 'Rising Creator',
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0,
      avgCollabPaise: (json['avgCollabPaise'] as num?)?.toInt() ?? 0,
      bio: json['bio'] as String? ?? '',
      niches: (json['niches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      contentTypes: (json['contentTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      startingPricePaise: (json['startingPricePaise'] as num?)?.toInt() ?? 0,
      instagramHandle: json['instagramHandle'] as String?,
      youtubeHandle: json['youtubeHandle'] as String?,
      walletBalancePaise: (json['walletBalancePaise'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CreatorProfileImplToJson(
        _$CreatorProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'fullName': instance.fullName,
      'displayName': instance.displayName,
      'tier': instance.tier,
      'followersCount': instance.followersCount,
      'engagementRate': instance.engagementRate,
      'avgCollabPaise': instance.avgCollabPaise,
      'bio': instance.bio,
      'niches': instance.niches,
      'contentTypes': instance.contentTypes,
      'startingPricePaise': instance.startingPricePaise,
      'instagramHandle': instance.instagramHandle,
      'youtubeHandle': instance.youtubeHandle,
      'walletBalancePaise': instance.walletBalancePaise,
    };

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Campaign',
      brandCategory: json['brandCategory'] as String? ?? 'General',
      brandInitial: json['brandInitial'] as String? ?? 'B',
      brandSize: json['brandSize'] as String?,
      minBudget: (json['minBudget'] as num?)?.toInt() ?? 0,
      maxBudget: (json['maxBudget'] as num?)?.toInt() ?? 0,
      collabType: $enumDecodeNullable(
              _$CampaignCollabTypeEnumMap, json['collabType']) ??
          CampaignCollabType.paid,
      deliverables: (json['deliverables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      bidCount: (json['bidCount'] as num?)?.toInt() ?? 0,
      deadline: DateTime.parse(json['deadline'] as String),
      status: $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']) ??
          CampaignStatus.active,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'brandCategory': instance.brandCategory,
      'brandInitial': instance.brandInitial,
      'brandSize': instance.brandSize,
      'minBudget': instance.minBudget,
      'maxBudget': instance.maxBudget,
      'collabType': _$CampaignCollabTypeEnumMap[instance.collabType]!,
      'deliverables': instance.deliverables,
      'bidCount': instance.bidCount,
      'deadline': instance.deadline.toIso8601String(),
      'status': _$CampaignStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$CampaignCollabTypeEnumMap = {
  CampaignCollabType.paid: 'paid',
  CampaignCollabType.barter: 'barter',
  CampaignCollabType.hybrid: 'hybrid',
};

const _$CampaignStatusEnumMap = {
  CampaignStatus.active: 'active',
  CampaignStatus.paused: 'paused',
  CampaignStatus.completed: 'completed',
  CampaignStatus.draft: 'draft',
  CampaignStatus.inProgress: 'in_progress',
};

_$BidImpl _$$BidImplFromJson(Map<String, dynamic> json) => _$BidImpl(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      creatorId: json['creatorId'] as String?,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      campaign: json['campaign'] == null
          ? null
          : Campaign.fromJson(json['campaign'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BidImplToJson(_$BidImpl instance) => <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'creatorId': instance.creatorId,
      'status': instance.status,
      'message': instance.message,
      'createdAt': instance.createdAt?.toIso8601String(),
      'campaign': instance.campaign,
    };

_$CollabRequestImpl _$$CollabRequestImplFromJson(Map<String, dynamic> json) =>
    _$CollabRequestImpl(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      brandName: json['brandName'] as String? ?? 'Brand',
      brandCategory: json['brandCategory'] as String? ?? 'General',
      brandInitial: json['brandInitial'] as String? ?? 'B',
      budgetPaise: (json['budgetPaise'] as num?)?.toInt() ?? 0,
      collabType: $enumDecodeNullable(
              _$CampaignCollabTypeEnumMap, json['collabType']) ??
          CampaignCollabType.paid,
      deliverables: (json['deliverables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CollabRequestImplToJson(_$CollabRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brandId': instance.brandId,
      'brandName': instance.brandName,
      'brandCategory': instance.brandCategory,
      'brandInitial': instance.brandInitial,
      'budgetPaise': instance.budgetPaise,
      'collabType': _$CampaignCollabTypeEnumMap[instance.collabType]!,
      'deliverables': instance.deliverables,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CollabImpl _$$CollabImplFromJson(Map<String, dynamic> json) => _$CollabImpl(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      creatorId: json['creatorId'] as String,
      brandCategory: json['brandCategory'] as String? ?? 'General',
      agreedAmountPaise: (json['agreedAmountPaise'] as num?)?.toInt() ?? 0,
      collabType: $enumDecodeNullable(
              _$CampaignCollabTypeEnumMap, json['collabType']) ??
          CampaignCollabType.paid,
      status: json['status'] as String? ?? 'in_progress',
      milestoneStatus: json['milestoneStatus'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      rating: (json['rating'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CollabImplToJson(_$CollabImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brandId': instance.brandId,
      'creatorId': instance.creatorId,
      'brandCategory': instance.brandCategory,
      'agreedAmountPaise': instance.agreedAmountPaise,
      'collabType': _$CampaignCollabTypeEnumMap[instance.collabType]!,
      'status': instance.status,
      'milestoneStatus': instance.milestoneStatus,
      'createdAt': instance.createdAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'rating': instance.rating,
    };

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionImpl(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'topup',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WalletTransactionImplToJson(
        _$WalletTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'reason': instance.reason,
      'referenceId': instance.referenceId,
      'balanceAfter': instance.balanceAfter,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$WalletDataImpl _$$WalletDataImplFromJson(Map<String, dynamic> json) =>
    _$WalletDataImpl(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map(
                  (e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <WalletTransaction>[],
    );

Map<String, dynamic> _$$WalletDataImplToJson(_$WalletDataImpl instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'transactions': instance.transactions,
    };

_$EventInviteImpl _$$EventInviteImplFromJson(Map<String, dynamic> json) =>
    _$EventInviteImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      status: json['status'] as String? ?? 'pending',
      qrCodeData: json['qrCodeData'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      eventTitle: json['eventTitle'] as String? ?? 'Event',
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.parse(json['eventDate'] as String),
      location: json['location'] as String?,
      brandName: json['brandName'] as String?,
      brandLogoUrl: json['brandLogoUrl'] as String?,
    );

Map<String, dynamic> _$$EventInviteImplToJson(_$EventInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'status': instance.status,
      'qrCodeData': instance.qrCodeData,
      'createdAt': instance.createdAt?.toIso8601String(),
      'eventTitle': instance.eventTitle,
      'eventDate': instance.eventDate?.toIso8601String(),
      'location': instance.location,
      'brandName': instance.brandName,
      'brandLogoUrl': instance.brandLogoUrl,
    };

_$EventTicketImpl _$$EventTicketImplFromJson(Map<String, dynamic> json) =>
    _$EventTicketImpl(
      id: json['id'] as String,
      ticketCode: json['ticketCode'] as String?,
      qrCodeData: json['qrCodeData'] as String?,
      status: json['status'] as String? ?? 'accepted',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String? ?? 'Event',
      eventDescription: json['eventDescription'] as String?,
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.parse(json['eventDate'] as String),
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      brandName: json['brandName'] as String?,
      brandLogoUrl: json['brandLogoUrl'] as String?,
    );

Map<String, dynamic> _$$EventTicketImplToJson(_$EventTicketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticketCode': instance.ticketCode,
      'qrCodeData': instance.qrCodeData,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'eventId': instance.eventId,
      'eventTitle': instance.eventTitle,
      'eventDescription': instance.eventDescription,
      'eventDate': instance.eventDate?.toIso8601String(),
      'location': instance.location,
      'imageUrl': instance.imageUrl,
      'brandName': instance.brandName,
      'brandLogoUrl': instance.brandLogoUrl,
    };

_$RazorpayOrderImpl _$$RazorpayOrderImplFromJson(Map<String, dynamic> json) =>
    _$RazorpayOrderImpl(
      orderId: json['orderId'] as String,
      amountPaise: (json['amountPaise'] as num).toInt(),
      currency: json['currency'] as String? ?? 'INR',
      keyId: json['keyId'] as String?,
    );

Map<String, dynamic> _$$RazorpayOrderImplToJson(_$RazorpayOrderImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'amountPaise': instance.amountPaise,
      'currency': instance.currency,
      'keyId': instance.keyId,
    };
