import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/brand_provider.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _venueAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _virtualLinkController = TextEditingController();
  final _slotsController = TextEditingController(text: '10');
  final _creatorBenefitsController = TextEditingController();

  String? _eventType;
  DateTime? _eventDate;
  bool _isVirtual = false;
  bool _isSubmitting = false;

  final Set<String> _targetNiches = <String>{};
  final Set<String> _targetTiers = <String>{};

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _cityController.dispose();
    _virtualLinkController.dispose();
    _slotsController.dispose();
    _creatorBenefitsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );

    if (pickedTime == null) return;

    setState(() {
      _eventDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateController.text =
          DateFormat('d MMM yyyy, h:mm a').format(_eventDate!);
    });
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isSubmitting = true);

    final eventId = await ref.read(brandProvider.notifier).createEvent(
          eventName: _nameController.text.trim(),
          eventType: _eventType!,
          eventDate: _eventDate!,
          isVirtual: _isVirtual,
          totalSlots: int.tryParse(_slotsController.text.trim()) ?? 0,
          targetNiches: _targetNiches.toList(growable: false),
          targetTiers: _targetTiers.toList(growable: false),
          venueName: _isVirtual ? null : _venueNameController.text.trim(),
          venueAddress: _isVirtual ? null : _venueAddressController.text.trim(),
          city: _isVirtual ? null : _cityController.text.trim(),
          virtualLink: _isVirtual ? _virtualLinkController.text.trim() : null,
          whatCreatorsGet: _creatorBenefitsController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Event created. Credits deducted when invites are sent.')),
    );

    if (eventId == null) return;
    context.go(RouteNames.brandEvents);
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Event name is required.';
    if (_eventType == null) return 'Select an event type.';
    if (_eventDate == null) return 'Select event date and time.';

    if (_isVirtual) {
      if (_virtualLinkController.text.trim().isEmpty) {
        return 'Virtual link is required.';
      }
    } else {
      if (_venueNameController.text.trim().isEmpty ||
          _venueAddressController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty) {
        return 'Venue name, address, and city are required.';
      }
    }

    final slots = int.tryParse(_slotsController.text.trim());
    if (slots == null || slots <= 0) return 'Enter valid total creator slots.';
    if (_targetNiches.isEmpty) return 'Select at least one target niche.';
    if (_targetTiers.isEmpty) return 'Select at least one target tier.';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Host an Event 🎟️', style: AppTypography.displaySM),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BCTextField(
              label: 'Event Name',
              hint: 'Air Max Day Launch Party',
              controller: _nameController,
            ),
            const SizedBox(height: AppSpacing.lg),
            BCDropdown(
              label: 'Event Type',
              hint: 'Choose type',
              value: _eventType,
              items: _eventTypes,
              onChanged: (value) => setState(() => _eventType = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: _pickDateTime,
              child: AbsorbPointer(
                child: BCTextField(
                  label: 'Event Date',
                  hint: 'Select date and time',
                  controller: _dateController,
                  suffixIcon: const Icon(Icons.calendar_today_rounded),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Expanded(
                  child: Text('Is Virtual?', style: AppTypography.labelMD),
                ),
                Switch(
                  value: _isVirtual,
                  activeColor: AppColors.neon,
                  onChanged: (value) => setState(() => _isVirtual = value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!_isVirtual) ...[
              BCTextField(
                label: 'Venue Name',
                hint: 'Skyline Rooftop',
                controller: _venueNameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              BCTextField(
                label: 'Venue Address',
                hint: 'Street and locality',
                maxLines: 2,
                controller: _venueAddressController,
              ),
              const SizedBox(height: AppSpacing.lg),
              BCTextField(
                label: 'City',
                hint: 'Mumbai',
                controller: _cityController,
              ),
            ] else ...[
              BCTextField(
                label: 'Virtual Link',
                hint: 'https://meet.example.com/abc',
                controller: _virtualLinkController,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            BCTextField(
              label: 'Total Creator Slots',
              hint: '20',
              keyboardType: TextInputType.number,
              controller: _slotsController,
            ),
            const SizedBox(height: AppSpacing.lg),
            BCTextField(
              label: 'What Creators Get',
              hint: 'Goodie bag + INR 2,000 appearance fee',
              maxLines: 3,
              controller: _creatorBenefitsController,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Target Niche', style: AppTypography.labelMD),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _niches
                  .map(
                    (niche) => _pill(
                      label: niche,
                      active: _targetNiches.contains(niche),
                      onTap: () {
                        setState(() {
                          if (_targetNiches.contains(niche)) {
                            _targetNiches.remove(niche);
                          } else {
                            _targetNiches.add(niche);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Target Tier', style: AppTypography.labelMD),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _tiers
                  .map(
                    (tier) => _pill(
                      label: tier,
                      active: _targetTiers.contains(tier),
                      onTap: () {
                        setState(() {
                          if (_targetTiers.contains(tier)) {
                            _targetTiers.remove(tier);
                          } else {
                            _targetTiers.add(tier);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            BCPrimaryButton.pink(
              label: 'Create Event →',
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No credit cost on creation. Credits are deducted when invites are sent.',
              style: AppTypography.bodyXS.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Text(
          label,
          style: AppTypography.labelSM.copyWith(
            color: active ? AppColors.neon : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

const _eventTypes = [
  'Product Launch',
  'Brand Party',
  'Press Meet',
  'Collab Meetup',
  'Virtual',
  'Other',
];

const _niches = [
  'Fashion',
  'Food',
  'Fitness',
  'Tech',
  'Beauty',
  'Travel',
  'Comedy',
  'Lifestyle',
];

const _tiers = ['Nano', 'Micro', 'Mid', 'Macro'];
