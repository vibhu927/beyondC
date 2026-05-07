import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';

class BCDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hint;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final BorderRadius? borderRadius;
  final bool showShadow;

  const BCDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
    this.borderRadius,
    this.showShadow = true,
  });

  @override
  State<BCDropdown> createState() => _BCDropdownState();
}

class _BCDropdownState extends State<BCDropdown> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    const borderColor = Colors.black;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusMD);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelMD.copyWith(
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: widget.value,
          focusNode: _focusNode,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyMD.copyWith(
              color: mutedColor,
            ),
            filled: true,
            fillColor: surfaceColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: borderColor,
                width: AppSpacing.borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: borderColor,
                width: AppSpacing.borderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: borderColor,
                width: AppSpacing.borderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: borderColor,
                width: AppSpacing.borderWidth,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            isDense: true,
          ),
          style: AppTypography.bodyMD.copyWith(
            color: textColor,
          ),
          icon: Icon(
            Symbols.keyboard_arrow_down,
            color: textColor,
          ),
          dropdownColor: surfaceColor,
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return widget.items
                .map(
                  (item) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMD.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                )
                .toList();
          },
          onChanged: widget.onChanged,
          validator: widget.validator,
        ),
      ],
    );
  }
}
