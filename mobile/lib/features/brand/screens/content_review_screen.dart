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
import '../../../widgets/inputs/bc_text_field.dart';

class ContentReviewScreen extends ConsumerStatefulWidget {
  const ContentReviewScreen({super.key, required this.collabId});

  final String collabId;

  @override
  ConsumerState<ContentReviewScreen> createState() =>
      _ContentReviewScreenState();
}

class _ContentReviewScreenState extends ConsumerState<ContentReviewScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _submissions = [];
  String? _error;
  String? _reviewingId;
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collabNotifier = ref.read(collabProvider(widget.collabId).notifier);
      final subs = await collabNotifier.getContentSubmissions();
      setState(() {
        _submissions = subs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reviewSubmission(String submissionId, String status) async {
    setState(() => _reviewingId = submissionId);

    try {
      final collabNotifier = ref.read(collabProvider(widget.collabId).notifier);
      await collabNotifier.reviewContent(
        submissionId,
        status: status,
        feedback: _feedbackController.text.trim().isNotEmpty
            ? _feedbackController.text.trim()
            : null,
      );

      _feedbackController.clear();
      await _loadSubmissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Content approved!'
                  : status == 'rejected'
                      ? 'Content rejected.'
                      : 'Revision requested.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _reviewingId = null);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Content'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: BCAppLoader())
                : _error != null
                    ? BCErrorState(message: _error!, onRetry: _loadSubmissions)
                    : _submissions.isEmpty
                        ? const Center(
                            child: Text('No content submissions yet.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.screenPadding),
                            itemCount: _submissions.length,
                            itemBuilder: (context, index) {
                              final sub = _submissions[index];
                              final isPending =
                                  (sub['status']?.toString() ?? 'pending') ==
                                      'pending';
                              final isReviewing = _reviewingId == sub['id'];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                child: _ReviewableSubmissionCard(
                                  submission: sub,
                                  isReviewing: isReviewing,
                                  feedbackController: _feedbackController,
                                  onView: () async {
                                    final url =
                                        sub['content_url']?.toString();
                                    if (url != null && url.isNotEmpty) {
                                      final uri = Uri.tryParse(url);
                                      if (uri != null) {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    }
                                  },
                                  onApprove: isPending
                                      ? () => _reviewSubmission(
                                          sub['id'], 'approved')
                                      : null,
                                  onReject: isPending
                                      ? () => _reviewSubmission(
                                          sub['id'], 'rejected')
                                      : null,
                                  onRevision: isPending
                                      ? () => _reviewSubmission(
                                          sub['id'], 'revision_requested')
                                      : null,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _ReviewableSubmissionCard extends StatelessWidget {
  const _ReviewableSubmissionCard({
    required this.submission,
    required this.isReviewing,
    required this.feedbackController,
    required this.onView,
    this.onApprove,
    this.onReject,
    this.onRevision,
  });

  final Map<String, dynamic> submission;
  final bool isReviewing;
  final TextEditingController feedbackController;
  final VoidCallback onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRevision;

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
          // Header
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

          // Caption
          if (caption != null && caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              caption,
              style: AppTypography.bodySM.copyWith(color: AppColors.ink),
            ),
          ],

          // Previous feedback
          if (feedback != null && feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your feedback: $feedback',
                style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Timestamp
          if (submittedAt != null)
            Text(
              'Submitted ${Formatters.timeAgo(DateTime.tryParse(submittedAt) ?? DateTime.now())}',
              style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
            ),

          // View button
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: onView,
            child: Text(
              'View Content →',
              style: AppTypography.labelSM.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Review actions
          if (onApprove != null) ...[
            const SizedBox(height: AppSpacing.md),
            BCTextField(
              label: 'Feedback (Optional)',
              hint: 'Add feedback for the creator',
              controller: feedbackController,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Approve',
                    color: AppColors.success,
                    icon: Icons.check_rounded,
                    isLoading: isReviewing,
                    onTap: onApprove!,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    label: 'Revision',
                    color: AppColors.warning,
                    icon: Icons.replay_rounded,
                    isLoading: isReviewing,
                    onTap: onRevision!,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    color: AppColors.error,
                    icon: Icons.close_rounded,
                    isLoading: isReviewing,
                    onTap: onReject!,
                  ),
                ),
              ],
            ),
          ],
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelXS.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
