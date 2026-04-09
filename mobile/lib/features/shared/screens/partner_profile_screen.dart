import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/cards/bc_card.dart';

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  late Future<_PartnerProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadPartnerProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadPartnerProfile();
    });
    await _future;
  }

  Future<_PartnerProfileData> _loadPartnerProfile() async {
    final id = _readString(widget.data['id']) ??
        _readString(widget.data['partnerId']) ??
        _readString(widget.data['otherPartyId']) ??
        '';
    final role = (_readString(widget.data['role']) ?? 'creator').toLowerCase();
    final viewerRole =
        (_readString(widget.data['viewerRole']) ?? '').toLowerCase();

    if (id.isEmpty) {
      return _PartnerProfileData.placeholder(role: role, fallback: widget.data);
    }

    final supabase = Supabase.instance.client;

    final baseProfileResponse =
        await supabase.from('profiles').select('*').eq('id', id).maybeSingle();
    final baseProfile = _asMap(baseProfileResponse);

    if (role == 'brand') {
      final brandResponse = await supabase
          .from('brand_profiles')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      final brand = _asMap(brandResponse);

      return _PartnerProfileData.forBrand(
        id: id,
        fullName: _readString(baseProfile['full_name']) ??
            _readString(brand['brand_name']) ??
            _readString(widget.data['name']) ??
            'Brand',
        avatarUrl: _readString(baseProfile['avatar_url']) ??
            _readString(brand['logo_url']),
        brandName: _readString(brand['brand_name']) ??
            _readString(widget.data['name']) ??
            'Brand',
        brandCategory: _readString(brand['brand_category']) ??
            _readString(widget.data['tier']) ??
            'General',
        description: _readString(brand['description']) ??
            _readString(widget.data['bio']) ??
            '',
        website: _readString(brand['website']) ?? '',
        contactEmail: _readString(brand['contact_email']),
        size: _readString(brand['size']),
        verified: _readBool(brand['verified']) ?? false,
        totalCollabs: _readInt(brand['total_collabs']) ?? 0,
        avgRating: _readDouble(brand['avg_rating']) ?? 0,
      );
    }

    final creatorResponse = await supabase
        .from('creator_profiles')
        .select('*')
        .eq('id', id)
        .maybeSingle();

    var canViewInstagram = true;
    if (viewerRole == 'brand') {
      canViewInstagram = await _isCreatorInstagramUnlockedForBrand(
        supabase: supabase,
        creatorId: id,
      );
    }

    final creator = _asMap(creatorResponse);
    return _PartnerProfileData.forCreator(
      id: id,
      fullName: _readString(baseProfile['full_name']) ??
          _readString(baseProfile['first_name']) ??
          _readString(widget.data['name']) ??
          'Creator',
      avatarUrl: _readString(baseProfile['avatar_url']),
      tier: _readString(creator['tier']) ??
          _readString(widget.data['tier']) ??
          'Rising Creator',
      bio: _readString(creator['bio']) ?? _readString(widget.data['bio']) ?? '',
      niches: _resolveNiches(creator),
      contentTypes:
          _stringList(creator['platforms'] ?? creator['content_type']),
      followers: _readInt(creator['followers_count']) ??
          _readInt(creator['follower_count']) ??
          _readInt(widget.data['followers']) ??
          0,
      engagementRate: _readDouble(creator['engagement_rate']) ?? 0,
      avgCollabPricePaise: _readInt(creator['avg_collab_price']) ?? 0,
      startingPricePaise: _readInt(creator['starting_price']) ?? 0,
      instagramUsername: _readString(creator['instagram_username']) ??
          _readString(widget.data['instagramUsername']),
      instagramVerified: _readBool(creator['instagram_verified']) ?? false,
      canViewInstagram: canViewInstagram,
      followingCount: _readInt(creator['following_count']) ?? 0,
      postsCount: _readInt(creator['posts_count']) ?? 0,
      highestVideoViews: _readInt(creator['highest_video_views']) ?? 0,
      avgVideoViews: _readInt(creator['avg_video_views']) ?? 0,
      avgLikes: _readInt(creator['avg_likes']) ?? 0,
      avgComments: _readInt(creator['avg_comments']) ?? 0,
    );
  }

  Future<bool> _isCreatorInstagramUnlockedForBrand({
    required SupabaseClient supabase,
    required String creatorId,
  }) async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null || creatorId.isEmpty) return false;

    final collabId = _readString(widget.data['collabId']);
    if (collabId != null && collabId.isNotEmpty) {
      final collab = await supabase
          .from('collabs')
          .select('status, brand_id, creator_id')
          .eq('id', collabId)
          .maybeSingle();
      final collabMap = _asMap(collab);
      if ((collabMap['brand_id']?.toString() ?? '') == currentUserId &&
          (collabMap['creator_id']?.toString() ?? '') == creatorId) {
        return _isAcceptedCollabStatus(_readString(collabMap['status']));
      }
    }

    final rows = await supabase
        .from('collabs')
        .select('status')
        .eq('brand_id', currentUserId)
        .eq('creator_id', creatorId)
        .limit(20);

    for (final item in rows as List) {
      final map = _asMap(item);
      if (_isAcceptedCollabStatus(_readString(map['status']))) {
        return true;
      }
    }

    return false;
  }

  bool _isAcceptedCollabStatus(String? status) {
    final normalized = (status ?? '').toLowerCase();
    return normalized == 'in_progress' ||
        normalized == 'active' ||
        normalized == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    final role = (_readString(widget.data['role']) ?? 'creator').toLowerCase();

    return Scaffold(
      body: FutureBuilder<_PartnerProfileData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neon),
            );
          }

          if (snapshot.hasError) {
            return BCErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final partner = snapshot.data ??
              _PartnerProfileData.placeholder(
                  role: role, fallback: widget.data);

          return RefreshIndicator(
            color: AppColors.neon,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.white,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    partner.isCreator ? 'Creator Profile' : 'Brand Profile',
                    style: AppTypography.displaySM
                        .copyWith(color: AppColors.white),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl * 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: partner.isCreator
                                      ? AppColors.neon
                                      : AppColors.pink,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: (partner.avatarUrl ?? '').trim().isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        partner.avatarUrl!,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(
                                          _initials(partner.displayName),
                                          style: AppTypography.labelLG
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _initials(partner.displayName),
                                      style: AppTypography.labelLG
                                          .copyWith(color: AppColors.white),
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              partner.displayName,
                              style: AppTypography.labelLG
                                  .copyWith(color: AppColors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            BCBadge(
                              label: partner.badgeLabel,
                              variant: partner.isCreator
                                  ? BCBadgeVariant.neon
                                  : BCBadgeVariant.pink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                      AppSpacing.screenPadding,
                      AppSpacing.huge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(partner),
                        const SizedBox(height: AppSpacing.xl),
                        if (partner.isCreator)
                          _CreatorProfileSection(partner: partner)
                        else
                          _BrandProfileSection(partner: partner),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _initials(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z ]'), '').trim();
    if (cleaned.isEmpty) return 'U';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _buildStatRow(_PartnerProfileData partner) {
    if (partner.isCreator) {
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Followers',
              value: Formatters.followerCount(partner.followers),
              shadow: AppShadows.neon,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'Engagement',
              value: '${partner.engagementRate.toStringAsFixed(1)}%',
              shadow: AppShadows.blue,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'Start Price',
              value: Formatters.currency(partner.startingPricePaise),
              shadow: AppShadows.pink,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Collabs',
            value: '${partner.totalCollabs}',
            shadow: AppShadows.pink,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Avg Rating',
            value: '${partner.avgRating.toStringAsFixed(1)} ★',
            shadow: AppShadows.blue,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Category',
            value: partner.brandCategory,
            shadow: AppShadows.neon,
          ),
        ),
      ],
    );
  }
}

class _CreatorProfileSection extends StatelessWidget {
  const _CreatorProfileSection({required this.partner});

  final _PartnerProfileData partner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BCCard(
          shadow: AppShadows.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('About', style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              Text(
                partner.bio.trim().isEmpty
                    ? 'No creator bio added yet.'
                    : partner.bio,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(label: 'Tier', value: partner.tier),
              _InstagramInfoRow(partner: partner),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCCard(
          shadow: AppShadows.neon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Niches', style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              if (partner.niches.isEmpty)
                Text(
                  'No niche details available.',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: partner.niches
                      .map((niche) => _PillTag(label: niche))
                      .toList(),
                ),
              const SizedBox(height: AppSpacing.md),
              const Text('Content Types', style: AppTypography.labelMD),
              const SizedBox(height: AppSpacing.sm),
              if (partner.contentTypes.isEmpty)
                Text(
                  'No content type details available.',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: partner.contentTypes
                      .map((type) => _PillTag(label: type))
                      .toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCCard(
          shadow: AppShadows.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Performance Snapshot',
                  style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(
                label: 'Following',
                value: Formatters.followerCount(partner.followingCount),
              ),
              _InfoRow(
                label: 'Posts',
                value: '${partner.postsCount}',
              ),
              _InfoRow(
                label: 'Highest Video Views',
                value: Formatters.followerCount(partner.highestVideoViews),
              ),
              _InfoRow(
                label: 'Avg Video Views',
                value: Formatters.followerCount(partner.avgVideoViews),
              ),
              _InfoRow(
                label: 'Avg Likes',
                value: Formatters.followerCount(partner.avgLikes),
              ),
              _InfoRow(
                label: 'Avg Comments',
                value: Formatters.followerCount(partner.avgComments),
              ),
              _InfoRow(
                label: 'Avg Collab Price',
                value: Formatters.currency(partner.avgCollabPricePaise),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstagramInfoRow extends StatelessWidget {
  const _InstagramInfoRow({required this.partner});

  final _PartnerProfileData partner;

  @override
  Widget build(BuildContext context) {
    final hasHandle = partner.instagramUsername?.trim().isNotEmpty == true;
    final value = hasHandle ? '@${partner.instagramUsername}' : 'Not connected';
    final locked = hasHandle && !partner.canViewInstagram;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              'Instagram',
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (locked)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3.2, sigmaY: 3.2),
                    child: Text(value, style: AppTypography.labelSM),
                  )
                else
                  Text(value, style: AppTypography.labelSM),
                if (locked)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'Unlocks once bid/collab is accepted',
                      style:
                          AppTypography.bodyXS.copyWith(color: AppColors.muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandProfileSection extends StatelessWidget {
  const _BrandProfileSection({required this.partner});

  final _PartnerProfileData partner;

  Future<void> _openWebsite(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BCCard(
          shadow: AppShadows.pink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(partner.brandName, style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  BCBadge(
                    label: partner.brandCategory,
                    variant: BCBadgeVariant.pink,
                  ),
                  BCBadge(
                    label: partner.verified ? 'Verified' : 'Unverified',
                    variant: partner.verified
                        ? BCBadgeVariant.success
                        : BCBadgeVariant.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                partner.description.trim().isEmpty
                    ? 'No brand description added yet.'
                    : partner.description,
                style: AppTypography.bodySM.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BCCard(
          shadow: AppShadows.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Business Details', style: AppTypography.displaySM),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(label: 'Brand Size', value: partner.size ?? 'Not set'),
              _InfoRow(
                label: 'Contact Email',
                value: partner.contactEmail ?? 'Not set',
              ),
              _InfoRow(
                label: 'Website',
                value: partner.website.trim().isEmpty
                    ? 'Not set'
                    : partner.website,
              ),
              if (partner.website.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _openWebsite(partner.website),
                  style: TextButton.styleFrom(foregroundColor: AppColors.blue),
                  child: const Text('Open Website →'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.shadow,
  });

  final String label;
  final String value;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: shadow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.labelMD,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodyXS,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.labelSM,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Text(label, style: AppTypography.labelXS),
    );
  }
}

class _PartnerProfileData {
  const _PartnerProfileData({
    required this.id,
    required this.role,
    required this.displayName,
    this.avatarUrl,
    this.tier = 'Rising Creator',
    this.bio = '',
    this.niches = const <String>[],
    this.contentTypes = const <String>[],
    this.followers = 0,
    this.engagementRate = 0,
    this.avgCollabPricePaise = 0,
    this.startingPricePaise = 0,
    this.instagramUsername,
    this.instagramVerified = false,
    this.canViewInstagram = true,
    this.followingCount = 0,
    this.postsCount = 0,
    this.highestVideoViews = 0,
    this.avgVideoViews = 0,
    this.avgLikes = 0,
    this.avgComments = 0,
    this.brandName = 'Brand',
    this.brandCategory = 'General',
    this.description = '',
    this.website = '',
    this.contactEmail,
    this.size,
    this.verified = false,
    this.totalCollabs = 0,
    this.avgRating = 0,
  });

  final String id;
  final String role;
  final String displayName;
  final String? avatarUrl;

  final String tier;
  final String bio;
  final List<String> niches;
  final List<String> contentTypes;
  final int followers;
  final double engagementRate;
  final int avgCollabPricePaise;
  final int startingPricePaise;
  final String? instagramUsername;
  final bool instagramVerified;
  final bool canViewInstagram;
  final int followingCount;
  final int postsCount;
  final int highestVideoViews;
  final int avgVideoViews;
  final int avgLikes;
  final int avgComments;

  final String brandName;
  final String brandCategory;
  final String description;
  final String website;
  final String? contactEmail;
  final String? size;
  final bool verified;
  final int totalCollabs;
  final double avgRating;

  bool get isCreator => role == 'creator';

  String get badgeLabel {
    if (isCreator) {
      return instagramVerified ? 'Creator • Verified' : 'Creator • $tier';
    }
    return verified ? 'Brand • Verified' : 'Brand';
  }

  factory _PartnerProfileData.forCreator({
    required String id,
    required String fullName,
    String? avatarUrl,
    required String tier,
    required String bio,
    required List<String> niches,
    required List<String> contentTypes,
    required int followers,
    required double engagementRate,
    required int avgCollabPricePaise,
    required int startingPricePaise,
    String? instagramUsername,
    required bool instagramVerified,
    required bool canViewInstagram,
    required int followingCount,
    required int postsCount,
    required int highestVideoViews,
    required int avgVideoViews,
    required int avgLikes,
    required int avgComments,
  }) {
    return _PartnerProfileData(
      id: id,
      role: 'creator',
      displayName: fullName,
      avatarUrl: avatarUrl,
      tier: tier,
      bio: bio,
      niches: niches,
      contentTypes: contentTypes,
      followers: followers,
      engagementRate: engagementRate,
      avgCollabPricePaise: avgCollabPricePaise,
      startingPricePaise: startingPricePaise,
      instagramUsername: instagramUsername,
      instagramVerified: instagramVerified,
      canViewInstagram: canViewInstagram,
      followingCount: followingCount,
      postsCount: postsCount,
      highestVideoViews: highestVideoViews,
      avgVideoViews: avgVideoViews,
      avgLikes: avgLikes,
      avgComments: avgComments,
    );
  }

  factory _PartnerProfileData.forBrand({
    required String id,
    required String fullName,
    String? avatarUrl,
    required String brandName,
    required String brandCategory,
    required String description,
    required String website,
    String? contactEmail,
    String? size,
    required bool verified,
    required int totalCollabs,
    required double avgRating,
  }) {
    return _PartnerProfileData(
      id: id,
      role: 'brand',
      displayName: fullName,
      avatarUrl: avatarUrl,
      brandName: brandName,
      brandCategory: brandCategory,
      description: description,
      website: website,
      contactEmail: contactEmail,
      size: size,
      verified: verified,
      totalCollabs: totalCollabs,
      avgRating: avgRating,
    );
  }

  factory _PartnerProfileData.placeholder({
    required String role,
    required Map<String, dynamic> fallback,
  }) {
    final normalizedRole = role.toLowerCase() == 'brand' ? 'brand' : 'creator';
    return _PartnerProfileData(
      id: '',
      role: normalizedRole,
      displayName: _readString(fallback['name']) ??
          (normalizedRole == 'creator' ? 'Creator' : 'Brand'),
      tier: _readString(fallback['tier']) ?? 'N/A',
      bio: _readString(fallback['bio']) ?? '',
      followers: _readInt(fallback['followers']) ?? 0,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  final single = _readString(value);
  if (single == null) return const <String>[];
  return single
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _resolveNiches(Map<String, dynamic> creator) {
  final niches = _stringList(creator['niches']);
  if (niches.isNotEmpty) return niches;
  return _stringList(creator['niche']);
}
