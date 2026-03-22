import 'package:flutter/material.dart';
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

  const BCDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
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
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border.all(
              color: borderColor,
              width: AppSpacing.borderWidth,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            boxShadow: _isFocused ? AppShadows.neon : AppShadows.ink,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: widget.value,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMD.copyWith(
                color: mutedColor,
              ),
              border: InputBorder.none,
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
              Icons.keyboard_arrow_down,
              color: textColor,
            ),
            dropdownColor: surfaceColor,
            items: widget.items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: widget.onChanged,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
