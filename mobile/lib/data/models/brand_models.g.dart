// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrandProfileImpl _$$BrandProfileImplFromJson(Map<String, dynamic> json) =>
    _$BrandProfileImpl(
      id: json['id'] as String,
      brandName: json['brandName'] as String? ?? 'Brand',
      brandCategory: json['brandCategory'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      website: json['website'] as String? ?? '',
      contactEmail: json['contactEmail'] as String?,
      size: json['size'] as String?,
      logoUrl: json['logoUrl'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      onboarded: json['onboarded'] as bool? ?? false,
      creditsBalance: (json['creditsBalance'] as num?)?.toInt() ?? 0,
      verified: json['verified'] as bool? ?? false,
      totalCollabs: (json['totalCollabs'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BrandProfileImplToJson(_$BrandProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brandName': instance.brandName,
      'brandCategory': instance.brandCategory,
      'description': instance.description,
      'website': instance.website,
      'contactEmail': instance.contactEmail,
      'size': instance.size,
      'logoUrl': instance.logoUrl,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'onboarded': instance.onboarded,
      'creditsBalance': instance.creditsBalance,
      'verified': instance.verified,
      'totalCollabs': instance.totalCollabs,
      'avgRating': instance.avgRating,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$CreatorDiscoveryImpl _$$CreatorDiscoveryImplFromJson(
        Map<String, dynamic> json) =>
    _$CreatorDiscoveryImpl(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? 'Creator',
      avatarUrl: json['avatarUrl'] as String?,
      niches: (json['niches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      contentTypes: (json['contentTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      tier: json['tier'] as String? ?? 'micro',
      startingPrice: (json['startingPrice'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0,
      totalCollabs: (json['totalCollabs'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0,
      bio: json['bio'] as String? ?? '',
      portfolioLinks: (json['portfolioLinks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      followerRange: json['followerRange'] as String? ?? '1K-5K',
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CreatorDiscoveryImplToJson(
        _$CreatorDiscoveryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'avatarUrl': instance.avatarUrl,
      'niches': instance.niches,
      'contentTypes': instance.contentTypes,
      'tier': instance.tier,
      'startingPrice': instance.startingPrice,
      'avgRating': instance.avgRating,
      'totalCollabs': instance.totalCollabs,
      'engagementRate': instance.engagementRate,
      'bio': instance.bio,
      'portfolioLinks': instance.portfolioLinks,
      'followerRange': instance.followerRange,
      'followersCount': instance.followersCount,
    };

_$CollabRequestImpl _$$CollabRequestImplFromJson(Map<String, dynamic> json) =>
    _$CollabRequestImpl(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      creatorId: json['creatorId'] as String,
      creatorFirstName: json['creatorFirstName'] as String?,
      creatorFullName: json['creatorFullName'] as String?,
      creatorInstagramHandle: json['creatorInstagramHandle'] as String?,
      creatorTier: json['creatorTier'] as String?,
      collabId: json['collabId'] as String?,
      message: json['message'] as String?,
      budget: (json['budget'] as num?)?.toInt(),
      collabType: $enumDecodeNullable(
              _$CampaignCollabTypeEnumMap, json['collabType']) ??
          CampaignCollabType.paid,
      deliverables: (json['deliverables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      status: json['status'] as String? ?? 'pending',
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CollabRequestImplToJson(_$CollabRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brandId': instance.brandId,
      'creatorId': instance.creatorId,
      'creatorFirstName': instance.creatorFirstName,
      'creatorFullName': instance.creatorFullName,
      'creatorInstagramHandle': instance.creatorInstagramHandle,
      'creatorTier': instance.creatorTier,
      'collabId': instance.collabId,
      'message': instance.message,
      'budget': instance.budget,
      'collabType': _$CampaignCollabTypeEnumMap[instance.collabType]!,
      'deliverables': instance.deliverables,
      'status': instance.status,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$CampaignCollabTypeEnumMap = {
  CampaignCollabType.paid: 'paid',
  CampaignCollabType.barter: 'barter',
  CampaignCollabType.hybrid: 'hybrid',
};

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Campaign',
      description: json['description'] as String? ?? '',
      niche:
          (json['niche'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      collabType: $enumDecodeNullable(
              _$CampaignCollabTypeEnumMap, json['collabType']) ??
          CampaignCollabType.paid,
      budget: (json['budget'] as num?)?.toInt(),
      budgetMin: (json['budgetMin'] as num?)?.toInt(),
      budgetMax: (json['budgetMax'] as num?)?.toInt(),
      deliverables: (json['deliverables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      requirements: json['requirements'] as String? ?? '',
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      status: $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']) ??
          CampaignStatus.active,
      slots: (json['slots'] as num?)?.toInt() ?? 1,
      slotsFilled: (json['slotsFilled'] as num?)?.toInt() ?? 0,
      bidCount: (json['bidCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'niche': instance.niche,
      'collabType': _$CampaignCollabTypeEnumMap[instance.collabType]!,
      'budget': instance.budget,
      'budgetMin': instance.budgetMin,
      'budgetMax': instance.budgetMax,
      'deliverables': instance.deliverables,
      'requirements': instance.requirements,
      'deadline': instance.deadline?.toIso8601String(),
      'status': _$CampaignStatusEnumMap[instance.status]!,
      'slots': instance.slots,
      'slotsFilled': instance.slotsFilled,
      'bidCount': instance.bidCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$CampaignStatusEnumMap = {
  CampaignStatus.active: 'active',
  CampaignStatus.paused: 'paused',
  CampaignStatus.completed: 'completed',
};

_$BidImpl _$$BidImplFromJson(Map<String, dynamic> json) => _$BidImpl(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String,
      creatorId: json['creatorId'] as String,
      bidAmount: (json['bidAmount'] as num?)?.toInt() ?? 0,
      deliverables: json['deliverables'] as String? ?? '',
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'pending',
      includeBarter: json['includeBarter'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      creatorFirstName: json['creatorFirstName'] as String? ?? 'Creator',
      creatorFullName: json['creatorFullName'] as String? ?? 'Creator',
      creatorHandle: json['creatorHandle'] as String? ?? '',
      tier: json['tier'] as String? ?? 'micro',
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0,
      niches: (json['niches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      collabType: $enumDecodeNullable(
              _$CampaignCollabTypeEnumMap, json['collabType']) ??
          CampaignCollabType.paid,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isAccepted: json['isAccepted'] as bool? ?? false,
    );

Map<String, dynamic> _$$BidImplToJson(_$BidImpl instance) => <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'creatorId': instance.creatorId,
      'bidAmount': instance.bidAmount,
      'deliverables': instance.deliverables,
      'message': instance.message,
      'status': instance.status,
      'includeBarter': instance.includeBarter,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'creatorFirstName': instance.creatorFirstName,
      'creatorFullName': instance.creatorFullName,
      'creatorHandle': instance.creatorHandle,
      'tier': instance.tier,
      'followersCount': instance.followersCount,
      'engagementRate': instance.engagementRate,
      'niches': instance.niches,
      'collabType': _$CampaignCollabTypeEnumMap[instance.collabType]!,
      'isUnlocked': instance.isUnlocked,
      'isAccepted': instance.isAccepted,
    };

_$CreditTransactionImpl _$$CreditTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$CreditTransactionImpl(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'deduct',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CreditTransactionImplToJson(
        _$CreditTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'reason': instance.reason,
      'referenceId': instance.referenceId,
      'balanceAfter': instance.balanceAfter,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$CreditsDataImpl _$$CreditsDataImplFromJson(Map<String, dynamic> json) =>
    _$CreditsDataImpl(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map(
                  (e) => CreditTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CreditTransaction>[],
    );

Map<String, dynamic> _$$CreditsDataImplToJson(_$CreditsDataImpl instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'transactions': instance.transactions,
    };

_$BrandEventImpl _$$BrandEventImplFromJson(Map<String, dynamic> json) =>
    _$BrandEventImpl(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Event',
      description: json['description'] as String? ?? '',
      eventType: json['eventType'] as String? ?? 'other',
      eventDate: DateTime.parse(json['eventDate'] as String),
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      venueName: json['venueName'] as String?,
      venueAddress: json['venueAddress'] as String?,
      city: json['city'] as String?,
      isVirtual: json['isVirtual'] as bool? ?? false,
      virtualLink: json['virtualLink'] as String?,
      totalSlots: (json['totalSlots'] as num?)?.toInt() ?? 10,
      slotsFilled: (json['slotsFilled'] as num?)?.toInt() ?? 0,
      whatCreatorsGet: json['whatCreatorsGet'] as String? ?? '',
      targetNiche: (json['targetNiche'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      targetTier: (json['targetTier'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      status: $enumDecodeNullable(_$BrandEventStatusEnumMap, json['status']) ??
          BrandEventStatus.upcoming,
      invitesSent: (json['invitesSent'] as num?)?.toInt() ?? 0,
      invitesAccepted: (json['invitesAccepted'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BrandEventImplToJson(_$BrandEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'eventType': instance.eventType,
      'eventDate': instance.eventDate.toIso8601String(),
      'location': instance.location,
      'imageUrl': instance.imageUrl,
      'venueName': instance.venueName,
      'venueAddress': instance.venueAddress,
      'city': instance.city,
      'isVirtual': instance.isVirtual,
      'virtualLink': instance.virtualLink,
      'totalSlots': instance.totalSlots,
      'slotsFilled': instance.slotsFilled,
      'whatCreatorsGet': instance.whatCreatorsGet,
      'targetNiche': instance.targetNiche,
      'targetTier': instance.targetTier,
      'status': _$BrandEventStatusEnumMap[instance.status]!,
      'invitesSent': instance.invitesSent,
      'invitesAccepted': instance.invitesAccepted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$BrandEventStatusEnumMap = {
  BrandEventStatus.upcoming: 'upcoming',
  BrandEventStatus.ongoing: 'ongoing',
  BrandEventStatus.completed: 'completed',
  BrandEventStatus.cancelled: 'cancelled',
};

_$EventInviteImpl _$$EventInviteImplFromJson(Map<String, dynamic> json) =>
    _$EventInviteImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      creatorId: json['creatorId'] as String,
      status: $enumDecodeNullable(_$EventInviteStatusEnumMap, json['status']) ??
          EventInviteStatus.pending,
      ticketCode: json['ticketCode'] as String?,
      ticketGeneratedAt: json['ticketGeneratedAt'] == null
          ? null
          : DateTime.parse(json['ticketGeneratedAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      creatorFirstName: json['creatorFirstName'] as String? ?? 'Creator',
      tier: json['tier'] as String? ?? 'micro',
      creatorNiches: (json['creatorNiches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      creatorFollowersCount:
          (json['creatorFollowersCount'] as num?)?.toInt() ?? 0,
      creatorAvgRating: (json['creatorAvgRating'] as num?)?.toDouble() ?? 0,
      creatorBio: json['creatorBio'] as String? ?? '',
    );

Map<String, dynamic> _$$EventInviteImplToJson(_$EventInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'creatorId': instance.creatorId,
      'status': _$EventInviteStatusEnumMap[instance.status]!,
      'ticketCode': instance.ticketCode,
      'ticketGeneratedAt': instance.ticketGeneratedAt?.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'creatorFirstName': instance.creatorFirstName,
      'tier': instance.tier,
      'creatorNiches': instance.creatorNiches,
      'creatorFollowersCount': instance.creatorFollowersCount,
      'creatorAvgRating': instance.creatorAvgRating,
      'creatorBio': instance.creatorBio,
    };

const _$EventInviteStatusEnumMap = {
  EventInviteStatus.pending: 'pending',
  EventInviteStatus.accepted: 'accepted',
  EventInviteStatus.declined: 'declined',
};

_$RazorpayOrderImpl _$$RazorpayOrderImplFromJson(Map<String, dynamic> json) =>
    _$RazorpayOrderImpl(
      orderId: json['orderId'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String? ?? 'INR',
      credits: (json['credits'] as num?)?.toInt(),
      keyId: json['keyId'] as String?,
    );

Map<String, dynamic> _$$RazorpayOrderImplToJson(_$RazorpayOrderImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'credits': instance.credits,
      'keyId': instance.keyId,
    };
