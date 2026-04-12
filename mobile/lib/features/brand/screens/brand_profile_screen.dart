import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_location_picker.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../../shared/widgets/profile_posts_tab.dart';

final _completedCollabsProvider =
    FutureProvider<List<ActiveCollabSummary>>((ref) {
  return ref.read(brandRepositoryProvider).getCompletedCollabs();
});

class BrandProfileScreen extends ConsumerStatefulWidget {
  const BrandProfileScreen({super.key});

  @override
  ConsumerState<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends ConsumerState<BrandProfileScreen> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(brandProvider.notifier).fetchBrandHome();
      ref.read(brandRequestsProvider);
      ref.read(brandProfileProvider);
      ref.read(creditsProvider);
      _loadAvatarUrl();
    });
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
    setState(() {
      if (fetched != null && fetched.isNotEmpty) {
        _avatarUrl = fetched;
      }
    });
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
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
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLG),
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  const Text('Verify Your Brand',
                      style: AppTypography.displaySM),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                    label: 'GST Number',
                    hint: '27ABCDE1234F1Z5',
                    controller: gstController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCTextField(
                    label: 'Website URL',
                    hint: 'https://yourbrand.com',
                    controller: websiteController,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BCPrimaryButton.pink(
                    label: 'Submit for Verification →',
                    onPressed: () async {
                      try {
                        await ref
                            .read(brandProfileProvider.notifier)
                            .updateProfile({
                          'gst_number': gstController.text.trim(),
                          'website': websiteController.text.trim(),
                        });
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Submitted! We'll verify within 24 hours.",
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
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

  Future<String?> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    return _uploadAvatarToStorage(bytes, picked.name);
  }

  Future<String> _uploadAvatarToStorage(
      Uint8List bytes, String fileName) async {
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
          initialChildSize: 0.75,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, controller) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusLG),
                    ),
                    border: const Border(
                      top: BorderSide(color: AppColors.ink, width: 2),
                    ),
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      const Text('Edit Brand Profile',
                          style: AppTypography.displaySM),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Brand Name',
                        controller: brandNameController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCDropdown(
                        label: 'Brand Category',
                        value: category,
                        items: const [
                          'Fashion',
                          'Beauty',
                          'Food',
                          'Tech',
                          'Fitness',
                          'Lifestyle',
                          'General',
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            category = value ?? category;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Website',
                        hint: 'https://yourbrand.com',
                        controller: websiteController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Description',
                        maxLines: 4,
                        controller: descriptionController,
                      ),
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
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.pink,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: (avatarUrl ?? '').trim().isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    avatarUrl!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      profile.logoInitial,
                                      style: AppTypography.labelMD.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  profile.logoInitial,
                                  style: AppTypography.labelMD.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BCPrimaryButton.dark(
                        label: 'Upload Profile Photo',
                        isFullWidth: false,
                        onPressed: () async {
                          try {
                            final url = await _pickAndUploadLogo();
                            if (url != null) {
                              setSheetState(() {
                                avatarUrl = url;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Photo uploaded successfully.'),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Upload failed: $e')),
                            );
                          }
                        },
                      ),
                      if ((avatarUrl ?? '').isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Photo uploaded',
                          style: AppTypography.bodySM
                              .copyWith(color: AppColors.success),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      BCPrimaryButton.pink(
                        label: 'Save Changes →',
                        onPressed: () async {
                          try {
                            await ref
                                .read(brandProfileProvider.notifier)
                                .updateProfile({
                              'brand_name': brandNameController.text.trim(),
                              'brand_category': category,
                              'website': websiteController.text.trim(),
                              'description': descriptionController.text.trim(),
                              'state': selectedState,
                              'city': selectedCity,
                              if ((avatarUrl ?? '').isNotEmpty) ...{
                                'logo_url': avatarUrl,
                                'avatar_url': avatarUrl,
                              },
                            });
                            if (mounted) {
                              setState(() {
                                _avatarUrl = avatarUrl;
                              });
                            }
                            await _refresh();
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
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
    final picker = ImagePicker();

    return showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLG),
            ),
            border: const Border(
              top: BorderSide(color: AppColors.ink, width: 2),
            ),
          ),
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
                  final file =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop(file);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              BCPrimaryButton.neon(
                label: 'Choose Video',
                onPressed: () async {
                  final file =
                      await picker.pickVideo(source: ImageSource.gallery);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isVideoFileName(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  bool _isVideoFile(XFile file) {
    final mime = (file.mimeType ?? '').toLowerCase();
    if (mime.startsWith('video/')) return true;
    return _isVideoFileName(file.name) || _isVideoFileName(file.path);
  }

  String _resolveExtension(XFile file, bool isVideo) {
    String source = file.name;
    if (!source.contains('.') && file.path.contains('.')) {
      source = file.path.split('/').last.split('\\').last;
    }

    if (source.contains('.')) {
      final ext = source.split('.').last.toLowerCase();
      if (ext.isNotEmpty) return ext;
    }

    return isVideo ? 'mp4' : 'jpg';
  }

  String _resolveContentType(String ext, bool isVideo) {
    final normalized = ext.toLowerCase();
    if (isVideo) {
      switch (normalized) {
        case 'mov':
          return 'video/quicktime';
        case 'm4v':
        case 'mp4':
          return 'video/mp4';
        case 'webm':
          return 'video/webm';
        case 'avi':
          return 'video/x-msvideo';
        case 'mkv':
          return 'video/x-matroska';
        default:
          return 'video/mp4';
      }
    }

    switch (normalized) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<String> _uploadProfileMediaToStorage(XFile file) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final isVideo = _isVideoFile(file);
    final ext = _resolveExtension(file, isVideo);
    final now = DateTime.now().millisecondsSinceEpoch;
    final path = 'brands/$userId-post-$now.$ext';
    final bytes = await file.readAsBytes();

    await Supabase.instance.client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _resolveContentType(ext, isVideo),
          ),
        );

    return Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> _uploadProfilePost(BrandProfile profile) async {
    if (profile.portfolioLinks.length >= 6) return;

    final selected = await _pickProfileMediaFile();
    if (selected == null) return;

    try {
      final url = await _uploadProfileMediaToStorage(selected);
      final next = [...profile.portfolioLinks, url];

      await ref
          .read(brandProfileProvider.notifier)
          .updateProfile({'portfolio_links': next});
      await _refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media uploaded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload media: $e')),
      );
    }
  }

  Future<void> _deleteProfilePost(BrandProfile profile, String url) async {
    try {
      final next = profile.portfolioLinks.where((item) => item != url).toList();
      await ref
          .read(brandProfileProvider.notifier)
          .updateProfile({'portfolio_links': next});
      await _refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete media: $e')),
      );
    }
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
          message: profileAsync.error.toString(),
          onRetry: _refresh,
        ),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to load brand profile.')),
      );
    }

    final credits =
        creditsAsync.valueOrNull?.balance ?? brandState.creditBalance;
    final completedCampaigns = brandState.campaigns
        .where((item) => item.status == CampaignStatus.completed)
        .toList();

    final completedCollabs = completedCollabsAsync.valueOrNull ?? const [];

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.brand,
        currentIndex: 3,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.brand,
        currentIndex: 3,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: AppColors.ink,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Align(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.pink, width: 3),
                              ),
                              alignment: Alignment.center,
                              child: ((_avatarUrl ??
                                          profile.avatarUrl ??
                                          profile.logoUrl ??
                                          ''))
                                      .trim()
                                      .isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        (_avatarUrl ??
                                            profile.avatarUrl ??
                                            profile.logoUrl)!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(
                                          profile.logoInitial,
                                          style: AppTypography.labelLG
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      profile.logoInitial,
                                      style: AppTypography.labelLG
                                          .copyWith(color: AppColors.white),
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              profile.brandName,
                              style: AppTypography.labelLG
                                  .copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: AppSpacing.sm,
                              children: [
                                BCBadge(
                                  label: profile.brandCategory,
                                  variant: BCBadgeVariant.pink,
                                ),
                                if (profile.verified)
                                  const BCBadge(
                                    label: '✅ Verified',
                                    variant: BCBadgeVariant.success,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: () => _openEditSheet(profile),
                          icon: const Icon(Symbols.edit_rounded,
                              color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.sm,
                ),
                child: TabBar(
                  indicatorColor: AppColors.pink,
                  labelColor: AppColors.ink,
                  unselectedLabelColor: AppColors.muted,
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Posts'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    RefreshIndicator(
                      color: AppColors.neon,
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenPadding,
                          AppSpacing.lg,
                          AppSpacing.screenPadding,
                          AppSpacing.huge + AppSpacing.xxxl,
                        ),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Total Collabs',
                                  value: '${profile.totalCollabs}',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _StatCard(
                                  label: 'Active Campaigns',
                                  value: '${brandState.activeCampaignCount}',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _StatCard(
                                  label: 'Avg Rating',
                                  value:
                                      '${profile.avgRating.toStringAsFixed(1)} ★',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          BCCard(
                            shadow: AppShadows.pink,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(profile.brandName,
                                    style: AppTypography.displaySM),
                                const SizedBox(height: AppSpacing.sm),
                                BCBadge(
                                  label: profile.brandCategory,
                                  variant: BCBadgeVariant.pink,
                                ),
                                if ((profile.state ?? '').trim().isNotEmpty ||
                                    (profile.city ?? '').trim().isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      const Icon(
                                        Symbols.location_on_rounded,
                                        size: 14,
                                        color: AppColors.muted,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          (profile.city ?? '').trim().isNotEmpty
                                              ? '${profile.city}, ${profile.state ?? ''}'
                                              : (profile.state ?? ''),
                                          style: AppTypography.bodyXS
                                              .copyWith(color: AppColors.muted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (profile.website.trim().isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  GestureDetector(
                                    onTap: () async {
                                      final uri =
                                          Uri.tryParse(profile.website.trim());
                                      if (uri != null) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    child: Text(
                                      profile.website,
                                      style: AppTypography.labelSM
                                          .copyWith(color: AppColors.blue),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  profile.description.trim().isEmpty
                                      ? 'No description added yet.'
                                      : profile.description,
                                  style: AppTypography.bodySM
                                      .copyWith(color: AppColors.muted),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _openEditSheet(profile),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.pink,
                                    ),
                                    child: const Text('Edit →'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (!profile.verified)
                            BCCard(
                              backgroundColor: const Color(0xFFFFF3CC),
                              shadow: AppShadows.orange,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '⚠️ Your brand is not verified',
                                    style: AppTypography.labelMD,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Upload GST number to get a verified badge and build creator trust.',
                                    style: AppTypography.bodySM
                                        .copyWith(color: AppColors.muted),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  BCPrimaryButton.dark(
                                    label: 'Verify Now →',
                                    isFullWidth: false,
                                    onPressed: () => _openVerifySheet(profile),
                                  ),
                                ],
                              ),
                            )
                          else
                            BCCard(
                              backgroundColor: const Color(0xFFE7FCEB),
                              child: const Text(
                                '✅ Verified Brand — Creators trust you more!',
                                style: AppTypography.labelMD,
                              ),
                            ),
                          const SizedBox(height: AppSpacing.lg),
                          BCCard(
                            shadow: AppShadows.blue,
                            onTap: () => context.push(RouteNames.brandCredits),
                            child: Row(
                              children: [
                                const Text('⚡ Credits',
                                    style: AppTypography.labelMD),
                                const Spacer(),
                                Text(
                                  '$credits',
                                  style: AppTypography.displaySM
                                      .copyWith(color: AppColors.blue),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                TextButton(
                                  onPressed: () =>
                                      context.push(RouteNames.brandCredits),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.blue,
                                  ),
                                  child: const Text('Buy Credits →'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Past Campaigns (${completedCampaigns.length})',
                                  style: AppTypography.displaySM,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push(RouteNames.brandCampaigns),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.pink,
                                ),
                                child: const Text('See all →'),
                              ),
                            ],
                          ),
                          if (completedCampaigns.isEmpty)
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Text(
                                '📢 No campaigns yet.',
                                style: AppTypography.bodySM,
                              ),
                            )
                          else
                            Column(
                              children:
                                  completedCampaigns.take(3).map((campaign) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  child: BCCard(
                                    shadow: AppShadows.neon,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                campaign.title,
                                                style: AppTypography.labelMD,
                                              ),
                                            ),
                                            const BCBadge(
                                              label: 'Completed',
                                              variant: BCBadgeVariant.blue,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            BCBadge(
                                              label: _campaignCollabType(
                                                  campaign.collabType),
                                              variant: BCBadgeVariant.outline,
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.sm),
                                            BCBadge(
                                              label:
                                                  '${campaign.slotsFilled} collabs done',
                                              variant: BCBadgeVariant.neon,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          campaign.deadline != null
                                              ? 'Ended ${_date(campaign.deadline!)}'
                                              : 'Date range unavailable',
                                          style: AppTypography.bodyXS
                                              .copyWith(color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Completed Collabs (${completedCollabs.length})',
                                  style: AppTypography.displaySM,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push(RouteNames.brandCollabs),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.pink,
                                ),
                                child: const Text('See all →'),
                              ),
                            ],
                          ),
                          if (completedCollabsAsync.isLoading)
                            const _InlineShimmerList()
                          else if (completedCollabsAsync.hasError)
                            BCErrorState(
                              message: completedCollabsAsync.error.toString(),
                              onRetry: () =>
                                  ref.refresh(_completedCollabsProvider),
                            )
                          else if (completedCollabs.isEmpty)
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Text(
                                '🤝 No completed collabs yet.',
                                style: AppTypography.bodySM,
                              ),
                            )
                          else
                            Column(
                              children: completedCollabs.take(3).map((collab) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  child: BCCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                collab.creatorName,
                                                style: AppTypography.labelMD,
                                              ),
                                            ),
                                            const BCBadge(
                                              label: 'micro',
                                              variant: BCBadgeVariant.outline,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            Text(
                                              collab.agreedAmount != null
                                                  ? '₹${collab.agreedAmount}'
                                                  : 'Amount not set',
                                              style: AppTypography.labelSM,
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.sm),
                                            const BCBadge(
                                              label: 'Completed',
                                              variant: BCBadgeVariant.blue,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          '★★★★☆',
                                          style: AppTypography.bodySM.copyWith(
                                              color: AppColors.warning),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: AppSpacing.xl),
                          BCCard(
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () =>
                                      context.push(RouteNames.settings),
                                  leading: const Text('⚙️'),
                                  title: const Text(
                                    'Settings',
                                    style: AppTypography.labelMD,
                                  ),
                                  trailing:
                                      const Icon(Symbols.chevron_right_rounded),
                                ),
                                const Divider(
                                    color: AppColors.divider, height: 1),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: _logout,
                                  leading: const Text('🚪'),
                                  title: Text(
                                    'Logout',
                                    style: AppTypography.labelMD
                                        .copyWith(color: AppColors.error),
                                  ),
                                  trailing: const Icon(
                                    Symbols.chevron_right_rounded,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProfilePostsTab(
                      mediaUrls: profile.portfolioLinks,
                      canManage: true,
                      emptyTitle:
                          'Upload photos/videos to showcase your brand work.',
                      onUpload: () => _uploadProfilePost(profile),
                      onDelete: (url) => _deleteProfilePost(profile, url),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return BCCard(
      shadow: AppShadows.pink,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.labelLG),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyXS,
          ),
        ],
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

String _campaignCollabType(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}

String _date(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
