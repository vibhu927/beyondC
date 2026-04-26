import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/bc_logo.dart';
import '../../../widgets/buttons/bc_back_button.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_dropdown.dart';
import '../../../widgets/inputs/bc_location_picker.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({
    super.key,
    this.role,
  });

  final String? role;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _brandNameController = TextEditingController();

  String? _selectedNiche;
  String? _selectedCategory;
  String? _selectedState;
  String? _selectedCity;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showValidationErrors = false;

  late final String _role;

  bool get _isCreator => _role == 'creator';
  bool get _isBrand => _role == 'brand';
  bool get _isAgency => _role == 'agency';

  final List<String> _niches = [
    'Fashion',
    'Food',
    'Travel',
    'Tech',
    'Beauty',
    'Comedy',
    'Fitness',
    'Gaming',
    'Lifestyle',
    'Health',
    'Education',
    'Other',
  ];

  final List<String> _categories = [
    'Fashion',
    'Food & Beverage',
    'Health & Wellness',
    'Tech',
    'Beauty & Skincare',
    'Education',
    'Finance',
    'Gaming',
    'Lifestyle',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _role = widget.role ?? 'creator';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  String _roleDescription() {
    if (_isCreator) {
      return 'Join as a creator and start getting paid to create.';
    }
    if (_isBrand) {
      return 'Join as a brand and discover your next creator.';
    }
    return 'Join as an agency and manage creators in one workspace.';
  }

  String _roleBadgeLabel() {
    if (_isCreator) return 'Joining as Creator';
    if (_isBrand) return 'Joining as Brand';
    return 'Joining as Agency';
  }

  BCBadgeVariant _roleBadgeVariant() {
    if (_isCreator) return BCBadgeVariant.neon;
    if (_isBrand) return BCBadgeVariant.pink;
    return BCBadgeVariant.blue;
  }

  String _roleSpecificValidationMessage() {
    if (_isCreator) return 'Please select your primary niche';
    return 'Please select your brand category';
  }

  String _successMessage() {
    if (_isCreator) return 'Account created. Welcome creator!';
    if (_isBrand) return 'Account created. Welcome brand!';
    return 'Account created. Welcome agency!';
  }

  String _homeRoute() {
    if (_isCreator) return RouteNames.creatorHome;
    if (_isBrand) return RouteNames.brandHome;
    return RouteNames.agencyHome;
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    final roleSpecificValid = (_isCreator && _selectedNiche != null) ||
        (_isBrand && _selectedCategory != null) ||
        _isAgency;
    final locationValid = (_selectedState ?? '').trim().isNotEmpty &&
        (_selectedCity ?? '').trim().isNotEmpty;

    if (!formValid || !roleSpecificValid || !locationValid) {
      setState(() {
        _showValidationErrors = true;
      });

      if (!roleSpecificValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _roleSpecificValidationMessage(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.ink,
          ),
        );
      }

      if (!locationValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select state and city',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.ink,
          ),
        );
      }

      return;
    }

    Map<String, dynamic>? extraData;
    if (_isCreator) {
      extraData = {
        if (_selectedNiche != null) 'primary_niche': _selectedNiche,
      };
    } else if (_isBrand) {
      extraData = {
        'brand_name': _brandNameController.text.trim(),
        if (_selectedCategory != null) 'brand_category': _selectedCategory,
      };
    }

    try {
      await ref.read(authProvider.notifier).signUpAndSignIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _role,
            firstName: _firstNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            locationState: _selectedState!.trim(),
            locationCity: _selectedCity!.trim(),
            extraData: extraData,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _successMessage(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.ink,
        ),
      );

      context.go(_homeRoute());
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create account: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            autovalidateMode: _showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BCBackButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.roleSelect);
                        }
                      },
                      iconColor: AppColors.ink,
                      backgroundColor: AppColors.surface,
                      borderColor: AppColors.lightBorder,
                      buttonSize: 36,
                    ),
                    const Spacer(),
                    const BCLogo(isDark: false, fontSize: 18),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Create your\naccount.',
                  style: AppTypography.displayMD.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _roleDescription(),
                  style: AppTypography.bodyMD.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 32),
                BCBadge(
                  label: _roleBadgeLabel(),
                  variant: _roleBadgeVariant(),
                ),
                const SizedBox(height: 24),
                BCTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  validator: (value) =>
                      Validators.minLength(value, 2, 'First name'),
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                BCTextField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  validator: (value) =>
                      Validators.minLength(value, 2, 'Full name'),
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                BCTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                BCTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                BCLocationPicker(
                  required: true,
                  onChanged: (state, city) {
                    setState(() {
                      _selectedState = state;
                      _selectedCity = city;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                BCTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  enabled: !isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Symbols.visibility_off
                          : Symbols.visibility,
                      color: AppColors.ink,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BCTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Symbols.visibility_off
                          : Symbols.visibility,
                      color: AppColors.ink,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_isCreator) ...[
                  BCDropdown(
                    label: 'Primary Niche',
                    value: _selectedNiche,
                    items: _niches,
                    hint: 'Select your niche',
                    validator: (value) =>
                        value == null ? 'Primary niche is required' : null,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedNiche = value;
                            });
                          },
                  ),
                ] else if (_isBrand) ...[
                  BCTextField(
                    label: 'Brand Name',
                    controller: _brandNameController,
                    validator: (value) =>
                        Validators.minLength(value, 2, 'Brand name'),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCDropdown(
                    label: 'Brand Category',
                    value: _selectedCategory,
                    items: _categories,
                    hint: 'Select category',
                    validator: (value) =>
                        value == null ? 'Brand category is required' : null,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                  ),
                ] else ...[
                  Text(
                    'You can finish your agency profile after account creation.',
                    style: AppTypography.bodySM.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _isCreator
                    ? BCPrimaryButton.neon(
                        label: 'Create Account ->',
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                        isFullWidth: true,
                      )
                    : _isBrand
                        ? BCPrimaryButton.pink(
                            label: 'Create Account ->',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                            isFullWidth: true,
                          )
                        : BCPrimaryButton(
                            label: 'Create Account ->',
                            onPressed: isLoading ? null : _submit,
                            isLoading: isLoading,
                            isFullWidth: true,
                            backgroundColor: AppColors.blue,
                            textColor: AppColors.white,
                          ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.push(RouteNames.login);
                          },
                    child: Text(
                      'Already have an account? Log in',
                      style: AppTypography.buttonMD.copyWith(
                        color: AppColors.ink,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
