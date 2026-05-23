import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/brand_page_top_header.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_location_picker.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../../shared/widgets/profile_posts_tab.dart';

final _completedCollabsProvider = FutureProvider<List<ActiveCollabSummary>>(
  (ref) => ref.read(brandRepositoryProvider).getCompletedCollabs(),
);

class BrandProfileScreen extends ConsumerStatefulWidget {
  const BrandProfileScreen({super.key});

  @override
  ConsumerState<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends ConsumerState<BrandProfileScreen> {
  String? _avatarUrl;
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    Future<void>.microtask(() async {
      await ref.read(brandProvider.notifier).fetchBrandHome();
      ref.read(brandProfileProvider);
      ref.read(brandRequestsProvider);
      ref.read(creditsProvider);
      await _loadAvatarUrl();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(brandProvider.notifier).fetchBrandHome(),
      ref.read(brandProfileProvider.notifier).refresh(),
      ref.read(creditsProvider.notifier).refresh(),
      ref.refresh(_completedCollabsProvider.future),
      _loadAvatarUrl(),
    ]);
  }

  Future<void> _loadAvatarUrl() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final row = await Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    if (!mounted) return;
    final fetched = (row?['avatar_url'] as String?)?.trim();
    if (fetched != null && fetched.isNotEmpty) {
      setState(() => _avatarUrl = fetched);
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  Future<String> _uploadAvatar(Uint8List bytes, String fileName) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final ext =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final version = DateTime.now().millisecondsSinceEpoch;
    final path = 'brands/$userId-$version.$ext';
    await Supabase.instance.client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
  }

  Future<String?> _pickAndUploadLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return _uploadAvatar(await picked.readAsBytes(), picked.name);
  }

  Future<void> _openVerifySheet(BrandProfile profile) async {
    final gstController = TextEditingController();
    final websiteController = TextEditingController(text: profile.website);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.52,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, controller) {
            return _SheetShell(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  const Text('Verify Brand', style: AppTypography.displaySM),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                      label: 'GST Number',
                      hint: '27ABCDE1234F1Z5',
                      controller: gstController),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                      label: 'Website',
                      hint: 'https://yourbrand.com',
                      controller: websiteController),
                  const SizedBox(height: AppSpacing.xl),
                  BCPrimaryButton.dark(
                    label: 'Submit',
                    onPressed: () async {
                      await ref
                          .read(brandProfileProvider.notifier)
                          .updateProfile({
                        'gst_number': gstController.text.trim(),
                        'website': websiteController.text.trim(),
                      });
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openEditSheet(BrandProfile profile) async {
    final brandNameController = TextEditingController(text: profile.brandName);
    final websiteController = TextEditingController(text: profile.website);
    final descriptionController =
        TextEditingController(text: profile.description);
    String category = profile.brandCategory;
    String? selectedState = profile.state;
    String? selectedCity = profile.city;
    String? avatarUrl = _avatarUrl ?? profile.avatarUrl ?? profile.logoUrl;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, controller) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return _ModernSheetShell(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Edit Profile',
                                style: AppTypography.displaySM),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.lightBg,
                              minimumSize: const Size(36, 36),
                            ),
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.brandDark, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                          label: 'Brand Name', controller: brandNameController),
                      const SizedBox(height: AppSpacing.lg),
                      BCDropdown(
                        label: 'Category',
                        value: category,
                        items: const [
                          'Fashion',
                          'Beauty',
                          'Food',
                          'Tech',
                          'Fitness',
                          'Lifestyle',
                          'General'
                        ],
                        onChanged: (value) =>
                            setSheetState(() => category = value ?? category),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                          label: 'Website', controller: websiteController),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                          label: 'Description',
                          maxLines: 4,
                          controller: descriptionController),
                      const SizedBox(height: AppSpacing.lg),
                      BCLocationPicker(
                        initialState: selectedState,
                        initialCity: selectedCity,
                        onChanged: (state, city) {
                          selectedState = state;
                          selectedCity = city;
                        },
                        required: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SheetActionButton(
                        label: 'Upload Logo',
                        onPressed: () async {
                          final url = await _pickAndUploadLogo();
                          if (url != null) setSheetState(() => avatarUrl = url);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _SheetActionButton(
                              label: 'Cancel',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _SheetActionButton(
                              label: 'Save',
                              onPressed: () async {
                                await ref
                                    .read(brandProfileProvider.notifier)
                                    .updateProfile({
                                  'brand_name': brandNameController.text.trim(),
                                  'brand_category': category,
                                  'website': websiteController.text.trim(),
                                  'description':
                                      descriptionController.text.trim(),
                                  'state': selectedState,
                                  'city': selectedCity,
                                  if ((avatarUrl ?? '').isNotEmpty) ...{
                                    'logo_url': avatarUrl,
                                    'avatar_url': avatarUrl,
                                  },
                                });
                                if (mounted) {
                                  setState(() => _avatarUrl = avatarUrl);
                                }
                                await _refresh();
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<XFile?> _pickProfileMediaFile() async {
    return showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SheetShell(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upload Post', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.md),
                BCPrimaryButton.dark(
                  label: 'Choose Photo',
                  onPressed: () async {
                    final file = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop(file);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                BCPrimaryButton.neon(
                  label: 'Choose Video',
                  onPressed: () async {
                    final file = await ImagePicker()
                        .pickVideo(source: ImageSource.gallery);
                    if (!sheetContext.mounted) return;
                    Navigator.of(sheetContext).pop(file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadProfilePost(BrandProfile profile) async {
    final picked = await _pickProfileMediaFile();
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final url = await _uploadAvatar(bytes, picked.name);
    final next = [...profile.portfolioLinks, url];
    await ref
        .read(brandProfileProvider.notifier)
        .updateProfile({'portfolio_links': next});
    await _refresh();
  }

  Future<void> _deleteProfilePost(BrandProfile profile, String url) async {
    final next = profile.portfolioLinks.where((item) => item != url).toList();
    await ref
        .read(brandProfileProvider.notifier)
        .updateProfile({'portfolio_links': next});
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(brandProfileProvider);
    final brandState = ref.watch(brandProvider);
    final creditsAsync = ref.watch(creditsProvider);
    final completedCollabsAsync = ref.watch(_completedCollabsProvider);
    final profile = profileAsync.valueOrNull ?? brandState.brandProfile;

    if (profileAsync.isLoading && profile == null) {
      return const Scaffold(body: _ProfileShimmer());
    }
    if (profileAsync.hasError && profile == null) {
      return Scaffold(
          body: BCErrorState(
              message: profileAsync.error.toString(), onRetry: _refresh));
    }
    if (profile == null) {
      return const Scaffold(
          body: Center(child: Text('Unable to load brand profile.')));
    }

    final credits =
        creditsAsync.valueOrNull?.balance ?? brandState.creditBalance;
    final completedCampaigns = brandState.campaigns
        .where((c) => c.status == CampaignStatus.completed)
        .toList();
    final completedCollabs =
        completedCollabsAsync.valueOrNull ?? const <ActiveCollabSummary>[];
    final logo =
        (_avatarUrl ?? profile.avatarUrl ?? profile.logoUrl ?? '').trim();
    final location = (profile.city ?? '').trim().isNotEmpty
        ? '${profile.city}, ${profile.state ?? ''}'
        : ((profile.state ?? '').trim().isEmpty
            ? 'Location not set'
            : profile.state!);

    final topInset = MediaQuery.of(context).padding.top + 14;
    const headerHeight = 48.0;
    const headerGap = 34.0;
    final sheetTop = topInset + headerHeight + headerGap;
    final headerSlide = _scrollOffset.clamp(0.0, sheetTop);
    final collapseProgress =
        (headerSlide / (headerHeight + headerGap)).clamp(0.0, 1.0);
    final collapsedTop = MediaQuery.of(context).padding.top + 8;
    final headerTop = lerpDouble(topInset, collapsedTop, collapseProgress)!;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar:
          const BCBottomNav(role: BCPortalRole.brand, currentIndex: 3),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 3,
        child: DefaultTabController(
          length: 2,
          child: Stack(
            children: [
              const Positioned.fill(
                  child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.lightBg))),
              Positioned(
                  top: -46,
                  right: -32,
                  child: _GlowOrb(
                      size: 136,
                      color: AppColors.brandPrimary.withValues(alpha: 0.08))),
              Positioned(
                  top: 220,
                  left: -44,
                  child: _GlowOrb(
                      size: 112,
                      color: AppColors.brandDark.withValues(alpha: 0.08))),
              Column(
                children: [
                  SizedBox(height: sheetTop + AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                    ),
                    child: BCCard(
                      shadow: const <BoxShadow>[],
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.brandDark
                                          .withValues(alpha: 0.14)),
                                ),
                                child: logo.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(logo,
                                            fit: BoxFit.cover))
                                    : Center(
                                        child: Text(profile.logoInitial,
                                            style: AppTypography.labelLG)),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.brandName,
                                      style: AppTypography.displaySM.copyWith(
                                        color: AppColors.brandDark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(location,
                                        style: AppTypography.bodyXS
                                            .copyWith(color: AppColors.muted)),
                                    const SizedBox(height: AppSpacing.sm),
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      children: [
                                        BCBadge(
                                            label: profile.brandCategory,
                                            variant: BCBadgeVariant.neon),
                                        if (profile.verified)
                                          const BCBadge(
                                              label: 'Verified',
                                              variant: BCBadgeVariant.success),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _openEditSheet(profile),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF6F8F2),
                                  minimumSize: const Size(40, 40),
                                ),
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.brandDark,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _StatPill(
                                  label: 'Collabs',
                                  value: '${profile.totalCollabs}'),
                              _StatPill(
                                  label: 'Campaigns',
                                  value: '${brandState.activeCampaignCount}'),
                              _StatPill(
                                  label: 'Rating',
                                  value: profile.avgRating.toStringAsFixed(1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: EdgeInsets.all(4),
                        indicator: BoxDecoration(
                          color: AppColors.brandDark,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        labelColor: AppColors.white,
                        unselectedLabelColor: AppColors.brandDark,
                        tabs: [Tab(text: 'Details'), Tab(text: 'Posts')],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: TabBarView(
                      children: [
                        RefreshIndicator(
                          color: AppColors.brandPrimary,
                          onRefresh: _refresh,
                          child: ListView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.screenPadding,
                              AppSpacing.sm,
                              AppSpacing.screenPadding,
                              MediaQuery.of(context).padding.bottom + 104,
                            ),
                            children: [
                              BCCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const _CircleIconChip(
                                            icon:
                                                Icons.business_center_rounded),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          'About',
                                          style: AppTypography.labelLG.copyWith(
                                            color: AppColors.brandDark,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      profile.description.trim().isEmpty
                                          ? 'No description added yet.'
                                          : profile.description,
                                      style: AppTypography.bodySM
                                          .copyWith(color: AppColors.muted),
                                    ),
                                    if (profile.website.trim().isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.sm),
                                      GestureDetector(
                                        onTap: () async {
                                          final uri = Uri.tryParse(
                                              profile.website.trim());
                                          if (uri != null) await launchUrl(uri);
                                        },
                                        child: Text(
                                          profile.website,
                                          style: AppTypography.labelSM
                                              .copyWith(color: AppColors.blue),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              BCCard(
                                onTap: () =>
                                    context.push(RouteNames.brandCredits),
                                child: Row(
                                  children: [
                                    const _CircleIconChip(
                                        icon: Icons
                                            .account_balance_wallet_rounded),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Credits',
                                      style: AppTypography.labelMD.copyWith(
                                        color: AppColors.brandDark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$credits',
                                      style: AppTypography.displaySM.copyWith(
                                        color: AppColors.brandDark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (!profile.verified)
                                BCCard(
                                  backgroundColor: const Color(0xFFFFFBEA),
                                  child: BCPrimaryButton.dark(
                                    label: 'Verify brand',
                                    isFullWidth: false,
                                    onPressed: () => _openVerifySheet(profile),
                                  ),
                                ),
                              if (completedCampaigns.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Past Campaigns',
                                  style: AppTypography.displaySM.copyWith(
                                    color: AppColors.brandDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                ...completedCampaigns.take(3).map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.sm),
                                        child: BCCard(
                                          child: Row(
                                            children: [
                                              const _CircleIconChip(
                                                  icon: Icons.campaign_rounded),
                                              const SizedBox(
                                                  width: AppSpacing.sm),
                                              Expanded(
                                                child: Text(item.title,
                                                    style:
                                                        AppTypography.labelMD),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              ] else
                                const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                height: completedCampaigns.isEmpty
                                    ? AppSpacing.xl
                                    : AppSpacing.lg,
                              ),
                              Text(
                                'Completed Collabs',
                                style: AppTypography.displaySM.copyWith(
                                  color: AppColors.brandDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              if (completedCollabsAsync.isLoading)
                                const _InlineShimmerList()
                              else if (completedCollabs.isEmpty)
                                const Text('No completed collabs yet.',
                                    style: AppTypography.bodySM)
                              else
                                ...completedCollabs.take(3).map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.sm),
                                        child: _CompletedCollabTile(item: item),
                                      ),
                                    ),
                              const SizedBox(height: AppSpacing.md),
                              _ProfileActionButton(
                                label: 'Settings',
                                icon: Icons.settings_rounded,
                                onPressed: () =>
                                    context.push(RouteNames.settings),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _ProfileActionButton(
                                label: 'Logout',
                                icon: Icons.logout_rounded,
                                onPressed: _logout,
                                backgroundColor: AppColors.error,
                              ),
                            ],
                          ),
                        ),
                        ProfilePostsTab(
                          mediaUrls: profile.portfolioLinks,
                          canManage: true,
                          emptyTitle:
                              'Upload photos or videos to showcase your brand work.',
                          onUpload: () => _uploadProfilePost(profile),
                          onDelete: (url) => _deleteProfilePost(profile, url),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: collapsedTop + 48 + 16,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightBg
                          .withValues(alpha: collapseProgress * 0.95),
                      border: collapseProgress > 0.5
                          ? const Border(
                              bottom: BorderSide(color: AppColors.lightBorder))
                          : null,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: headerTop,
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                child: BrandPageTopHeader(collapseProgress: collapseProgress),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconChip extends StatelessWidget {
  const _CircleIconChip({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8F2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.brandDark, size: 20),
    );
  }
}

class _CompletedCollabTile extends StatelessWidget {
  const _CompletedCollabTile({required this.item});

  final ActiveCollabSummary item;

  @override
  Widget build(BuildContext context) {
    final initial = item.creatorName.isEmpty
        ? 'C'
        : item.creatorName.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.brandDark,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTypography.labelMD.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.creatorName, style: AppTypography.labelMD),
                const SizedBox(height: 2),
                Text(
                  item.campaignTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const BCBadge(label: 'Completed', variant: BCBadgeVariant.neon),
              const SizedBox(height: 4),
              Text(
                'Completed',
                style:
                    AppTypography.bodyXS.copyWith(color: AppColors.brandDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.labelSM.copyWith(
              color: AppColors.brandDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.brandDark.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}

class _ModernSheetShell extends StatelessWidget {
  const _ModernSheetShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: child,
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelSM.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.brandDark,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.white, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelSM.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.55,
              spreadRadius: size * 0.04,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Container(height: 210, color: AppColors.white),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 90, color: AppColors.white),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 180, color: AppColors.white),
        ],
      ),
    );
  }
}

class _InlineShimmerList extends StatelessWidget {
  const _InlineShimmerList();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
