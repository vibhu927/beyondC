import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/creator_models.dart';
import '../../../data/services/instagram_oauth_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_bottom_nav.dart';
import '../../../widgets/bc_portal_top_bar.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';
import '../../../widgets/inputs/bc_location_picker.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../../shared/widgets/profile_posts_tab.dart';

class CreatorProfileScreen extends ConsumerStatefulWidget {
  const CreatorProfileScreen({super.key});

  @override
  ConsumerState<CreatorProfileScreen> createState() =>
      _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends ConsumerState<CreatorProfileScreen> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(myBidsProvider);
      ref.read(creatorProfileProvider);
      ref.read(creatorCollabsProvider);
      ref.read(walletProvider);
      _loadAvatarUrl();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(creatorProfileProvider.notifier).refresh(),
      ref.read(creatorCollabsProvider.notifier).refresh(),
      ref.read(walletProvider.notifier).refresh(),
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

  Future<String?> _pickAndUploadAvatar() async {
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
    final path = 'creators/$userId-$version.$ext';

    await Supabase.instance.client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> _logout() async {
    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;
      context.go(RouteNames.login);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to logout. Please try again.')),
      );
    }
  }

  Future<void> _openEditProfileSheet(CreatorProfile profile) async {
    final displayNameController = TextEditingController(
      text: profile.displayName ?? profile.fullName,
    );
    final bioController = TextEditingController(text: profile.bio);
    final nichesController =
        TextEditingController(text: profile.niches.join(', '));
    final contentTypesController =
        TextEditingController(text: profile.contentTypes.join(', '));
    final youtubeController =
        TextEditingController(text: profile.youtubeHandle ?? '');
    String? selectedState = profile.state;
    String? selectedCity = profile.city;
    String? avatarUrl = _avatarUrl;

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
            bool isSaving = false;
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
                      const Text('Edit Creator Profile',
                          style: AppTypography.displaySM),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Display Name',
                        controller: displayNameController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Bio',
                        maxLines: 4,
                        controller: bioController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Niches',
                        hint: 'Fashion, Lifestyle, Beauty',
                        controller: nichesController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Content Types',
                        hint: 'Instagram, Reels, YouTube',
                        controller: contentTypesController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'YouTube Handle',
                        hint: '@yourchannel',
                        controller: youtubeController,
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
                              color: AppColors.neon,
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
                                      _avatarInitials(profile.fullName),
                                      style: AppTypography.labelMD.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  _avatarInitials(profile.fullName),
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
                            final url = await _pickAndUploadAvatar();
                            if (url != null) {
                              setSheetState(() {
                                avatarUrl = url;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Profile photo uploaded successfully.'),
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
                          'Profile photo uploaded',
                          style: AppTypography.bodySM
                              .copyWith(color: AppColors.success),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      BCPrimaryButton.pink(
                        label: 'Save Changes →',
                        isLoading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                try {
                                  await ref
                                      .read(creatorProfileProvider.notifier)
                                      .updateProfile({
                                    'display_name':
                                        displayNameController.text.trim(),
                                    'bio': bioController.text.trim(),
                                    'niches':
                                        _parseTagList(nichesController.text),
                                    'platforms': _parseTagList(
                                        contentTypesController.text),
                                    'youtube_handle': _normalizeHandle(
                                        youtubeController.text),
                                    'state': selectedState,
                                    'city': selectedCity,
                                    if ((avatarUrl ?? '').isNotEmpty)
                                      'avatar_url': avatarUrl,
                                  });

                                  if (mounted) {
                                    setState(() {
                                      _avatarUrl = avatarUrl;
                                    });
                                  }
                                  await _refresh();
                                  if (!mounted) return;
                                  Navigator.of(this.context).pop();
                                } catch (e) {
                                  if (!mounted) return;
                                  setSheetState(() => isSaving = false);
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
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

  Future<void> _openEditPricingSheet(CreatorProfile profile) async {
    final startPriceRupees = (profile.startingPricePaise / 100).round();
    final priceController = TextEditingController(
      text: startPriceRupees > 0 ? '$startPriceRupees' : '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.46,
          minChildSize: 0.35,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, controller) {
            bool isSavingFee = false;
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
                      const Text('Edit Collab Fee',
                          style: AppTypography.displaySM),
                      const SizedBox(height: AppSpacing.lg),
                      BCTextField(
                        label: 'Starting Price (INR)',
                        hint: 'e.g. 2500',
                        controller: priceController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'This is your minimum fee shown to brands.',
                        style: AppTypography.bodySM
                            .copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BCPrimaryButton.pink(
                        label: 'Update Fee →',
                        isLoading: isSavingFee,
                        onPressed: isSavingFee
                            ? null
                            : () async {
                                final rupees =
                                    int.tryParse(priceController.text.trim());
                                if (rupees == null || rupees < 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Enter a valid non-negative amount.'),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSavingFee = true);
                                try {
                                  await ref
                                      .read(creatorProfileProvider.notifier)
                                      .updateStartingPrice(rupees * 100);
                                  await _refresh();
                                  if (!mounted) return;
                                  Navigator.of(this.context).pop();
                                } catch (e) {
                                  if (!mounted) return;
                                  setSheetState(() => isSavingFee = false);
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(
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

  Future<void> _refreshInstagramStats() async {
    try {
      await ref.read(instagramOAuthServiceProvider).refreshStats();
      await ref.read(creatorProfileProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stats refresh started.')),
      );
    } catch (error) {
      if (!mounted) return;
      final message =
          ref.read(instagramOAuthServiceProvider).extractApiError(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(message.isEmpty ? 'Could not refresh stats.' : message)),
      );
    }
  }

  List<String> _parseTagList(String value) {
    final seen = <String>{};
    final parsed = <String>[];
    for (final raw in value.split(',')) {
      final normalized = raw.trim();
      if (normalized.isEmpty) continue;
      final key = normalized.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      parsed.add(normalized);
    }
    return parsed;
  }

  String _normalizeHandle(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '';
    return normalized.startsWith('@') ? normalized.substring(1) : normalized;
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
    final path = 'creators/$userId-post-$now.$ext';
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

  Future<void> _uploadProfilePost(CreatorProfile profile) async {
    if (profile.portfolioLinks.length >= 6) return;

    final selected = await _pickProfileMediaFile();
    if (selected == null) return;

    try {
      final url = await _uploadProfileMediaToStorage(selected);
      final next = [...profile.portfolioLinks, url];

      await ref
          .read(creatorProfileProvider.notifier)
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

  Future<void> _deleteProfilePost(CreatorProfile profile, String url) async {
    try {
      final next = profile.portfolioLinks.where((item) => item != url).toList();
      await ref
          .read(creatorProfileProvider.notifier)
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
    final profileAsync = ref.watch(creatorProfileProvider);
    final collabsAsync = ref.watch(creatorCollabsProvider);
    final walletAsync = ref.watch(walletProvider);

    if (profileAsync.isLoading) {
      return const Scaffold(
        body: Center(child: BCAppLoader()),
      );
    }

    if (profileAsync.hasError) {
      return Scaffold(
        body: BCErrorState(
          message: profileAsync.error.toString(),
          onRetry: _refresh,
        ),
      );
    }

    final profile = profileAsync.value;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to load profile')),
      );
    }

    final pastCollabs =
        collabsAsync.valueOrNull?.take(3).toList() ?? const <Collab>[];
    final walletBalance =
        walletAsync.valueOrNull?.balance ?? profile.walletBalancePaise;

    return Scaffold(
      extendBody: true,
      appBar: const BCPortalTopBar(),
      bottomNavigationBar: const BCBottomNav(
        role: BCPortalRole.creator,
        currentIndex: 3,
      ),
      body: BCPageSwipeArea(
        role: BCPortalRole.creator,
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
                                border: Border.all(
                                  color: AppColors.neon,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _avatarUrl != null &&
                                      _avatarUrl!.trim().isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        _avatarUrl!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(
                                          _avatarInitials(profile.fullName),
                                          style: AppTypography.labelLG
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _avatarInitials(profile.fullName),
                                      style: AppTypography.labelLG
                                          .copyWith(color: AppColors.white),
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              profile.fullName,
                              style: AppTypography.labelLG
                                  .copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            BCBadge(
                              label: profile.tier,
                              variant: BCBadgeVariant.neon,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: () => _openEditProfileSheet(profile),
                          icon: const Icon(
                            Symbols.edit_rounded,
                            color: AppColors.white,
                          ),
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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.ink,
                    labelStyle: AppTypography.labelSM,
                    unselectedLabelStyle: AppTypography.labelSM,
                    overlayColor:
                        WidgetStateProperty.all(Colors.transparent),
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Posts'),
                    ],
                  ),
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
                                  value: Formatters.followerCount(
                                      profile.followers),
                                  label: 'Followers',
                                  shadow: AppShadows.neon,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _StatCard(
                                  value:
                                      '${profile.engagementRate.toStringAsFixed(1)}%',
                                  label: 'Engagement',
                                  shadow: AppShadows.blue,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _StatCard(
                                  value: Formatters.currency(
                                      profile.avgCollabPaise),
                                  label: 'Avg Collab',
                                  shadow: AppShadows.pink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const Text('About', style: AppTypography.displaySM),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            profile.bio,
                            style: AppTypography.bodySM
                                .copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: profile.niches
                                .map((niche) => _ThemedWordPill(label: niche))
                                .toList(),
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
                          const SizedBox(height: AppSpacing.xl),
                          const Text(
                            'Instagram Verification',
                            style: AppTypography.displaySM,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              BCBadge(
                                label: profile.instagramVerified
                                    ? '🔵 Verified'
                                    : '⚠️ Unverified',
                                variant: profile.instagramVerified
                                    ? BCBadgeVariant.blue
                                    : BCBadgeVariant.warning,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                profile.instagramVerified
                                    ? '@${profile.instagramUsername ?? 'instagram'}'
                                    : 'Connect from Home screen',
                                style: AppTypography.bodySM.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (profile.instagramVerified)
                            _InstagramStatsCard(
                              profile: profile,
                              onRefreshStats: _refreshInstagramStats,
                            ),
                          const SizedBox(height: AppSpacing.xl),
                          const Text('Content Types',
                              style: AppTypography.displaySM),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: profile.contentTypes
                                .map(
                                  (contentType) =>
                                      _ThemedWordPill(label: contentType),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          BCCard(
                            shadow: AppShadows.purple,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Starting at ${Formatters.currency(profile.startingPricePaise)}/collab',
                                  style: AppTypography.displaySM,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        _openEditPricingSheet(profile),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.blue,
                                    ),
                                    child: const Text('Edit collab fee →'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Past Collabs (${collabsAsync.valueOrNull?.length ?? 0})',
                                  style: AppTypography.displaySM,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Showing latest 3 for now.'),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.blue,
                                ),
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                          if (collabsAsync.isLoading)
                            const _PastCollabsShimmerList()
                          else if (collabsAsync.hasError)
                            BCErrorState(
                              message: collabsAsync.error.toString(),
                              onRetry: () =>
                                  ref.invalidate(creatorCollabsProvider),
                            )
                          else
                            Column(
                              children: pastCollabs
                                  .map(
                                    (collab) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm),
                                      child: BCCard(
                                        backgroundColor: AppColors.surfaceAlt,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${collab.brandCategory} • ${_collabTypeLabel(collab.collabType)}',
                                                    style:
                                                        AppTypography.labelMD,
                                                  ),
                                                  const SizedBox(
                                                      height: AppSpacing.xs),
                                                  Text(
                                                    '⭐' *
                                                        ((collab.rating ?? 4)
                                                            .clamp(1, 5)),
                                                    style: AppTypography.bodySM,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              Formatters.currency(
                                                  collab.amount),
                                              style: AppTypography.labelLG,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: AppSpacing.xl),
                          BCCard(
                            shadow: AppShadows.orange,
                            onTap: () => context.push(RouteNames.creatorWallet),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '💰 Wallet Balance',
                                        style: AppTypography.labelMD,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        Formatters.currency(walletBalance),
                                        style: AppTypography.displaySM
                                            .copyWith(color: AppColors.purple),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                GestureDetector(
                                  onTap: () =>
                                      context.push(RouteNames.creatorWallet),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.ink,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSM),
                                      border: Border.all(
                                          color: AppColors.ink, width: 2),
                                    ),
                                    child: Text(
                                      'Top Up →',
                                      style: AppTypography.labelSM
                                          .copyWith(color: AppColors.orange),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                          'Upload photos/videos to showcase your sample work.',
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
    required this.value,
    required this.label,
    required this.shadow,
  });

  final String value;
  final String label;
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

class _InstagramStatsCard extends StatelessWidget {
  const _InstagramStatsCard({
    required this.profile,
    required this.onRefreshStats,
  });

  final CreatorProfile profile;
  final VoidCallback onRefreshStats;

  @override
  Widget build(BuildContext context) {
    final followers = profile.followersCount;
    final engagementRate = profile.engagementRate;
    final highestViews = profile.highestVideoViews ?? 0;
    final totalPosts = profile.postsCount ?? 0;
    final hasFetchedStats = profile.statsFetchedAt != null;

    return BCCard(
      shadow: AppShadows.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '@${profile.instagramUsername ?? 'instagram'}',
                  style: AppTypography.labelLG,
                ),
              ),
              const BCBadge(
                label: '🔵 Verified',
                variant: BCBadgeVariant.blue,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: Formatters.followerCount(followers),
                  label: 'Followers',
                  shadow: AppShadows.neon,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  value: '${engagementRate.toStringAsFixed(1)}%',
                  label: 'Engagement',
                  shadow: AppShadows.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: Formatters.followerCount(highestViews),
                  label: 'Highest Views',
                  shadow: AppShadows.pink,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  value: '$totalPosts',
                  label: 'Total Posts',
                  shadow: AppShadows.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!hasFetchedStats)
            Text(
              'Instagram connected. Tap Refresh Stats to load your latest numbers.',
              style: AppTypography.bodySM.copyWith(color: AppColors.muted),
            ),
          if (!hasFetchedStats) const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRefreshStats,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.pink,
              ),
              child: const Text('Refresh Stats'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastCollabsShimmerList extends StatelessWidget {
  const _PastCollabsShimmerList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightDivider,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceAlt
                : AppColors.lightSurfaceAlt,
            child: BCCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          height: 14,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 70,
                          height: 12,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 64, height: 16, color: AppColors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemedWordPill extends StatelessWidget {
  const _ThemedWordPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tone = _tagToneForWord(label);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: tone.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Text(
        label,
        style: AppTypography.labelSM.copyWith(color: AppColors.ink),
      ),
    );
  }
}

Color _tagToneForWord(String label) {
  final value = label.trim().toLowerCase();

  bool hasAny(List<String> keys) => keys.any(value.contains);

  if (hasAny(['fashion', 'beauty', 'style', 'makeup', 'lifestyle'])) {
    return AppColors.pink;
  }
  if (hasAny(['food', 'recipe', 'cooking', 'drink', 'travel'])) {
    return AppColors.orange;
  }
  if (hasAny(['tech', 'gaming', 'youtube', 'stream', 'podcast'])) {
    return AppColors.blue;
  }
  if (hasAny(['fitness', 'health', 'wellness', 'gym', 'sport'])) {
    return AppColors.success;
  }
  if (hasAny(['instagram', 'reel', 'short', 'ugc', 'photo'])) {
    return AppColors.purple;
  }

  const fallback = [
    AppColors.neon,
    AppColors.pink,
    AppColors.blue,
    AppColors.purple,
    AppColors.orange,
  ];
  final hash = value.codeUnits.fold<int>(0, (sum, ch) => sum + ch);
  return fallback[hash % fallback.length];
}

String _avatarInitials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'C';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String _collabTypeLabel(CampaignCollabType type) {
  switch (type) {
    case CampaignCollabType.paid:
      return 'Paid';
    case CampaignCollabType.barter:
      return 'Barter';
    case CampaignCollabType.hybrid:
      return 'Hybrid';
  }
}
