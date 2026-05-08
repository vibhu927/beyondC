import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/creator_provider.dart';
import '../../../widgets/bc_app_loader.dart';
import '../../../widgets/bc_empty_state.dart';
import '../../../widgets/bc_error_state.dart';

class TicketDetailScreen extends ConsumerWidget {
  const TicketDetailScreen({super.key, required this.inviteId});

  final String inviteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Your Ticket',
          style: AppTypography.displaySM.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: BCAppLoader()),
        error: (error, _) => BCErrorState(message: error.toString()),
        data: (tickets) {
          final ticket =
              tickets.where((item) => item.id == inviteId).firstOrNull;
          if (ticket == null) {
            return const BCEmptyState(
              emoji: '🎟️',
              message: 'Ticket not found.',
            );
          }

          final ticketCode =
              ticket.ticketCode ?? ticket.qrCodeData ?? ticket.id;
          final eventDate = ticket.eventDate;
          final creatorName = (auth.user?.userMetadata?['first_name'] ??
                  auth.user?.userMetadata?['full_name'] ??
                  'Creator')
              .toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.xl,
              AppSpacing.screenPadding,
              AppSpacing.huge,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                    border: Border.all(color: AppColors.ink, width: 2),
                    boxShadow: AppShadows.purpleLarge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neon,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSM),
                                    border: Border.all(
                                        color: AppColors.ink, width: 1.5),
                                  ),
                                  child: Text(
                                    'beyondC',
                                    style: AppTypography.labelSM
                                        .copyWith(color: AppColors.ink),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.purple,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    'EVENT',
                                    style: AppTypography.labelXS
                                        .copyWith(color: AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(ticket.eventTitle,
                                style: AppTypography.displayMD),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              ticket.brandName ?? 'Brand event',
                              style: AppTypography.bodySM
                                  .copyWith(color: AppColors.muted),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              eventDate == null
                                  ? 'Date TBD'
                                  : '${Formatters.date(eventDate)} • ${Formatters.time(eventDate)}',
                              style: AppTypography.labelMD,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              (ticket.location == null ||
                                      ticket.location!.trim().isEmpty)
                                  ? 'Virtual Event'
                                  : ticket.location!,
                              style: AppTypography.bodySM,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                        child: _DashedDivider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(creatorName,
                                          style: AppTypography.labelLG),
                                      const SizedBox(height: AppSpacing.xs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusFull),
                                          border: Border.all(
                                              color: AppColors.ink, width: 1),
                                        ),
                                        child: const Text(
                                          'Creator',
                                          style: AppTypography.labelXS,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                QrImageView(
                                  data: ticketCode,
                                  size: 140,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.ink,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Show this at the entrance',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyXS,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'bC',
                                style: AppTypography.labelXS
                                    .copyWith(color: AppColors.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton(
                  onPressed: () {
                    final shareText =
                        'I\'m going to ${ticket.eventTitle} by ${ticket.brandName ?? 'a brand'}! 🎟️ BeyondC\nTicket: $ticketCode';
                    Share.share(shareText);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.white, width: 1.6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    foregroundColor: AppColors.white,
                  ),
                  child: Text(
                    'Share Ticket',
                    style:
                        AppTypography.labelMD.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.3;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
