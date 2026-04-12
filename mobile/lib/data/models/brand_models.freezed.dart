// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brand_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BrandProfile _$BrandProfileFromJson(Map<String, dynamic> json) {
  return _BrandProfile.fromJson(json);
}

/// @nodoc
mixin _$BrandProfile {
  String get id => throw _privateConstructorUsedError;
  String get brandName => throw _privateConstructorUsedError;
  String get brandCategory => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get website => throw _privateConstructorUsedError;
  String? get contactEmail => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  List<String> get portfolioLinks => throw _privateConstructorUsedError;
  bool get onboarded => throw _privateConstructorUsedError;
  int get creditsBalance => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;
  int get totalCollabs => throw _privateConstructorUsedError;
  double get avgRating => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BrandProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BrandProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrandProfileCopyWith<BrandProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrandProfileCopyWith<$Res> {
  factory $BrandProfileCopyWith(
          BrandProfile value, $Res Function(BrandProfile) then) =
      _$BrandProfileCopyWithImpl<$Res, BrandProfile>;
  @useResult
  $Res call(
      {String id,
      String brandName,
      String brandCategory,
      String description,
      String website,
      String? contactEmail,
      String? state,
      String? city,
      String? size,
      String? logoUrl,
      String? displayName,
      String? avatarUrl,
      List<String> portfolioLinks,
      bool onboarded,
      int creditsBalance,
      bool verified,
      int totalCollabs,
      double avgRating,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$BrandProfileCopyWithImpl<$Res, $Val extends BrandProfile>
    implements $BrandProfileCopyWith<$Res> {
  _$BrandProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BrandProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandName = null,
    Object? brandCategory = null,
    Object? description = null,
    Object? website = null,
    Object? contactEmail = freezed,
    Object? state = freezed,
    Object? city = freezed,
    Object? size = freezed,
    Object? logoUrl = freezed,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? portfolioLinks = null,
    Object? onboarded = null,
    Object? creditsBalance = null,
    Object? verified = null,
    Object? totalCollabs = null,
    Object? avgRating = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      brandCategory: null == brandCategory
          ? _value.brandCategory
          : brandCategory // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      website: null == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      portfolioLinks: null == portfolioLinks
          ? _value.portfolioLinks
          : portfolioLinks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onboarded: null == onboarded
          ? _value.onboarded
          : onboarded // ignore: cast_nullable_to_non_nullable
              as bool,
      creditsBalance: null == creditsBalance
          ? _value.creditsBalance
          : creditsBalance // ignore: cast_nullable_to_non_nullable
              as int,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      totalCollabs: null == totalCollabs
          ? _value.totalCollabs
          : totalCollabs // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BrandProfileImplCopyWith<$Res>
    implements $BrandProfileCopyWith<$Res> {
  factory _$$BrandProfileImplCopyWith(
          _$BrandProfileImpl value, $Res Function(_$BrandProfileImpl) then) =
      __$$BrandProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String brandName,
      String brandCategory,
      String description,
      String website,
      String? contactEmail,
      String? state,
      String? city,
      String? size,
      String? logoUrl,
      String? displayName,
      String? avatarUrl,
      List<String> portfolioLinks,
      bool onboarded,
      int creditsBalance,
      bool verified,
      int totalCollabs,
      double avgRating,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$BrandProfileImplCopyWithImpl<$Res>
    extends _$BrandProfileCopyWithImpl<$Res, _$BrandProfileImpl>
    implements _$$BrandProfileImplCopyWith<$Res> {
  __$$BrandProfileImplCopyWithImpl(
      _$BrandProfileImpl _value, $Res Function(_$BrandProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrandProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandName = null,
    Object? brandCategory = null,
    Object? description = null,
    Object? website = null,
    Object? contactEmail = freezed,
    Object? state = freezed,
    Object? city = freezed,
    Object? size = freezed,
    Object? logoUrl = freezed,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? portfolioLinks = null,
    Object? onboarded = null,
    Object? creditsBalance = null,
    Object? verified = null,
    Object? totalCollabs = null,
    Object? avgRating = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BrandProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      brandCategory: null == brandCategory
          ? _value.brandCategory
          : brandCategory // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      website: null == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: freezed == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      portfolioLinks: null == portfolioLinks
          ? _value._portfolioLinks
          : portfolioLinks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      onboarded: null == onboarded
          ? _value.onboarded
          : onboarded // ignore: cast_nullable_to_non_nullable
              as bool,
      creditsBalance: null == creditsBalance
          ? _value.creditsBalance
          : creditsBalance // ignore: cast_nullable_to_non_nullable
              as int,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      totalCollabs: null == totalCollabs
          ? _value.totalCollabs
          : totalCollabs // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BrandProfileImpl extends _BrandProfile {
  const _$BrandProfileImpl(
      {required this.id,
      this.brandName = 'Brand',
      this.brandCategory = 'General',
      this.description = '',
      this.website = '',
      this.contactEmail,
      this.state,
      this.city,
      this.size,
      this.logoUrl,
      this.displayName,
      this.avatarUrl,
      final List<String> portfolioLinks = const <String>[],
      this.onboarded = false,
      this.creditsBalance = 0,
      this.verified = false,
      this.totalCollabs = 0,
      this.avgRating = 0,
      this.createdAt,
      this.updatedAt})
      : _portfolioLinks = portfolioLinks,
        super._();

  factory _$BrandProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$BrandProfileImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String brandName;
  @override
  @JsonKey()
  final String brandCategory;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String website;
  @override
  final String? contactEmail;
  @override
  final String? state;
  @override
  final String? city;
  @override
  final String? size;
  @override
  final String? logoUrl;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  final List<String> _portfolioLinks;
  @override
  @JsonKey()
  List<String> get portfolioLinks {
    if (_portfolioLinks is EqualUnmodifiableListView) return _portfolioLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_portfolioLinks);
  }

  @override
  @JsonKey()
  final bool onboarded;
  @override
  @JsonKey()
  final int creditsBalance;
  @override
  @JsonKey()
  final bool verified;
  @override
  @JsonKey()
  final int totalCollabs;
  @override
  @JsonKey()
  final double avgRating;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BrandProfile(id: $id, brandName: $brandName, brandCategory: $brandCategory, description: $description, website: $website, contactEmail: $contactEmail, state: $state, city: $city, size: $size, logoUrl: $logoUrl, displayName: $displayName, avatarUrl: $avatarUrl, portfolioLinks: $portfolioLinks, onboarded: $onboarded, creditsBalance: $creditsBalance, verified: $verified, totalCollabs: $totalCollabs, avgRating: $avgRating, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrandProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.brandCategory, brandCategory) ||
                other.brandCategory == brandCategory) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality()
                .equals(other._portfolioLinks, _portfolioLinks) &&
            (identical(other.onboarded, onboarded) ||
                other.onboarded == onboarded) &&
            (identical(other.creditsBalance, creditsBalance) ||
                other.creditsBalance == creditsBalance) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.totalCollabs, totalCollabs) ||
                other.totalCollabs == totalCollabs) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        brandName,
        brandCategory,
        description,
        website,
        contactEmail,
        state,
        city,
        size,
        logoUrl,
        displayName,
        avatarUrl,
        const DeepCollectionEquality().hash(_portfolioLinks),
        onboarded,
        creditsBalance,
        verified,
        totalCollabs,
        avgRating,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of BrandProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrandProfileImplCopyWith<_$BrandProfileImpl> get copyWith =>
      __$$BrandProfileImplCopyWithImpl<_$BrandProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BrandProfileImplToJson(
      this,
    );
  }
}

abstract class _BrandProfile extends BrandProfile {
  const factory _BrandProfile(
      {required final String id,
      final String brandName,
      final String brandCategory,
      final String description,
      final String website,
      final String? contactEmail,
      final String? state,
      final String? city,
      final String? size,
      final String? logoUrl,
      final String? displayName,
      final String? avatarUrl,
      final List<String> portfolioLinks,
      final bool onboarded,
      final int creditsBalance,
      final bool verified,
      final int totalCollabs,
      final double avgRating,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BrandProfileImpl;
  const _BrandProfile._() : super._();

  factory _BrandProfile.fromJson(Map<String, dynamic> json) =
      _$BrandProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get brandName;
  @override
  String get brandCategory;
  @override
  String get description;
  @override
  String get website;
  @override
  String? get contactEmail;
  @override
  String? get state;
  @override
  String? get city;
  @override
  String? get size;
  @override
  String? get logoUrl;
  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  List<String> get portfolioLinks;
  @override
  bool get onboarded;
  @override
  int get creditsBalance;
  @override
  bool get verified;
  @override
  int get totalCollabs;
  @override
  double get avgRating;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BrandProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrandProfileImplCopyWith<_$BrandProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreatorDiscovery _$CreatorDiscoveryFromJson(Map<String, dynamic> json) {
  return _CreatorDiscovery.fromJson(json);
}

/// @nodoc
mixin _$CreatorDiscovery {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  List<String> get niches => throw _privateConstructorUsedError;
  List<String> get contentTypes => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  int get startingPrice => throw _privateConstructorUsedError;
  double get avgRating => throw _privateConstructorUsedError;
  int get totalCollabs => throw _privateConstructorUsedError;
  double get engagementRate => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  List<String> get portfolioLinks => throw _privateConstructorUsedError;
  String get followerRange => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  bool get instagramVerified => throw _privateConstructorUsedError;

  /// Serializes this CreatorDiscovery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreatorDiscovery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatorDiscoveryCopyWith<CreatorDiscovery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatorDiscoveryCopyWith<$Res> {
  factory $CreatorDiscoveryCopyWith(
          CreatorDiscovery value, $Res Function(CreatorDiscovery) then) =
      _$CreatorDiscoveryCopyWithImpl<$Res, CreatorDiscovery>;
  @useResult
  $Res call(
      {String id,
      String firstName,
      String? avatarUrl,
      String? state,
      String? city,
      List<String> niches,
      List<String> contentTypes,
      String tier,
      int startingPrice,
      double avgRating,
      int totalCollabs,
      double engagementRate,
      String bio,
      List<String> portfolioLinks,
      String followerRange,
      int followersCount,
      bool instagramVerified});
}

/// @nodoc
class _$CreatorDiscoveryCopyWithImpl<$Res, $Val extends CreatorDiscovery>
    implements $CreatorDiscoveryCopyWith<$Res> {
  _$CreatorDiscoveryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatorDiscovery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? avatarUrl = freezed,
    Object? state = freezed,
    Object? city = freezed,
    Object? niches = null,
    Object? contentTypes = null,
    Object? tier = null,
    Object? startingPrice = null,
    Object? avgRating = null,
    Object? totalCollabs = null,
    Object? engagementRate = null,
    Object? bio = null,
    Object? portfolioLinks = null,
    Object? followerRange = null,
    Object? followersCount = null,
    Object? instagramVerified = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      niches: null == niches
          ? _value.niches
          : niches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contentTypes: null == contentTypes
          ? _value.contentTypes
          : contentTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      startingPrice: null == startingPrice
          ? _value.startingPrice
          : startingPrice // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalCollabs: null == totalCollabs
          ? _value.totalCollabs
          : totalCollabs // ignore: cast_nullable_to_non_nullable
              as int,
      engagementRate: null == engagementRate
          ? _value.engagementRate
          : engagementRate // ignore: cast_nullable_to_non_nullable
              as double,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      portfolioLinks: null == portfolioLinks
          ? _value.portfolioLinks
          : portfolioLinks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followerRange: null == followerRange
          ? _value.followerRange
          : followerRange // ignore: cast_nullable_to_non_nullable
              as String,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      instagramVerified: null == instagramVerified
          ? _value.instagramVerified
          : instagramVerified // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreatorDiscoveryImplCopyWith<$Res>
    implements $CreatorDiscoveryCopyWith<$Res> {
  factory _$$CreatorDiscoveryImplCopyWith(_$CreatorDiscoveryImpl value,
          $Res Function(_$CreatorDiscoveryImpl) then) =
      __$$CreatorDiscoveryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String firstName,
      String? avatarUrl,
      String? state,
      String? city,
      List<String> niches,
      List<String> contentTypes,
      String tier,
      int startingPrice,
      double avgRating,
      int totalCollabs,
      double engagementRate,
      String bio,
      List<String> portfolioLinks,
      String followerRange,
      int followersCount,
      bool instagramVerified});
}

/// @nodoc
class __$$CreatorDiscoveryImplCopyWithImpl<$Res>
    extends _$CreatorDiscoveryCopyWithImpl<$Res, _$CreatorDiscoveryImpl>
    implements _$$CreatorDiscoveryImplCopyWith<$Res> {
  __$$CreatorDiscoveryImplCopyWithImpl(_$CreatorDiscoveryImpl _value,
      $Res Function(_$CreatorDiscoveryImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreatorDiscovery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? avatarUrl = freezed,
    Object? state = freezed,
    Object? city = freezed,
    Object? niches = null,
    Object? contentTypes = null,
    Object? tier = null,
    Object? startingPrice = null,
    Object? avgRating = null,
    Object? totalCollabs = null,
    Object? engagementRate = null,
    Object? bio = null,
    Object? portfolioLinks = null,
    Object? followerRange = null,
    Object? followersCount = null,
    Object? instagramVerified = null,
  }) {
    return _then(_$CreatorDiscoveryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      niches: null == niches
          ? _value._niches
          : niches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contentTypes: null == contentTypes
          ? _value._contentTypes
          : contentTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      startingPrice: null == startingPrice
          ? _value.startingPrice
          : startingPrice // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalCollabs: null == totalCollabs
          ? _value.totalCollabs
          : totalCollabs // ignore: cast_nullable_to_non_nullable
              as int,
      engagementRate: null == engagementRate
          ? _value.engagementRate
          : engagementRate // ignore: cast_nullable_to_non_nullable
              as double,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      portfolioLinks: null == portfolioLinks
          ? _value._portfolioLinks
          : portfolioLinks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followerRange: null == followerRange
          ? _value.followerRange
          : followerRange // ignore: cast_nullable_to_non_nullable
              as String,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      instagramVerified: null == instagramVerified
          ? _value.instagramVerified
          : instagramVerified // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatorDiscoveryImpl extends _CreatorDiscovery {
  const _$CreatorDiscoveryImpl(
      {required this.id,
      this.firstName = 'Creator',
      this.avatarUrl,
      this.state,
      this.city,
      final List<String> niches = const <String>[],
      final List<String> contentTypes = const <String>[],
      this.tier = 'micro',
      this.startingPrice = 0,
      this.avgRating = 0,
      this.totalCollabs = 0,
      this.engagementRate = 0,
      this.bio = '',
      final List<String> portfolioLinks = const <String>[],
      this.followerRange = '1K-5K',
      this.followersCount = 0,
      this.instagramVerified = false})
      : _niches = niches,
        _contentTypes = contentTypes,
        _portfolioLinks = portfolioLinks,
        super._();

  factory _$CreatorDiscoveryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatorDiscoveryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String firstName;
  @override
  final String? avatarUrl;
  @override
  final String? state;
  @override
  final String? city;
  final List<String> _niches;
  @override
  @JsonKey()
  List<String> get niches {
    if (_niches is EqualUnmodifiableListView) return _niches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_niches);
  }

  final List<String> _contentTypes;
  @override
  @JsonKey()
  List<String> get contentTypes {
    if (_contentTypes is EqualUnmodifiableListView) return _contentTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contentTypes);
  }

  @override
  @JsonKey()
  final String tier;
  @override
  @JsonKey()
  final int startingPrice;
  @override
  @JsonKey()
  final double avgRating;
  @override
  @JsonKey()
  final int totalCollabs;
  @override
  @JsonKey()
  final double engagementRate;
  @override
  @JsonKey()
  final String bio;
  final List<String> _portfolioLinks;
  @override
  @JsonKey()
  List<String> get portfolioLinks {
    if (_portfolioLinks is EqualUnmodifiableListView) return _portfolioLinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_portfolioLinks);
  }

  @override
  @JsonKey()
  final String followerRange;
  @override
  @JsonKey()
  final int followersCount;
  @override
  @JsonKey()
  final bool instagramVerified;

  @override
  String toString() {
    return 'CreatorDiscovery(id: $id, firstName: $firstName, avatarUrl: $avatarUrl, state: $state, city: $city, niches: $niches, contentTypes: $contentTypes, tier: $tier, startingPrice: $startingPrice, avgRating: $avgRating, totalCollabs: $totalCollabs, engagementRate: $engagementRate, bio: $bio, portfolioLinks: $portfolioLinks, followerRange: $followerRange, followersCount: $followersCount, instagramVerified: $instagramVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatorDiscoveryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.city, city) || other.city == city) &&
            const DeepCollectionEquality().equals(other._niches, _niches) &&
            const DeepCollectionEquality()
                .equals(other._contentTypes, _contentTypes) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.startingPrice, startingPrice) ||
                other.startingPrice == startingPrice) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.totalCollabs, totalCollabs) ||
                other.totalCollabs == totalCollabs) &&
            (identical(other.engagementRate, engagementRate) ||
                other.engagementRate == engagementRate) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality()
                .equals(other._portfolioLinks, _portfolioLinks) &&
            (identical(other.followerRange, followerRange) ||
                other.followerRange == followerRange) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.instagramVerified, instagramVerified) ||
                other.instagramVerified == instagramVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      avatarUrl,
      state,
      city,
      const DeepCollectionEquality().hash(_niches),
      const DeepCollectionEquality().hash(_contentTypes),
      tier,
      startingPrice,
      avgRating,
      totalCollabs,
      engagementRate,
      bio,
      const DeepCollectionEquality().hash(_portfolioLinks),
      followerRange,
      followersCount,
      instagramVerified);

  /// Create a copy of CreatorDiscovery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatorDiscoveryImplCopyWith<_$CreatorDiscoveryImpl> get copyWith =>
      __$$CreatorDiscoveryImplCopyWithImpl<_$CreatorDiscoveryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatorDiscoveryImplToJson(
      this,
    );
  }
}

abstract class _CreatorDiscovery extends CreatorDiscovery {
  const factory _CreatorDiscovery(
      {required final String id,
      final String firstName,
      final String? avatarUrl,
      final String? state,
      final String? city,
      final List<String> niches,
      final List<String> contentTypes,
      final String tier,
      final int startingPrice,
      final double avgRating,
      final int totalCollabs,
      final double engagementRate,
      final String bio,
      final List<String> portfolioLinks,
      final String followerRange,
      final int followersCount,
      final bool instagramVerified}) = _$CreatorDiscoveryImpl;
  const _CreatorDiscovery._() : super._();

  factory _CreatorDiscovery.fromJson(Map<String, dynamic> json) =
      _$CreatorDiscoveryImpl.fromJson;

  @override
  String get id;
  @override
  String get firstName;
  @override
  String? get avatarUrl;
  @override
  String? get state;
  @override
  String? get city;
  @override
  List<String> get niches;
  @override
  List<String> get contentTypes;
  @override
  String get tier;
  @override
  int get startingPrice;
  @override
  double get avgRating;
  @override
  int get totalCollabs;
  @override
  double get engagementRate;
  @override
  String get bio;
  @override
  List<String> get portfolioLinks;
  @override
  String get followerRange;
  @override
  int get followersCount;
  @override
  bool get instagramVerified;

  /// Create a copy of CreatorDiscovery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatorDiscoveryImplCopyWith<_$CreatorDiscoveryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollabRequest _$CollabRequestFromJson(Map<String, dynamic> json) {
  return _CollabRequest.fromJson(json);
}

/// @nodoc
mixin _$CollabRequest {
  String get id => throw _privateConstructorUsedError;
  String get brandId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String? get creatorFirstName => throw _privateConstructorUsedError;
  String? get creatorFullName => throw _privateConstructorUsedError;
  String? get creatorInstagramHandle => throw _privateConstructorUsedError;
  String? get creatorTier => throw _privateConstructorUsedError;
  String? get collabId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  int? get budget => throw _privateConstructorUsedError;
  CampaignCollabType get collabType => throw _privateConstructorUsedError;
  List<String> get deliverables => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CollabRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollabRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollabRequestCopyWith<CollabRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollabRequestCopyWith<$Res> {
  factory $CollabRequestCopyWith(
          CollabRequest value, $Res Function(CollabRequest) then) =
      _$CollabRequestCopyWithImpl<$Res, CollabRequest>;
  @useResult
  $Res call(
      {String id,
      String brandId,
      String creatorId,
      String? creatorFirstName,
      String? creatorFullName,
      String? creatorInstagramHandle,
      String? creatorTier,
      String? collabId,
      String? message,
      int? budget,
      CampaignCollabType collabType,
      List<String> deliverables,
      String status,
      DateTime? expiresAt,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$CollabRequestCopyWithImpl<$Res, $Val extends CollabRequest>
    implements $CollabRequestCopyWith<$Res> {
  _$CollabRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollabRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandId = null,
    Object? creatorId = null,
    Object? creatorFirstName = freezed,
    Object? creatorFullName = freezed,
    Object? creatorInstagramHandle = freezed,
    Object? creatorTier = freezed,
    Object? collabId = freezed,
    Object? message = freezed,
    Object? budget = freezed,
    Object? collabType = null,
    Object? deliverables = null,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandId: null == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorFirstName: freezed == creatorFirstName
          ? _value.creatorFirstName
          : creatorFirstName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorFullName: freezed == creatorFullName
          ? _value.creatorFullName
          : creatorFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorInstagramHandle: freezed == creatorInstagramHandle
          ? _value.creatorInstagramHandle
          : creatorInstagramHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorTier: freezed == creatorTier
          ? _value.creatorTier
          : creatorTier // ignore: cast_nullable_to_non_nullable
              as String?,
      collabId: freezed == collabId
          ? _value.collabId
          : collabId // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int?,
      collabType: null == collabType
          ? _value.collabType
          : collabType // ignore: cast_nullable_to_non_nullable
              as CampaignCollabType,
      deliverables: null == deliverables
          ? _value.deliverables
          : deliverables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollabRequestImplCopyWith<$Res>
    implements $CollabRequestCopyWith<$Res> {
  factory _$$CollabRequestImplCopyWith(
          _$CollabRequestImpl value, $Res Function(_$CollabRequestImpl) then) =
      __$$CollabRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String brandId,
      String creatorId,
      String? creatorFirstName,
      String? creatorFullName,
      String? creatorInstagramHandle,
      String? creatorTier,
      String? collabId,
      String? message,
      int? budget,
      CampaignCollabType collabType,
      List<String> deliverables,
      String status,
      DateTime? expiresAt,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$CollabRequestImplCopyWithImpl<$Res>
    extends _$CollabRequestCopyWithImpl<$Res, _$CollabRequestImpl>
    implements _$$CollabRequestImplCopyWith<$Res> {
  __$$CollabRequestImplCopyWithImpl(
      _$CollabRequestImpl _value, $Res Function(_$CollabRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollabRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandId = null,
    Object? creatorId = null,
    Object? creatorFirstName = freezed,
    Object? creatorFullName = freezed,
    Object? creatorInstagramHandle = freezed,
    Object? creatorTier = freezed,
    Object? collabId = freezed,
    Object? message = freezed,
    Object? budget = freezed,
    Object? collabType = null,
    Object? deliverables = null,
    Object? status = null,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CollabRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandId: null == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorFirstName: freezed == creatorFirstName
          ? _value.creatorFirstName
          : creatorFirstName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorFullName: freezed == creatorFullName
          ? _value.creatorFullName
          : creatorFullName // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorInstagramHandle: freezed == creatorInstagramHandle
          ? _value.creatorInstagramHandle
          : creatorInstagramHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorTier: freezed == creatorTier
          ? _value.creatorTier
          : creatorTier // ignore: cast_nullable_to_non_nullable
              as String?,
      collabId: freezed == collabId
          ? _value.collabId
          : collabId // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int?,
      collabType: null == collabType
          ? _value.collabType
          : collabType // ignore: cast_nullable_to_non_nullable
              as CampaignCollabType,
      deliverables: null == deliverables
          ? _value._deliverables
          : deliverables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CollabRequestImpl implements _CollabRequest {
  const _$CollabRequestImpl(
      {required this.id,
      required this.brandId,
      required this.creatorId,
      this.creatorFirstName,
      this.creatorFullName,
      this.creatorInstagramHandle,
      this.creatorTier,
      this.collabId,
      this.message,
      this.budget,
      this.collabType = CampaignCollabType.paid,
      final List<String> deliverables = const <String>[],
      this.status = 'pending',
      this.expiresAt,
      this.createdAt,
      this.updatedAt})
      : _deliverables = deliverables;

  factory _$CollabRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollabRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String brandId;
  @override
  final String creatorId;
  @override
  final String? creatorFirstName;
  @override
  final String? creatorFullName;
  @override
  final String? creatorInstagramHandle;
  @override
  final String? creatorTier;
  @override
  final String? collabId;
  @override
  final String? message;
  @override
  final int? budget;
  @override
  @JsonKey()
  final CampaignCollabType collabType;
  final List<String> _deliverables;
  @override
  @JsonKey()
  List<String> get deliverables {
    if (_deliverables is EqualUnmodifiableListView) return _deliverables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deliverables);
  }

  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CollabRequest(id: $id, brandId: $brandId, creatorId: $creatorId, creatorFirstName: $creatorFirstName, creatorFullName: $creatorFullName, creatorInstagramHandle: $creatorInstagramHandle, creatorTier: $creatorTier, collabId: $collabId, message: $message, budget: $budget, collabType: $collabType, deliverables: $deliverables, status: $status, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollabRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorFirstName, creatorFirstName) ||
                other.creatorFirstName == creatorFirstName) &&
            (identical(other.creatorFullName, creatorFullName) ||
                other.creatorFullName == creatorFullName) &&
            (identical(other.creatorInstagramHandle, creatorInstagramHandle) ||
                other.creatorInstagramHandle == creatorInstagramHandle) &&
            (identical(other.creatorTier, creatorTier) ||
                other.creatorTier == creatorTier) &&
            (identical(other.collabId, collabId) ||
                other.collabId == collabId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.collabType, collabType) ||
                other.collabType == collabType) &&
            const DeepCollectionEquality()
                .equals(other._deliverables, _deliverables) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      brandId,
      creatorId,
      creatorFirstName,
      creatorFullName,
      creatorInstagramHandle,
      creatorTier,
      collabId,
      message,
      budget,
      collabType,
      const DeepCollectionEquality().hash(_deliverables),
      status,
      expiresAt,
      createdAt,
      updatedAt);

  /// Create a copy of CollabRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollabRequestImplCopyWith<_$CollabRequestImpl> get copyWith =>
      __$$CollabRequestImplCopyWithImpl<_$CollabRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollabRequestImplToJson(
      this,
    );
  }
}

abstract class _CollabRequest implements CollabRequest {
  const factory _CollabRequest(
      {required final String id,
      required final String brandId,
      required final String creatorId,
      final String? creatorFirstName,
      final String? creatorFullName,
      final String? creatorInstagramHandle,
      final String? creatorTier,
      final String? collabId,
      final String? message,
      final int? budget,
      final CampaignCollabType collabType,
      final List<String> deliverables,
      final String status,
      final DateTime? expiresAt,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$CollabRequestImpl;

  factory _CollabRequest.fromJson(Map<String, dynamic> json) =
      _$CollabRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get brandId;
  @override
  String get creatorId;
  @override
  String? get creatorFirstName;
  @override
  String? get creatorFullName;
  @override
  String? get creatorInstagramHandle;
  @override
  String? get creatorTier;
  @override
  String? get collabId;
  @override
  String? get message;
  @override
  int? get budget;
  @override
  CampaignCollabType get collabType;
  @override
  List<String> get deliverables;
  @override
  String get status;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CollabRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollabRequestImplCopyWith<_$CollabRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Campaign _$CampaignFromJson(Map<String, dynamic> json) {
  return _Campaign.fromJson(json);
}

/// @nodoc
mixin _$Campaign {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get niche => throw _privateConstructorUsedError;
  CampaignCollabType get collabType => throw _privateConstructorUsedError;
  int? get budget => throw _privateConstructorUsedError;
  int? get budgetMin => throw _privateConstructorUsedError;
  int? get budgetMax => throw _privateConstructorUsedError;
  List<String> get deliverables => throw _privateConstructorUsedError;
  String get requirements => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  CampaignStatus get status => throw _privateConstructorUsedError;
  int get slots => throw _privateConstructorUsedError;
  int get slotsFilled => throw _privateConstructorUsedError;
  String? get targetState => throw _privateConstructorUsedError;
  String? get targetCity => throw _privateConstructorUsedError;
  int get bidCount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampaignCopyWith<Campaign> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampaignCopyWith<$Res> {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) then) =
      _$CampaignCopyWithImpl<$Res, Campaign>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      List<String> niche,
      CampaignCollabType collabType,
      int? budget,
      int? budgetMin,
      int? budgetMax,
      List<String> deliverables,
      String requirements,
      DateTime? deadline,
      CampaignStatus status,
      int slots,
      int slotsFilled,
      String? targetState,
      String? targetCity,
      int bidCount,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$CampaignCopyWithImpl<$Res, $Val extends Campaign>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? niche = null,
    Object? collabType = null,
    Object? budget = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? deliverables = null,
    Object? requirements = null,
    Object? deadline = freezed,
    Object? status = null,
    Object? slots = null,
    Object? slotsFilled = null,
    Object? targetState = freezed,
    Object? targetCity = freezed,
    Object? bidCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      niche: null == niche
          ? _value.niche
          : niche // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collabType: null == collabType
          ? _value.collabType
          : collabType // ignore: cast_nullable_to_non_nullable
              as CampaignCollabType,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as int?,
      deliverables: null == deliverables
          ? _value.deliverables
          : deliverables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      requirements: null == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CampaignStatus,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as int,
      slotsFilled: null == slotsFilled
          ? _value.slotsFilled
          : slotsFilled // ignore: cast_nullable_to_non_nullable
              as int,
      targetState: freezed == targetState
          ? _value.targetState
          : targetState // ignore: cast_nullable_to_non_nullable
              as String?,
      targetCity: freezed == targetCity
          ? _value.targetCity
          : targetCity // ignore: cast_nullable_to_non_nullable
              as String?,
      bidCount: null == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CampaignImplCopyWith<$Res>
    implements $CampaignCopyWith<$Res> {
  factory _$$CampaignImplCopyWith(
          _$CampaignImpl value, $Res Function(_$CampaignImpl) then) =
      __$$CampaignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      List<String> niche,
      CampaignCollabType collabType,
      int? budget,
      int? budgetMin,
      int? budgetMax,
      List<String> deliverables,
      String requirements,
      DateTime? deadline,
      CampaignStatus status,
      int slots,
      int slotsFilled,
      String? targetState,
      String? targetCity,
      int bidCount,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$CampaignImplCopyWithImpl<$Res>
    extends _$CampaignCopyWithImpl<$Res, _$CampaignImpl>
    implements _$$CampaignImplCopyWith<$Res> {
  __$$CampaignImplCopyWithImpl(
      _$CampaignImpl _value, $Res Function(_$CampaignImpl) _then)
      : super(_value, _then);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? niche = null,
    Object? collabType = null,
    Object? budget = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? deliverables = null,
    Object? requirements = null,
    Object? deadline = freezed,
    Object? status = null,
    Object? slots = null,
    Object? slotsFilled = null,
    Object? targetState = freezed,
    Object? targetCity = freezed,
    Object? bidCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CampaignImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      niche: null == niche
          ? _value._niche
          : niche // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collabType: null == collabType
          ? _value.collabType
          : collabType // ignore: cast_nullable_to_non_nullable
              as CampaignCollabType,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as int?,
      deliverables: null == deliverables
          ? _value._deliverables
          : deliverables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      requirements: null == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CampaignStatus,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as int,
      slotsFilled: null == slotsFilled
          ? _value.slotsFilled
          : slotsFilled // ignore: cast_nullable_to_non_nullable
              as int,
      targetState: freezed == targetState
          ? _value.targetState
          : targetState // ignore: cast_nullable_to_non_nullable
              as String?,
      targetCity: freezed == targetCity
          ? _value.targetCity
          : targetCity // ignore: cast_nullable_to_non_nullable
              as String?,
      bidCount: null == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignImpl extends _Campaign {
  const _$CampaignImpl(
      {required this.id,
      this.title = 'Campaign',
      this.description = '',
      final List<String> niche = const <String>[],
      this.collabType = CampaignCollabType.paid,
      this.budget,
      this.budgetMin,
      this.budgetMax,
      final List<String> deliverables = const <String>[],
      this.requirements = '',
      this.deadline,
      this.status = CampaignStatus.active,
      this.slots = 1,
      this.slotsFilled = 0,
      this.targetState,
      this.targetCity,
      this.bidCount = 0,
      this.createdAt,
      this.updatedAt})
      : _niche = niche,
        _deliverables = deliverables,
        super._();

  factory _$CampaignImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  final List<String> _niche;
  @override
  @JsonKey()
  List<String> get niche {
    if (_niche is EqualUnmodifiableListView) return _niche;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_niche);
  }

  @override
  @JsonKey()
  final CampaignCollabType collabType;
  @override
  final int? budget;
  @override
  final int? budgetMin;
  @override
  final int? budgetMax;
  final List<String> _deliverables;
  @override
  @JsonKey()
  List<String> get deliverables {
    if (_deliverables is EqualUnmodifiableListView) return _deliverables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deliverables);
  }

  @override
  @JsonKey()
  final String requirements;
  @override
  final DateTime? deadline;
  @override
  @JsonKey()
  final CampaignStatus status;
  @override
  @JsonKey()
  final int slots;
  @override
  @JsonKey()
  final int slotsFilled;
  @override
  final String? targetState;
  @override
  final String? targetCity;
  @override
  @JsonKey()
  final int bidCount;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Campaign(id: $id, title: $title, description: $description, niche: $niche, collabType: $collabType, budget: $budget, budgetMin: $budgetMin, budgetMax: $budgetMax, deliverables: $deliverables, requirements: $requirements, deadline: $deadline, status: $status, slots: $slots, slotsFilled: $slotsFilled, targetState: $targetState, targetCity: $targetCity, bidCount: $bidCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._niche, _niche) &&
            (identical(other.collabType, collabType) ||
                other.collabType == collabType) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.budgetMin, budgetMin) ||
                other.budgetMin == budgetMin) &&
            (identical(other.budgetMax, budgetMax) ||
                other.budgetMax == budgetMax) &&
            const DeepCollectionEquality()
                .equals(other._deliverables, _deliverables) &&
            (identical(other.requirements, requirements) ||
                other.requirements == requirements) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.slots, slots) || other.slots == slots) &&
            (identical(other.slotsFilled, slotsFilled) ||
                other.slotsFilled == slotsFilled) &&
            (identical(other.targetState, targetState) ||
                other.targetState == targetState) &&
            (identical(other.targetCity, targetCity) ||
                other.targetCity == targetCity) &&
            (identical(other.bidCount, bidCount) ||
                other.bidCount == bidCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        const DeepCollectionEquality().hash(_niche),
        collabType,
        budget,
        budgetMin,
        budgetMax,
        const DeepCollectionEquality().hash(_deliverables),
        requirements,
        deadline,
        status,
        slots,
        slotsFilled,
        targetState,
        targetCity,
        bidCount,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      __$$CampaignImplCopyWithImpl<_$CampaignImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampaignImplToJson(
      this,
    );
  }
}

abstract class _Campaign extends Campaign {
  const factory _Campaign(
      {required final String id,
      final String title,
      final String description,
      final List<String> niche,
      final CampaignCollabType collabType,
      final int? budget,
      final int? budgetMin,
      final int? budgetMax,
      final List<String> deliverables,
      final String requirements,
      final DateTime? deadline,
      final CampaignStatus status,
      final int slots,
      final int slotsFilled,
      final String? targetState,
      final String? targetCity,
      final int bidCount,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$CampaignImpl;
  const _Campaign._() : super._();

  factory _Campaign.fromJson(Map<String, dynamic> json) =
      _$CampaignImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  List<String> get niche;
  @override
  CampaignCollabType get collabType;
  @override
  int? get budget;
  @override
  int? get budgetMin;
  @override
  int? get budgetMax;
  @override
  List<String> get deliverables;
  @override
  String get requirements;
  @override
  DateTime? get deadline;
  @override
  CampaignStatus get status;
  @override
  int get slots;
  @override
  int get slotsFilled;
  @override
  String? get targetState;
  @override
  String? get targetCity;
  @override
  int get bidCount;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Bid _$BidFromJson(Map<String, dynamic> json) {
  return _Bid.fromJson(json);
}

/// @nodoc
mixin _$Bid {
  String get id => throw _privateConstructorUsedError;
  String get campaignId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  int get bidAmount => throw _privateConstructorUsedError;
  String get deliverables => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get includeBarter => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String get creatorFirstName => throw _privateConstructorUsedError;
  String get creatorFullName => throw _privateConstructorUsedError;
  String? get creatorAvatarUrl => throw _privateConstructorUsedError;
  String get creatorHandle => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  double get engagementRate => throw _privateConstructorUsedError;
  List<String> get niches => throw _privateConstructorUsedError;
  CampaignCollabType get collabType => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  bool get isAccepted => throw _privateConstructorUsedError;

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bid
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BidCopyWith<Bid> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BidCopyWith<$Res> {
  factory $BidCopyWith(Bid value, $Res Function(Bid) then) =
      _$BidCopyWithImpl<$Res, Bid>;
  @useResult
  $Res call(
      {String id,
      String campaignId,
      String creatorId,
      int bidAmount,
      String deliverables,
      String? message,
      String status,
      bool includeBarter,
      DateTime? createdAt,
      DateTime? updatedAt,
      String creatorFirstName,
      String creatorFullName,
      String? creatorAvatarUrl,
      String creatorHandle,
      String tier,
      int followersCount,
      double engagementRate,
      List<String> niches,
      CampaignCollabType collabType,
      bool isUnlocked,
      bool isAccepted});
}

/// @nodoc
class _$BidCopyWithImpl<$Res, $Val extends Bid> implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bid
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? campaignId = null,
    Object? creatorId = null,
    Object? bidAmount = null,
    Object? deliverables = null,
    Object? message = freezed,
    Object? status = null,
    Object? includeBarter = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? creatorFirstName = null,
    Object? creatorFullName = null,
    Object? creatorAvatarUrl = freezed,
    Object? creatorHandle = null,
    Object? tier = null,
    Object? followersCount = null,
    Object? engagementRate = null,
    Object? niches = null,
    Object? collabType = null,
    Object? isUnlocked = null,
    Object? isAccepted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      campaignId: null == campaignId
          ? _value.campaignId
          : campaignId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      bidAmount: null == bidAmount
          ? _value.bidAmount
          : bidAmount // ignore: cast_nullable_to_non_nullable
              as int,
      deliverables: null == deliverables
          ? _value.deliverables
          : deliverables // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      includeBarter: null == includeBarter
          ? _value.includeBarter
          : includeBarter // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorFirstName: null == creatorFirstName
          ? _value.creatorFirstName
          : creatorFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorFullName: null == creatorFullName
          ? _value.creatorFullName
          : creatorFullName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorAvatarUrl: freezed == creatorAvatarUrl
          ? _value.creatorAvatarUrl
          : creatorAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorHandle: null == creatorHandle
          ? _value.creatorHandle
          : creatorHandle // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      engagementRate: null == engagementRate
          ? _value.engagementRate
          : engagementRate // ignore: cast_nullable_to_non_nullable
              as double,
      niches: null == niches
          ? _value.niches
          : niches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collabType: null == collabType
          ? _value.collabType
          : collabType // ignore: cast_nullable_to_non_nullable
              as CampaignCollabType,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      isAccepted: null == isAccepted
          ? _value.isAccepted
          : isAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BidImplCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$$BidImplCopyWith(_$BidImpl value, $Res Function(_$BidImpl) then) =
      __$$BidImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String campaignId,
      String creatorId,
      int bidAmount,
      String deliverables,
      String? message,
      String status,
      bool includeBarter,
      DateTime? createdAt,
      DateTime? updatedAt,
      String creatorFirstName,
      String creatorFullName,
      String? creatorAvatarUrl,
      String creatorHandle,
      String tier,
      int followersCount,
      double engagementRate,
      List<String> niches,
      CampaignCollabType collabType,
      bool isUnlocked,
      bool isAccepted});
}

/// @nodoc
class __$$BidImplCopyWithImpl<$Res> extends _$BidCopyWithImpl<$Res, _$BidImpl>
    implements _$$BidImplCopyWith<$Res> {
  __$$BidImplCopyWithImpl(_$BidImpl _value, $Res Function(_$BidImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bid
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? campaignId = null,
    Object? creatorId = null,
    Object? bidAmount = null,
    Object? deliverables = null,
    Object? message = freezed,
    Object? status = null,
    Object? includeBarter = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? creatorFirstName = null,
    Object? creatorFullName = null,
    Object? creatorAvatarUrl = freezed,
    Object? creatorHandle = null,
    Object? tier = null,
    Object? followersCount = null,
    Object? engagementRate = null,
    Object? niches = null,
    Object? collabType = null,
    Object? isUnlocked = null,
    Object? isAccepted = null,
  }) {
    return _then(_$BidImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      campaignId: null == campaignId
          ? _value.campaignId
          : campaignId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      bidAmount: null == bidAmount
          ? _value.bidAmount
          : bidAmount // ignore: cast_nullable_to_non_nullable
              as int,
      deliverables: null == deliverables
          ? _value.deliverables
          : deliverables // ignore: cast_nullable_to_non_nullable
              as String,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      includeBarter: null == includeBarter
          ? _value.includeBarter
          : includeBarter // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorFirstName: null == creatorFirstName
          ? _value.creatorFirstName
          : creatorFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorFullName: null == creatorFullName
          ? _value.creatorFullName
          : creatorFullName // ignore: cast_nullable_to_non_nullable
              as String,
      creatorAvatarUrl: freezed == creatorAvatarUrl
          ? _value.creatorAvatarUrl
          : creatorAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      creatorHandle: null == creatorHandle
          ? _value.creatorHandle
          : creatorHandle // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      engagementRate: null == engagementRate
          ? _value.engagementRate
          : engagementRate // ignore: cast_nullable_to_non_nullable
              as double,
      niches: null == niches
          ? _value._niches
          : niches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collabType: null == collabType
          ? _value.collabType
          : collabType // ignore: cast_nullable_to_non_nullable
              as CampaignCollabType,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      isAccepted: null == isAccepted
          ? _value.isAccepted
          : isAccepted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BidImpl extends _Bid {
  const _$BidImpl(
      {required this.id,
      required this.campaignId,
      required this.creatorId,
      this.bidAmount = 0,
      this.deliverables = '',
      this.message,
      this.status = 'pending',
      this.includeBarter = false,
      this.createdAt,
      this.updatedAt,
      this.creatorFirstName = 'Creator',
      this.creatorFullName = 'Creator',
      this.creatorAvatarUrl,
      this.creatorHandle = '',
      this.tier = 'micro',
      this.followersCount = 0,
      this.engagementRate = 0,
      final List<String> niches = const <String>[],
      this.collabType = CampaignCollabType.paid,
      this.isUnlocked = false,
      this.isAccepted = false})
      : _niches = niches,
        super._();

  factory _$BidImpl.fromJson(Map<String, dynamic> json) =>
      _$$BidImplFromJson(json);

  @override
  final String id;
  @override
  final String campaignId;
  @override
  final String creatorId;
  @override
  @JsonKey()
  final int bidAmount;
  @override
  @JsonKey()
  final String deliverables;
  @override
  final String? message;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool includeBarter;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final String creatorFirstName;
  @override
  @JsonKey()
  final String creatorFullName;
  @override
  final String? creatorAvatarUrl;
  @override
  @JsonKey()
  final String creatorHandle;
  @override
  @JsonKey()
  final String tier;
  @override
  @JsonKey()
  final int followersCount;
  @override
  @JsonKey()
  final double engagementRate;
  final List<String> _niches;
  @override
  @JsonKey()
  List<String> get niches {
    if (_niches is EqualUnmodifiableListView) return _niches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_niches);
  }

  @override
  @JsonKey()
  final CampaignCollabType collabType;
  @override
  @JsonKey()
  final bool isUnlocked;
  @override
  @JsonKey()
  final bool isAccepted;

  @override
  String toString() {
    return 'Bid(id: $id, campaignId: $campaignId, creatorId: $creatorId, bidAmount: $bidAmount, deliverables: $deliverables, message: $message, status: $status, includeBarter: $includeBarter, createdAt: $createdAt, updatedAt: $updatedAt, creatorFirstName: $creatorFirstName, creatorFullName: $creatorFullName, creatorAvatarUrl: $creatorAvatarUrl, creatorHandle: $creatorHandle, tier: $tier, followersCount: $followersCount, engagementRate: $engagementRate, niches: $niches, collabType: $collabType, isUnlocked: $isUnlocked, isAccepted: $isAccepted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BidImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.campaignId, campaignId) ||
                other.campaignId == campaignId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.bidAmount, bidAmount) ||
                other.bidAmount == bidAmount) &&
            (identical(other.deliverables, deliverables) ||
                other.deliverables == deliverables) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.includeBarter, includeBarter) ||
                other.includeBarter == includeBarter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.creatorFirstName, creatorFirstName) ||
                other.creatorFirstName == creatorFirstName) &&
            (identical(other.creatorFullName, creatorFullName) ||
                other.creatorFullName == creatorFullName) &&
            (identical(other.creatorAvatarUrl, creatorAvatarUrl) ||
                other.creatorAvatarUrl == creatorAvatarUrl) &&
            (identical(other.creatorHandle, creatorHandle) ||
                other.creatorHandle == creatorHandle) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.engagementRate, engagementRate) ||
                other.engagementRate == engagementRate) &&
            const DeepCollectionEquality().equals(other._niches, _niches) &&
            (identical(other.collabType, collabType) ||
                other.collabType == collabType) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.isAccepted, isAccepted) ||
                other.isAccepted == isAccepted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        campaignId,
        creatorId,
        bidAmount,
        deliverables,
        message,
        status,
        includeBarter,
        createdAt,
        updatedAt,
        creatorFirstName,
        creatorFullName,
        creatorAvatarUrl,
        creatorHandle,
        tier,
        followersCount,
        engagementRate,
        const DeepCollectionEquality().hash(_niches),
        collabType,
        isUnlocked,
        isAccepted
      ]);

  /// Create a copy of Bid
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BidImplCopyWith<_$BidImpl> get copyWith =>
      __$$BidImplCopyWithImpl<_$BidImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BidImplToJson(
      this,
    );
  }
}

abstract class _Bid extends Bid {
  const factory _Bid(
      {required final String id,
      required final String campaignId,
      required final String creatorId,
      final int bidAmount,
      final String deliverables,
      final String? message,
      final String status,
      final bool includeBarter,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String creatorFirstName,
      final String creatorFullName,
      final String? creatorAvatarUrl,
      final String creatorHandle,
      final String tier,
      final int followersCount,
      final double engagementRate,
      final List<String> niches,
      final CampaignCollabType collabType,
      final bool isUnlocked,
      final bool isAccepted}) = _$BidImpl;
  const _Bid._() : super._();

  factory _Bid.fromJson(Map<String, dynamic> json) = _$BidImpl.fromJson;

  @override
  String get id;
  @override
  String get campaignId;
  @override
  String get creatorId;
  @override
  int get bidAmount;
  @override
  String get deliverables;
  @override
  String? get message;
  @override
  String get status;
  @override
  bool get includeBarter;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String get creatorFirstName;
  @override
  String get creatorFullName;
  @override
  String? get creatorAvatarUrl;
  @override
  String get creatorHandle;
  @override
  String get tier;
  @override
  int get followersCount;
  @override
  double get engagementRate;
  @override
  List<String> get niches;
  @override
  CampaignCollabType get collabType;
  @override
  bool get isUnlocked;
  @override
  bool get isAccepted;

  /// Create a copy of Bid
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BidImplCopyWith<_$BidImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditTransaction _$CreditTransactionFromJson(Map<String, dynamic> json) {
  return _CreditTransaction.fromJson(json);
}

/// @nodoc
mixin _$CreditTransaction {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  int get balanceAfter => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CreditTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditTransactionCopyWith<CreditTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditTransactionCopyWith<$Res> {
  factory $CreditTransactionCopyWith(
          CreditTransaction value, $Res Function(CreditTransaction) then) =
      _$CreditTransactionCopyWithImpl<$Res, CreditTransaction>;
  @useResult
  $Res call(
      {String id,
      String type,
      int amount,
      String reason,
      String? referenceId,
      int balanceAfter,
      DateTime? createdAt});
}

/// @nodoc
class _$CreditTransactionCopyWithImpl<$Res, $Val extends CreditTransaction>
    implements $CreditTransactionCopyWith<$Res> {
  _$CreditTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? reason = null,
    Object? referenceId = freezed,
    Object? balanceAfter = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      balanceAfter: null == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreditTransactionImplCopyWith<$Res>
    implements $CreditTransactionCopyWith<$Res> {
  factory _$$CreditTransactionImplCopyWith(_$CreditTransactionImpl value,
          $Res Function(_$CreditTransactionImpl) then) =
      __$$CreditTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      int amount,
      String reason,
      String? referenceId,
      int balanceAfter,
      DateTime? createdAt});
}

/// @nodoc
class __$$CreditTransactionImplCopyWithImpl<$Res>
    extends _$CreditTransactionCopyWithImpl<$Res, _$CreditTransactionImpl>
    implements _$$CreditTransactionImplCopyWith<$Res> {
  __$$CreditTransactionImplCopyWithImpl(_$CreditTransactionImpl _value,
      $Res Function(_$CreditTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreditTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? reason = null,
    Object? referenceId = freezed,
    Object? balanceAfter = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$CreditTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      balanceAfter: null == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditTransactionImpl extends _CreditTransaction {
  const _$CreditTransactionImpl(
      {required this.id,
      this.type = 'deduct',
      this.amount = 0,
      this.reason = '',
      this.referenceId,
      this.balanceAfter = 0,
      this.createdAt})
      : super._();

  factory _$CreditTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditTransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final int amount;
  @override
  @JsonKey()
  final String reason;
  @override
  final String? referenceId;
  @override
  @JsonKey()
  final int balanceAfter;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CreditTransaction(id: $id, type: $type, amount: $amount, reason: $reason, referenceId: $referenceId, balanceAfter: $balanceAfter, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, amount, reason,
      referenceId, balanceAfter, createdAt);

  /// Create a copy of CreditTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditTransactionImplCopyWith<_$CreditTransactionImpl> get copyWith =>
      __$$CreditTransactionImplCopyWithImpl<_$CreditTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditTransactionImplToJson(
      this,
    );
  }
}

abstract class _CreditTransaction extends CreditTransaction {
  const factory _CreditTransaction(
      {required final String id,
      final String type,
      final int amount,
      final String reason,
      final String? referenceId,
      final int balanceAfter,
      final DateTime? createdAt}) = _$CreditTransactionImpl;
  const _CreditTransaction._() : super._();

  factory _CreditTransaction.fromJson(Map<String, dynamic> json) =
      _$CreditTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  int get amount;
  @override
  String get reason;
  @override
  String? get referenceId;
  @override
  int get balanceAfter;
  @override
  DateTime? get createdAt;

  /// Create a copy of CreditTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditTransactionImplCopyWith<_$CreditTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreditsData _$CreditsDataFromJson(Map<String, dynamic> json) {
  return _CreditsData.fromJson(json);
}

/// @nodoc
mixin _$CreditsData {
  int get balance => throw _privateConstructorUsedError;
  List<CreditTransaction> get transactions =>
      throw _privateConstructorUsedError;

  /// Serializes this CreditsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditsDataCopyWith<CreditsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditsDataCopyWith<$Res> {
  factory $CreditsDataCopyWith(
          CreditsData value, $Res Function(CreditsData) then) =
      _$CreditsDataCopyWithImpl<$Res, CreditsData>;
  @useResult
  $Res call({int balance, List<CreditTransaction> transactions});
}

/// @nodoc
class _$CreditsDataCopyWithImpl<$Res, $Val extends CreditsData>
    implements $CreditsDataCopyWith<$Res> {
  _$CreditsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? transactions = null,
  }) {
    return _then(_value.copyWith(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<CreditTransaction>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreditsDataImplCopyWith<$Res>
    implements $CreditsDataCopyWith<$Res> {
  factory _$$CreditsDataImplCopyWith(
          _$CreditsDataImpl value, $Res Function(_$CreditsDataImpl) then) =
      __$$CreditsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int balance, List<CreditTransaction> transactions});
}

/// @nodoc
class __$$CreditsDataImplCopyWithImpl<$Res>
    extends _$CreditsDataCopyWithImpl<$Res, _$CreditsDataImpl>
    implements _$$CreditsDataImplCopyWith<$Res> {
  __$$CreditsDataImplCopyWithImpl(
      _$CreditsDataImpl _value, $Res Function(_$CreditsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreditsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? transactions = null,
  }) {
    return _then(_$CreditsDataImpl(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      transactions: null == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<CreditTransaction>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditsDataImpl implements _CreditsData {
  const _$CreditsDataImpl(
      {this.balance = 0,
      final List<CreditTransaction> transactions = const <CreditTransaction>[]})
      : _transactions = transactions;

  factory _$CreditsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditsDataImplFromJson(json);

  @override
  @JsonKey()
  final int balance;
  final List<CreditTransaction> _transactions;
  @override
  @JsonKey()
  List<CreditTransaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  @override
  String toString() {
    return 'CreditsData(balance: $balance, transactions: $transactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditsDataImpl &&
            (identical(other.balance, balance) || other.balance == balance) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, balance, const DeepCollectionEquality().hash(_transactions));

  /// Create a copy of CreditsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditsDataImplCopyWith<_$CreditsDataImpl> get copyWith =>
      __$$CreditsDataImplCopyWithImpl<_$CreditsDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditsDataImplToJson(
      this,
    );
  }
}

abstract class _CreditsData implements CreditsData {
  const factory _CreditsData(
      {final int balance,
      final List<CreditTransaction> transactions}) = _$CreditsDataImpl;

  factory _CreditsData.fromJson(Map<String, dynamic> json) =
      _$CreditsDataImpl.fromJson;

  @override
  int get balance;
  @override
  List<CreditTransaction> get transactions;

  /// Create a copy of CreditsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditsDataImplCopyWith<_$CreditsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BrandEvent _$BrandEventFromJson(Map<String, dynamic> json) {
  return _BrandEvent.fromJson(json);
}

/// @nodoc
mixin _$BrandEvent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  DateTime get eventDate => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get venueName => throw _privateConstructorUsedError;
  String? get venueAddress => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  bool get isVirtual => throw _privateConstructorUsedError;
  String? get virtualLink => throw _privateConstructorUsedError;
  int get totalSlots => throw _privateConstructorUsedError;
  int get slotsFilled => throw _privateConstructorUsedError;
  String get whatCreatorsGet => throw _privateConstructorUsedError;
  List<String> get targetNiche => throw _privateConstructorUsedError;
  List<String> get targetTier => throw _privateConstructorUsedError;
  BrandEventStatus get status => throw _privateConstructorUsedError;
  int get invitesSent => throw _privateConstructorUsedError;
  int get invitesAccepted => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BrandEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BrandEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrandEventCopyWith<BrandEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrandEventCopyWith<$Res> {
  factory $BrandEventCopyWith(
          BrandEvent value, $Res Function(BrandEvent) then) =
      _$BrandEventCopyWithImpl<$Res, BrandEvent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String eventType,
      DateTime eventDate,
      String? location,
      String? imageUrl,
      String? venueName,
      String? venueAddress,
      String? city,
      String? state,
      bool isVirtual,
      String? virtualLink,
      int totalSlots,
      int slotsFilled,
      String whatCreatorsGet,
      List<String> targetNiche,
      List<String> targetTier,
      BrandEventStatus status,
      int invitesSent,
      int invitesAccepted,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$BrandEventCopyWithImpl<$Res, $Val extends BrandEvent>
    implements $BrandEventCopyWith<$Res> {
  _$BrandEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BrandEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? eventType = null,
    Object? eventDate = null,
    Object? location = freezed,
    Object? imageUrl = freezed,
    Object? venueName = freezed,
    Object? venueAddress = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? isVirtual = null,
    Object? virtualLink = freezed,
    Object? totalSlots = null,
    Object? slotsFilled = null,
    Object? whatCreatorsGet = null,
    Object? targetNiche = null,
    Object? targetTier = null,
    Object? status = null,
    Object? invitesSent = null,
    Object? invitesAccepted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      venueName: freezed == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String?,
      venueAddress: freezed == venueAddress
          ? _value.venueAddress
          : venueAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      isVirtual: null == isVirtual
          ? _value.isVirtual
          : isVirtual // ignore: cast_nullable_to_non_nullable
              as bool,
      virtualLink: freezed == virtualLink
          ? _value.virtualLink
          : virtualLink // ignore: cast_nullable_to_non_nullable
              as String?,
      totalSlots: null == totalSlots
          ? _value.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      slotsFilled: null == slotsFilled
          ? _value.slotsFilled
          : slotsFilled // ignore: cast_nullable_to_non_nullable
              as int,
      whatCreatorsGet: null == whatCreatorsGet
          ? _value.whatCreatorsGet
          : whatCreatorsGet // ignore: cast_nullable_to_non_nullable
              as String,
      targetNiche: null == targetNiche
          ? _value.targetNiche
          : targetNiche // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetTier: null == targetTier
          ? _value.targetTier
          : targetTier // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BrandEventStatus,
      invitesSent: null == invitesSent
          ? _value.invitesSent
          : invitesSent // ignore: cast_nullable_to_non_nullable
              as int,
      invitesAccepted: null == invitesAccepted
          ? _value.invitesAccepted
          : invitesAccepted // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BrandEventImplCopyWith<$Res>
    implements $BrandEventCopyWith<$Res> {
  factory _$$BrandEventImplCopyWith(
          _$BrandEventImpl value, $Res Function(_$BrandEventImpl) then) =
      __$$BrandEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String eventType,
      DateTime eventDate,
      String? location,
      String? imageUrl,
      String? venueName,
      String? venueAddress,
      String? city,
      String? state,
      bool isVirtual,
      String? virtualLink,
      int totalSlots,
      int slotsFilled,
      String whatCreatorsGet,
      List<String> targetNiche,
      List<String> targetTier,
      BrandEventStatus status,
      int invitesSent,
      int invitesAccepted,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$BrandEventImplCopyWithImpl<$Res>
    extends _$BrandEventCopyWithImpl<$Res, _$BrandEventImpl>
    implements _$$BrandEventImplCopyWith<$Res> {
  __$$BrandEventImplCopyWithImpl(
      _$BrandEventImpl _value, $Res Function(_$BrandEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrandEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? eventType = null,
    Object? eventDate = null,
    Object? location = freezed,
    Object? imageUrl = freezed,
    Object? venueName = freezed,
    Object? venueAddress = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? isVirtual = null,
    Object? virtualLink = freezed,
    Object? totalSlots = null,
    Object? slotsFilled = null,
    Object? whatCreatorsGet = null,
    Object? targetNiche = null,
    Object? targetTier = null,
    Object? status = null,
    Object? invitesSent = null,
    Object? invitesAccepted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BrandEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      venueName: freezed == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String?,
      venueAddress: freezed == venueAddress
          ? _value.venueAddress
          : venueAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      isVirtual: null == isVirtual
          ? _value.isVirtual
          : isVirtual // ignore: cast_nullable_to_non_nullable
              as bool,
      virtualLink: freezed == virtualLink
          ? _value.virtualLink
          : virtualLink // ignore: cast_nullable_to_non_nullable
              as String?,
      totalSlots: null == totalSlots
          ? _value.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      slotsFilled: null == slotsFilled
          ? _value.slotsFilled
          : slotsFilled // ignore: cast_nullable_to_non_nullable
              as int,
      whatCreatorsGet: null == whatCreatorsGet
          ? _value.whatCreatorsGet
          : whatCreatorsGet // ignore: cast_nullable_to_non_nullable
              as String,
      targetNiche: null == targetNiche
          ? _value._targetNiche
          : targetNiche // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetTier: null == targetTier
          ? _value._targetTier
          : targetTier // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BrandEventStatus,
      invitesSent: null == invitesSent
          ? _value.invitesSent
          : invitesSent // ignore: cast_nullable_to_non_nullable
              as int,
      invitesAccepted: null == invitesAccepted
          ? _value.invitesAccepted
          : invitesAccepted // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BrandEventImpl extends _BrandEvent {
  const _$BrandEventImpl(
      {required this.id,
      this.title = 'Event',
      this.description = '',
      this.eventType = 'other',
      required this.eventDate,
      this.location,
      this.imageUrl,
      this.venueName,
      this.venueAddress,
      this.city,
      this.state,
      this.isVirtual = false,
      this.virtualLink,
      this.totalSlots = 10,
      this.slotsFilled = 0,
      this.whatCreatorsGet = '',
      final List<String> targetNiche = const <String>[],
      final List<String> targetTier = const <String>[],
      this.status = BrandEventStatus.upcoming,
      this.invitesSent = 0,
      this.invitesAccepted = 0,
      this.createdAt,
      this.updatedAt})
      : _targetNiche = targetNiche,
        _targetTier = targetTier,
        super._();

  factory _$BrandEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$BrandEventImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String eventType;
  @override
  final DateTime eventDate;
  @override
  final String? location;
  @override
  final String? imageUrl;
  @override
  final String? venueName;
  @override
  final String? venueAddress;
  @override
  final String? city;
  @override
  final String? state;
  @override
  @JsonKey()
  final bool isVirtual;
  @override
  final String? virtualLink;
  @override
  @JsonKey()
  final int totalSlots;
  @override
  @JsonKey()
  final int slotsFilled;
  @override
  @JsonKey()
  final String whatCreatorsGet;
  final List<String> _targetNiche;
  @override
  @JsonKey()
  List<String> get targetNiche {
    if (_targetNiche is EqualUnmodifiableListView) return _targetNiche;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetNiche);
  }

  final List<String> _targetTier;
  @override
  @JsonKey()
  List<String> get targetTier {
    if (_targetTier is EqualUnmodifiableListView) return _targetTier;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetTier);
  }

  @override
  @JsonKey()
  final BrandEventStatus status;
  @override
  @JsonKey()
  final int invitesSent;
  @override
  @JsonKey()
  final int invitesAccepted;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BrandEvent(id: $id, title: $title, description: $description, eventType: $eventType, eventDate: $eventDate, location: $location, imageUrl: $imageUrl, venueName: $venueName, venueAddress: $venueAddress, city: $city, state: $state, isVirtual: $isVirtual, virtualLink: $virtualLink, totalSlots: $totalSlots, slotsFilled: $slotsFilled, whatCreatorsGet: $whatCreatorsGet, targetNiche: $targetNiche, targetTier: $targetTier, status: $status, invitesSent: $invitesSent, invitesAccepted: $invitesAccepted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrandEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName) &&
            (identical(other.venueAddress, venueAddress) ||
                other.venueAddress == venueAddress) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.isVirtual, isVirtual) ||
                other.isVirtual == isVirtual) &&
            (identical(other.virtualLink, virtualLink) ||
                other.virtualLink == virtualLink) &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.slotsFilled, slotsFilled) ||
                other.slotsFilled == slotsFilled) &&
            (identical(other.whatCreatorsGet, whatCreatorsGet) ||
                other.whatCreatorsGet == whatCreatorsGet) &&
            const DeepCollectionEquality()
                .equals(other._targetNiche, _targetNiche) &&
            const DeepCollectionEquality()
                .equals(other._targetTier, _targetTier) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.invitesSent, invitesSent) ||
                other.invitesSent == invitesSent) &&
            (identical(other.invitesAccepted, invitesAccepted) ||
                other.invitesAccepted == invitesAccepted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        eventType,
        eventDate,
        location,
        imageUrl,
        venueName,
        venueAddress,
        city,
        state,
        isVirtual,
        virtualLink,
        totalSlots,
        slotsFilled,
        whatCreatorsGet,
        const DeepCollectionEquality().hash(_targetNiche),
        const DeepCollectionEquality().hash(_targetTier),
        status,
        invitesSent,
        invitesAccepted,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of BrandEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrandEventImplCopyWith<_$BrandEventImpl> get copyWith =>
      __$$BrandEventImplCopyWithImpl<_$BrandEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BrandEventImplToJson(
      this,
    );
  }
}

abstract class _BrandEvent extends BrandEvent {
  const factory _BrandEvent(
      {required final String id,
      final String title,
      final String description,
      final String eventType,
      required final DateTime eventDate,
      final String? location,
      final String? imageUrl,
      final String? venueName,
      final String? venueAddress,
      final String? city,
      final String? state,
      final bool isVirtual,
      final String? virtualLink,
      final int totalSlots,
      final int slotsFilled,
      final String whatCreatorsGet,
      final List<String> targetNiche,
      final List<String> targetTier,
      final BrandEventStatus status,
      final int invitesSent,
      final int invitesAccepted,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BrandEventImpl;
  const _BrandEvent._() : super._();

  factory _BrandEvent.fromJson(Map<String, dynamic> json) =
      _$BrandEventImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get eventType;
  @override
  DateTime get eventDate;
  @override
  String? get location;
  @override
  String? get imageUrl;
  @override
  String? get venueName;
  @override
  String? get venueAddress;
  @override
  String? get city;
  @override
  String? get state;
  @override
  bool get isVirtual;
  @override
  String? get virtualLink;
  @override
  int get totalSlots;
  @override
  int get slotsFilled;
  @override
  String get whatCreatorsGet;
  @override
  List<String> get targetNiche;
  @override
  List<String> get targetTier;
  @override
  BrandEventStatus get status;
  @override
  int get invitesSent;
  @override
  int get invitesAccepted;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BrandEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrandEventImplCopyWith<_$BrandEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventInvite _$EventInviteFromJson(Map<String, dynamic> json) {
  return _EventInvite.fromJson(json);
}

/// @nodoc
mixin _$EventInvite {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  EventInviteStatus get status => throw _privateConstructorUsedError;
  String? get ticketCode => throw _privateConstructorUsedError;
  DateTime? get ticketGeneratedAt => throw _privateConstructorUsedError;
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String get creatorFirstName => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  List<String> get creatorNiches => throw _privateConstructorUsedError;
  int get creatorFollowersCount => throw _privateConstructorUsedError;
  double get creatorAvgRating => throw _privateConstructorUsedError;
  String get creatorBio => throw _privateConstructorUsedError;

  /// Serializes this EventInvite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventInviteCopyWith<EventInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventInviteCopyWith<$Res> {
  factory $EventInviteCopyWith(
          EventInvite value, $Res Function(EventInvite) then) =
      _$EventInviteCopyWithImpl<$Res, EventInvite>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      String creatorId,
      EventInviteStatus status,
      String? ticketCode,
      DateTime? ticketGeneratedAt,
      DateTime? acceptedAt,
      DateTime? createdAt,
      String creatorFirstName,
      String tier,
      List<String> creatorNiches,
      int creatorFollowersCount,
      double creatorAvgRating,
      String creatorBio});
}

/// @nodoc
class _$EventInviteCopyWithImpl<$Res, $Val extends EventInvite>
    implements $EventInviteCopyWith<$Res> {
  _$EventInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? creatorId = null,
    Object? status = null,
    Object? ticketCode = freezed,
    Object? ticketGeneratedAt = freezed,
    Object? acceptedAt = freezed,
    Object? createdAt = freezed,
    Object? creatorFirstName = null,
    Object? tier = null,
    Object? creatorNiches = null,
    Object? creatorFollowersCount = null,
    Object? creatorAvgRating = null,
    Object? creatorBio = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventInviteStatus,
      ticketCode: freezed == ticketCode
          ? _value.ticketCode
          : ticketCode // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketGeneratedAt: freezed == ticketGeneratedAt
          ? _value.ticketGeneratedAt
          : ticketGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorFirstName: null == creatorFirstName
          ? _value.creatorFirstName
          : creatorFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      creatorNiches: null == creatorNiches
          ? _value.creatorNiches
          : creatorNiches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      creatorFollowersCount: null == creatorFollowersCount
          ? _value.creatorFollowersCount
          : creatorFollowersCount // ignore: cast_nullable_to_non_nullable
              as int,
      creatorAvgRating: null == creatorAvgRating
          ? _value.creatorAvgRating
          : creatorAvgRating // ignore: cast_nullable_to_non_nullable
              as double,
      creatorBio: null == creatorBio
          ? _value.creatorBio
          : creatorBio // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventInviteImplCopyWith<$Res>
    implements $EventInviteCopyWith<$Res> {
  factory _$$EventInviteImplCopyWith(
          _$EventInviteImpl value, $Res Function(_$EventInviteImpl) then) =
      __$$EventInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      String creatorId,
      EventInviteStatus status,
      String? ticketCode,
      DateTime? ticketGeneratedAt,
      DateTime? acceptedAt,
      DateTime? createdAt,
      String creatorFirstName,
      String tier,
      List<String> creatorNiches,
      int creatorFollowersCount,
      double creatorAvgRating,
      String creatorBio});
}

/// @nodoc
class __$$EventInviteImplCopyWithImpl<$Res>
    extends _$EventInviteCopyWithImpl<$Res, _$EventInviteImpl>
    implements _$$EventInviteImplCopyWith<$Res> {
  __$$EventInviteImplCopyWithImpl(
      _$EventInviteImpl _value, $Res Function(_$EventInviteImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? creatorId = null,
    Object? status = null,
    Object? ticketCode = freezed,
    Object? ticketGeneratedAt = freezed,
    Object? acceptedAt = freezed,
    Object? createdAt = freezed,
    Object? creatorFirstName = null,
    Object? tier = null,
    Object? creatorNiches = null,
    Object? creatorFollowersCount = null,
    Object? creatorAvgRating = null,
    Object? creatorBio = null,
  }) {
    return _then(_$EventInviteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventInviteStatus,
      ticketCode: freezed == ticketCode
          ? _value.ticketCode
          : ticketCode // ignore: cast_nullable_to_non_nullable
              as String?,
      ticketGeneratedAt: freezed == ticketGeneratedAt
          ? _value.ticketGeneratedAt
          : ticketGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorFirstName: null == creatorFirstName
          ? _value.creatorFirstName
          : creatorFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      creatorNiches: null == creatorNiches
          ? _value._creatorNiches
          : creatorNiches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      creatorFollowersCount: null == creatorFollowersCount
          ? _value.creatorFollowersCount
          : creatorFollowersCount // ignore: cast_nullable_to_non_nullable
              as int,
      creatorAvgRating: null == creatorAvgRating
          ? _value.creatorAvgRating
          : creatorAvgRating // ignore: cast_nullable_to_non_nullable
              as double,
      creatorBio: null == creatorBio
          ? _value.creatorBio
          : creatorBio // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventInviteImpl extends _EventInvite {
  const _$EventInviteImpl(
      {required this.id,
      required this.eventId,
      required this.creatorId,
      this.status = EventInviteStatus.pending,
      this.ticketCode,
      this.ticketGeneratedAt,
      this.acceptedAt,
      this.createdAt,
      this.creatorFirstName = 'Creator',
      this.tier = 'micro',
      final List<String> creatorNiches = const <String>[],
      this.creatorFollowersCount = 0,
      this.creatorAvgRating = 0,
      this.creatorBio = ''})
      : _creatorNiches = creatorNiches,
        super._();

  factory _$EventInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventInviteImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String creatorId;
  @override
  @JsonKey()
  final EventInviteStatus status;
  @override
  final String? ticketCode;
  @override
  final DateTime? ticketGeneratedAt;
  @override
  final DateTime? acceptedAt;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final String creatorFirstName;
  @override
  @JsonKey()
  final String tier;
  final List<String> _creatorNiches;
  @override
  @JsonKey()
  List<String> get creatorNiches {
    if (_creatorNiches is EqualUnmodifiableListView) return _creatorNiches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_creatorNiches);
  }

  @override
  @JsonKey()
  final int creatorFollowersCount;
  @override
  @JsonKey()
  final double creatorAvgRating;
  @override
  @JsonKey()
  final String creatorBio;

  @override
  String toString() {
    return 'EventInvite(id: $id, eventId: $eventId, creatorId: $creatorId, status: $status, ticketCode: $ticketCode, ticketGeneratedAt: $ticketGeneratedAt, acceptedAt: $acceptedAt, createdAt: $createdAt, creatorFirstName: $creatorFirstName, tier: $tier, creatorNiches: $creatorNiches, creatorFollowersCount: $creatorFollowersCount, creatorAvgRating: $creatorAvgRating, creatorBio: $creatorBio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventInviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.ticketCode, ticketCode) ||
                other.ticketCode == ticketCode) &&
            (identical(other.ticketGeneratedAt, ticketGeneratedAt) ||
                other.ticketGeneratedAt == ticketGeneratedAt) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.creatorFirstName, creatorFirstName) ||
                other.creatorFirstName == creatorFirstName) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            const DeepCollectionEquality()
                .equals(other._creatorNiches, _creatorNiches) &&
            (identical(other.creatorFollowersCount, creatorFollowersCount) ||
                other.creatorFollowersCount == creatorFollowersCount) &&
            (identical(other.creatorAvgRating, creatorAvgRating) ||
                other.creatorAvgRating == creatorAvgRating) &&
            (identical(other.creatorBio, creatorBio) ||
                other.creatorBio == creatorBio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      eventId,
      creatorId,
      status,
      ticketCode,
      ticketGeneratedAt,
      acceptedAt,
      createdAt,
      creatorFirstName,
      tier,
      const DeepCollectionEquality().hash(_creatorNiches),
      creatorFollowersCount,
      creatorAvgRating,
      creatorBio);

  /// Create a copy of EventInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventInviteImplCopyWith<_$EventInviteImpl> get copyWith =>
      __$$EventInviteImplCopyWithImpl<_$EventInviteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventInviteImplToJson(
      this,
    );
  }
}

abstract class _EventInvite extends EventInvite {
  const factory _EventInvite(
      {required final String id,
      required final String eventId,
      required final String creatorId,
      final EventInviteStatus status,
      final String? ticketCode,
      final DateTime? ticketGeneratedAt,
      final DateTime? acceptedAt,
      final DateTime? createdAt,
      final String creatorFirstName,
      final String tier,
      final List<String> creatorNiches,
      final int creatorFollowersCount,
      final double creatorAvgRating,
      final String creatorBio}) = _$EventInviteImpl;
  const _EventInvite._() : super._();

  factory _EventInvite.fromJson(Map<String, dynamic> json) =
      _$EventInviteImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get creatorId;
  @override
  EventInviteStatus get status;
  @override
  String? get ticketCode;
  @override
  DateTime? get ticketGeneratedAt;
  @override
  DateTime? get acceptedAt;
  @override
  DateTime? get createdAt;
  @override
  String get creatorFirstName;
  @override
  String get tier;
  @override
  List<String> get creatorNiches;
  @override
  int get creatorFollowersCount;
  @override
  double get creatorAvgRating;
  @override
  String get creatorBio;

  /// Create a copy of EventInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventInviteImplCopyWith<_$EventInviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RazorpayOrder _$RazorpayOrderFromJson(Map<String, dynamic> json) {
  return _RazorpayOrder.fromJson(json);
}

/// @nodoc
mixin _$RazorpayOrder {
  String get orderId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  int? get credits => throw _privateConstructorUsedError;
  String? get keyId => throw _privateConstructorUsedError;

  /// Serializes this RazorpayOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RazorpayOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RazorpayOrderCopyWith<RazorpayOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RazorpayOrderCopyWith<$Res> {
  factory $RazorpayOrderCopyWith(
          RazorpayOrder value, $Res Function(RazorpayOrder) then) =
      _$RazorpayOrderCopyWithImpl<$Res, RazorpayOrder>;
  @useResult
  $Res call(
      {String orderId,
      int amount,
      String currency,
      int? credits,
      String? keyId});
}

/// @nodoc
class _$RazorpayOrderCopyWithImpl<$Res, $Val extends RazorpayOrder>
    implements $RazorpayOrderCopyWith<$Res> {
  _$RazorpayOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RazorpayOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? amount = null,
    Object? currency = null,
    Object? credits = freezed,
    Object? keyId = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      credits: freezed == credits
          ? _value.credits
          : credits // ignore: cast_nullable_to_non_nullable
              as int?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RazorpayOrderImplCopyWith<$Res>
    implements $RazorpayOrderCopyWith<$Res> {
  factory _$$RazorpayOrderImplCopyWith(
          _$RazorpayOrderImpl value, $Res Function(_$RazorpayOrderImpl) then) =
      __$$RazorpayOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String orderId,
      int amount,
      String currency,
      int? credits,
      String? keyId});
}

/// @nodoc
class __$$RazorpayOrderImplCopyWithImpl<$Res>
    extends _$RazorpayOrderCopyWithImpl<$Res, _$RazorpayOrderImpl>
    implements _$$RazorpayOrderImplCopyWith<$Res> {
  __$$RazorpayOrderImplCopyWithImpl(
      _$RazorpayOrderImpl _value, $Res Function(_$RazorpayOrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of RazorpayOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? amount = null,
    Object? currency = null,
    Object? credits = freezed,
    Object? keyId = freezed,
  }) {
    return _then(_$RazorpayOrderImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      credits: freezed == credits
          ? _value.credits
          : credits // ignore: cast_nullable_to_non_nullable
              as int?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RazorpayOrderImpl implements _RazorpayOrder {
  const _$RazorpayOrderImpl(
      {required this.orderId,
      required this.amount,
      this.currency = 'INR',
      this.credits,
      this.keyId});

  factory _$RazorpayOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$RazorpayOrderImplFromJson(json);

  @override
  final String orderId;
  @override
  final int amount;
  @override
  @JsonKey()
  final String currency;
  @override
  final int? credits;
  @override
  final String? keyId;

  @override
  String toString() {
    return 'RazorpayOrder(orderId: $orderId, amount: $amount, currency: $currency, credits: $credits, keyId: $keyId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RazorpayOrderImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.credits, credits) || other.credits == credits) &&
            (identical(other.keyId, keyId) || other.keyId == keyId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, amount, currency, credits, keyId);

  /// Create a copy of RazorpayOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RazorpayOrderImplCopyWith<_$RazorpayOrderImpl> get copyWith =>
      __$$RazorpayOrderImplCopyWithImpl<_$RazorpayOrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RazorpayOrderImplToJson(
      this,
    );
  }
}

abstract class _RazorpayOrder implements RazorpayOrder {
  const factory _RazorpayOrder(
      {required final String orderId,
      required final int amount,
      final String currency,
      final int? credits,
      final String? keyId}) = _$RazorpayOrderImpl;

  factory _RazorpayOrder.fromJson(Map<String, dynamic> json) =
      _$RazorpayOrderImpl.fromJson;

  @override
  String get orderId;
  @override
  int get amount;
  @override
  String get currency;
  @override
  int? get credits;
  @override
  String? get keyId;

  /// Create a copy of RazorpayOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RazorpayOrderImplCopyWith<_$RazorpayOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
