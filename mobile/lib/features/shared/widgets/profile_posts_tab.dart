import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../creator/shared/widgets/creator_design_system.dart';
import '../../../widgets/buttons/bc_back_button.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/cards/bc_card.dart';

class ProfilePostsTab extends StatefulWidget {
  const ProfilePostsTab({
    super.key,
    required this.mediaUrls,
    required this.canManage,
    required this.emptyTitle,
    this.maxItems = 6,
    this.onUpload,
    this.onDelete,
  });

  final List<String> mediaUrls;
  final bool canManage;
  final String emptyTitle;
  final int maxItems;
  final Future<void> Function()? onUpload;
  final Future<void> Function(String url)? onDelete;

  @override
  State<ProfilePostsTab> createState() => _ProfilePostsTabState();
}

class _ProfilePostsTabState extends State<ProfilePostsTab> {
  bool _isUploading = false;

  bool get _canUpload =>
      widget.canManage &&
      !_isUploading &&
      widget.mediaUrls.length < widget.maxItems;

  Future<void> _handleUpload() async {
    if (!_canUpload || widget.onUpload == null) return;
    setState(() => _isUploading = true);
    try {
      await widget.onUpload!.call();
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _handleDelete(String url) async {
    if (!widget.canManage || widget.onDelete == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: BCCard(
            shadow: AppShadows.ink,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delete Media?', style: AppTypography.displaySM),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This media will be removed from your profile posts.',
                  style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: BCPrimaryButton.dark(
                        label: 'Keep',
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: BCPrimaryButton.pink(
                        label: 'Delete',
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await widget.onDelete!.call(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.mediaUrls.take(widget.maxItems).toList();
    final navClearance = MediaQuery.of(context).padding.bottom + 84;

    return Stack(
      children: [
        if (media.isEmpty)
          Center(
            child: widget.canManage
                ? GlassButton(
                    label: _isUploading ? 'Uploading...' : 'Upload media',
                    accent: AppColors.creatorDark,
                    textColor: AppColors.white,
                    solidBackground: true,
                    onTap: _canUpload ? _handleUpload : null,
                  )
                : Text(
                    widget.emptyTitle,
                    style:
                        AppTypography.bodySM.copyWith(color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
          )
        else
          GridView.builder(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.huge + navClearance,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
            ),
            itemCount: media.length,
            itemBuilder: (context, index) {
              final url = media[index];
              final isVideo = _isVideoUrl(url);
              final heroTag = 'profile-media-$index-$url';

              return GestureDetector(
                onLongPress: widget.canManage ? () => _handleDelete(url) : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _MediaViewerPage(
                        url: url,
                        isVideo: isVideo,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isVideo)
                          _VideoThumbnail(url: url)
                        else
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surfaceAlt,
                              alignment: Alignment.center,
                              child: const Icon(Symbols.broken_image_rounded),
                            ),
                          ),
                        if (isVideo)
                          Container(
                            color: Colors.black.withValues(alpha: 0.32),
                            alignment: Alignment.center,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Symbols.play_arrow_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (widget.canManage)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _handleDelete(url),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        if (media.isNotEmpty && _canUpload)
          Positioned(
            right: AppSpacing.lg,
            bottom: navClearance,
            child: GlassButton(
              label: _isUploading ? 'Uploading...' : 'Upload media',
              accent: AppColors.creatorDark,
              textColor: AppColors.white,
              solidBackground: true,
              onTap: _isUploading ? null : _handleUpload,
            ),
          ),
      ],
    );
  }
}

class _MediaViewerPage extends StatefulWidget {
  const _MediaViewerPage({
    required this.url,
    required this.isVideo,
    required this.heroTag,
  });

  final String url;
  final bool isVideo;
  final String heroTag;

  @override
  State<_MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<_MediaViewerPage> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
      await controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _videoError =
            'Unable to play this video. Please upload an MP4/WebM file.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: widget.heroTag,
              child: widget.isVideo
                  ? (_videoError != null
                      ? Container(
                          color: AppColors.surfaceAlt,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Symbols.videocam_off_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _videoError!,
                                style: AppTypography.bodySM
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : (_isReady && _controller != null
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        )
                      : const CircularProgressIndicator(color: Colors.white)))
                  : InteractiveViewer(
                      child: Image.network(
                        widget.url,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: AppSpacing.xl * 2,
            right: AppSpacing.lg,
            child: BCBackButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.close_rounded,
              tooltip: 'Close',
            ),
          ),
          if (widget.isVideo && _isReady && _controller != null)
            Positioned(
              bottom: AppSpacing.xl * 2,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _controller!.play();
                      }
                    });
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.6),
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Symbols.pause_rounded
                          : Symbols.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  const _VideoThumbnail({required this.url});

  final String url;

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isReady = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_isReady && controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: const Icon(
        Symbols.video_library_rounded,
        color: AppColors.muted,
      ),
    );
  }
}

bool _isVideoUrl(String url) {
  final value = url.toLowerCase();
  final uri = Uri.tryParse(value);
  final path = (uri?.path ?? value).toLowerCase();

  return path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.m4v') ||
      path.endsWith('.webm') ||
      path.endsWith('.avi') ||
      path.endsWith('.mkv');
}
