import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class ContentSubmissionScreen extends ConsumerStatefulWidget {
  const ContentSubmissionScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<ContentSubmissionScreen> createState() =>
      _ContentSubmissionScreenState();
}

class _ContentSubmissionScreenState
    extends ConsumerState<ContentSubmissionScreen> {
  bool _isSubmitting = false;
  bool _isLoadingSubmissions = true;
  List<Map<String, dynamic>> _submissions = [];
  String? _error;

  final _urlController = TextEditingController();
  final _captionController = TextEditingController();
  final _notesController = TextEditingController();
  String _contentType = 'image';

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoadingSubmissions = true;
      _error = null;
    });

    try {
      final collabNotifier = ref.read(collabProvider(widget.collabId).notifier);
      final subs = await collabNotifier.getContentSubmissions();
      setState(() {
        _submissions = subs;
        _isLoadingSubmissions = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingSubmissions = false;
      });
    }
  }

  Future<void> _submitContent() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a content URL')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final collabNotifier = ref.read(collabProvider(widget.collabId).notifier);
      await collabNotifier.submitContent(
        contentUrl: _urlController.text.trim(),
        contentType: _contentType,
        caption: _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      _urlController.clear();
      _captionController.clear();
      _notesController.clear();

      await _loadSubmissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content submitted. Brand has been notified.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _captionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Content'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                // Submission form
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightDivider, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Submission',
                        style: AppTypography.labelMD.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BCTextField(
                        label: 'Content URL *',
                        hint: 'https://instagram.com/p/...',
                        controller: _urlController,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Content Type',
                        style: AppTypography.labelSM.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          _ContentTypeChip(
                            label: 'Image',
                            icon: Icons.image_rounded,
                            isSelected: _contentType == 'image',
                            onTap: () => setState(() => _contentType = 'image'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ContentTypeChip(
                            label: 'Video',
                            icon: Icons.videocam_rounded,
                            isSelected: _contentType == 'video',
                            onTap: () => setState(() => _contentType = 'video'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ContentTypeChip(
                            label: 'Link',
                            icon: Icons.link_rounded,
                            isSelected: _contentType == 'link',
                            onTap: () => setState(() => _contentType = 'link'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BCTextField(
                        label: 'Caption (Optional)',
                        hint: 'Add a caption for the content',
                        controller: _captionController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BCTextField(
                        label: 'Notes for Brand (Optional)',
                        hint: 'Any notes you want to share',
                        controller: _notesController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: BCPrimaryButton(
                          label: _isSubmitting ? 'Submitting...' : 'Submit Content',
                          onPressed: _isSubmitting ? null : _submitContent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Previous submissions
                Text(
                  'Previous Submissions',
                  style: AppTypography.displaySM.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (_isLoadingSubmissions)
                  const Center(child: BCAppLoader())
                else if (_error != null)
                  BCErrorState(message: _error!, onRetry: _loadSubmissions)
                else if (_submissions.isEmpty)
                  Text(
                    'No submissions yet.',
                    style: AppTypography.bodySM.copyWith(color: AppColors.muted),
                  )
                else
                  ..._submissions.map((sub) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SubmissionCard(
                          submission: sub,
                          onView: () async {
                            final url = sub['content_url']?.toString();
                            if (url != null && url.isNotEmpty) {
                              final uri = Uri.tryParse(url);
                              if (uri != null) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentTypeChip extends StatelessWidget {
  const _ContentTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neon : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.lightDivider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.darkGreen : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelXS.copyWith(
                color: isSelected ? AppColors.darkGreen : AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.onView,
  });

  final Map<String, dynamic> submission;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final status = submission['status']?.toString() ?? 'pending';
    final contentType = submission['content_type']?.toString() ?? 'link';
    final caption = submission['caption']?.toString();
    final feedback = submission['brand_feedback']?.toString();
    final submittedAt = submission['submitted_at']?.toString();
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _contentIcon(contentType),
                size: 16,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  contentType.toUpperCase(),
                  style: AppTypography.labelXS.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: AppTypography.labelXS.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (caption != null && caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              caption,
              style: AppTypography.bodySM.copyWith(color: AppColors.ink),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (feedback != null && feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Brand feedback: $feedback',
                style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (submittedAt != null)
                Text(
                  Formatters.timeAgo(DateTime.tryParse(submittedAt) ?? DateTime.now()),
                  style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
                ),
              const Spacer(),
              GestureDetector(
                onTap: onView,
                child: Text(
                  'View',
                  style: AppTypography.labelSM.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'revision_requested':
        return AppColors.warning;
      default:
        return AppColors.muted;
    }
  }

  IconData _contentIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      default:
        return Icons.link_rounded;
    }
  }
}
