import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/collab_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_error_state.dart';

class PaymentMilestoneViewScreen extends ConsumerStatefulWidget {
  const PaymentMilestoneViewScreen({
    super.key,
    required this.collabId,
  });

  final String collabId;

  @override
  ConsumerState<PaymentMilestoneViewScreen> createState() =>
      _PaymentMilestoneViewScreenState();
}

class _PaymentMilestoneViewScreenState
    extends ConsumerState<PaymentMilestoneViewScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _milestones = [];
  String? _error;
  String? _releasingId;

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collabNotifier = ref.read(collabProvider(widget.collabId).notifier);
      final milestones = await collabNotifier.getPaymentMilestones();
      setState(() {
        _milestones = milestones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _releaseMilestone(String milestoneId) async {
    setState(() => _releasingId = milestoneId);

    try {
      final collabNotifier = ref.read(collabProvider(widget.collabId).notifier);
      await collabNotifier.releasePaymentMilestone(milestoneId);
      await _loadMilestones();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment released successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _releasingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider.select((s) => s.role)) ?? 'creator';
    final isBrand = role == 'brand';
    final collabAsync = ref.watch(collabProvider(widget.collabId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Milestones'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: _isLoading
          ? const Center(child: BCAppLoader())
          : _error != null
              ? BCErrorState(message: _error!, onRetry: _loadMilestones)
              : _milestones.isEmpty
                  ? const Center(
                      child: Text('No payment milestones configured.'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      children: [
                        // Summary
                        _PaymentSummary(
                          milestones: _milestones,
                          agreedAmountPaise: collabAsync.valueOrNull?.agreedAmountPaise ?? 0,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Milestones list
                        ...List.generate(_milestones.length, (index) {
                          final m = _milestones[index];
                          final isReleased = m['status']?.toString() == 'released';
                          final isReleasing = _releasingId == m['id'];
                          final percentage = double.tryParse(
                                  m['percentage']?.toString() ?? '0') ??
                              0;
                          final amount = _int(m['amount_paise']);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _MilestoneCard(
                              name: m['name']?.toString() ?? 'Milestone ${index + 1}',
                              percentage: percentage,
                              amount: amount,
                              isReleased: isReleased,
                              releasedAt: m['released_at']?.toString(),
                              canRelease: isBrand && !isReleased,
                              isReleasing: isReleasing,
                              onRelease: () => _releaseMilestone(m['id']),
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.milestones,
    required this.agreedAmountPaise,
  });

  final List<Map<String, dynamic>> milestones;
  final int agreedAmountPaise;

  @override
  Widget build(BuildContext context) {
    final released = milestones
        .where((m) => m['status']?.toString() == 'released')
        .fold<int>(0, (sum, m) => sum + (m['amount_paise'] as int? ?? 0));
    final pending = agreedAmountPaise - released;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightDivider, width: 1),
      ),
      child: Row(
        children: [
          _SummaryItem(
            label: 'Total',
            amount: agreedAmountPaise,
            color: AppColors.ink,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightDivider,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          _SummaryItem(
            label: 'Released',
            amount: released,
            color: AppColors.success,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightDivider,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          _SummaryItem(
            label: 'Pending',
            amount: pending,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            Formatters.currency(amount),
            style: AppTypography.labelMD.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.isReleased,
    this.releasedAt,
    required this.canRelease,
    required this.isReleasing,
    required this.onRelease,
  });

  final String name;
  final double percentage;
  final int amount;
  final bool isReleased;
  final String? releasedAt;
  final bool canRelease;
  final bool isReleasing;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReleased ? AppColors.success : AppColors.lightDivider,
          width: isReleased ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isReleased
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.lightBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isReleased
                ? const Icon(Icons.check_rounded, size: 20, color: AppColors.success)
                : Text(
                    '${percentage.round()}%',
                    style: AppTypography.labelXS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.labelMD.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.currency(amount),
                  style: AppTypography.bodyXS.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (canRelease)
            GestureDetector(
              onTap: isReleasing ? null : onRelease,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.neon,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isReleasing ? '...' : 'Release',
                  style: AppTypography.labelXS.copyWith(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          else if (isReleased)
            Text(
              'Released',
              style: AppTypography.labelXS.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
