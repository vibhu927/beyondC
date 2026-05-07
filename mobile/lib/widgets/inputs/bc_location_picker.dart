import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/india_locations.dart';
import '../../core/theme/app_spacing.dart';
import 'bc_dropdown.dart';
import 'bc_text_field.dart';

class BCLocationPicker extends ConsumerStatefulWidget {
  const BCLocationPicker({
    super.key,
    this.initialState,
    this.initialCity,
    required this.onChanged,
    this.required = false,
    this.label = 'Location',
    this.inputBorderRadius,
  });

  final String? initialState;
  final String? initialCity;
  final void Function(String state, String city) onChanged;
  final bool required;
  final String label;
  final BorderRadius? inputBorderRadius;

  @override
  ConsumerState<BCLocationPicker> createState() => _BCLocationPickerState();
}

class _BCLocationPickerState extends ConsumerState<BCLocationPicker> {
  String? _selectedState;
  String? _selectedCity;
  final TextEditingController _otherCityController = TextEditingController();

  bool get _isOtherCity => (_selectedCity ?? '').toLowerCase() == 'other';

  @override
  void initState() {
    super.initState();
    _selectedState = _normalizeNullable(widget.initialState);
    _selectedCity = _normalizeNullable(widget.initialCity);

    if (_isOtherCity && widget.initialCity != null) {
      _otherCityController.text = widget.initialCity!;
    }

    _emitIfReady();
  }

  @override
  void didUpdateWidget(covariant BCLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialState != widget.initialState ||
        oldWidget.initialCity != widget.initialCity) {
      _selectedState = _normalizeNullable(widget.initialState);
      _selectedCity = _normalizeNullable(widget.initialCity);
      if (_isOtherCity && widget.initialCity != null) {
        _otherCityController.text = widget.initialCity!;
      } else {
        _otherCityController.clear();
      }
      _emitIfReady();
    }
  }

  @override
  void dispose() {
    _otherCityController.dispose();
    super.dispose();
  }

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  void _emitIfReady() {
    final state = _selectedState;
    if (state == null || state.isEmpty) return;

    final city = _isOtherCity
        ? _otherCityController.text.trim()
        : (_selectedCity ?? '').trim();
    if (city.isEmpty) return;

    widget.onChanged(state, city);
  }

  @override
  Widget build(BuildContext context) {
    final cityItems = _selectedState == null
        ? const <String>[]
        : IndiaLocations.getCities(_selectedState!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(widget.label),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BCDropdown(
                label: 'State${widget.required ? ' *' : ''}',
                value: _selectedState,
                hint: 'Select state',
                items: IndiaLocations.states,
                borderRadius: widget.inputBorderRadius,
                validator: widget.required
                    ? (value) =>
                        (value == null || value.trim().isEmpty) ? 'State is required' : null
                    : null,
                onChanged: (nextState) {
                  setState(() {
                    _selectedState = _normalizeNullable(nextState);
                    _selectedCity = null;
                    _otherCityController.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: BCDropdown(
                label: 'City${widget.required ? ' *' : ''}',
                value: _selectedCity,
                hint: _selectedState == null ? 'Select state first' : 'Select city',
                items: cityItems,
                borderRadius: widget.inputBorderRadius,
                validator: widget.required
                    ? (value) {
                        if (_selectedState == null || _selectedState!.isEmpty) {
                          return 'State is required';
                        }
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      }
                    : null,
                onChanged: _selectedState == null
                    ? null
                    : (nextCity) {
                        setState(() {
                          _selectedCity = _normalizeNullable(nextCity);
                          if (!_isOtherCity) {
                            _otherCityController.clear();
                          }
                        });
                        _emitIfReady();
                      },
              ),
            ),
          ],
        ),
        if (_isOtherCity) ...[
          const SizedBox(height: AppSpacing.md),
          BCTextField(
            label: 'Enter city${widget.required ? ' *' : ''}',
            hint: 'Type your city',
            controller: _otherCityController,
            borderRadius: widget.inputBorderRadius,
            onChanged: (_) => _emitIfReady(),
            validator: widget.required
                ? (value) =>
                    (value == null || value.trim().isEmpty) ? 'City is required' : null
                : null,
          ),
        ],
      ],
    );
  }
}
