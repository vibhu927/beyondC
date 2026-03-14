import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/bc_logo.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/badges/bc_badge.dart';
import '../../../widgets/inputs/bc_text_field.dart';
import '../../../widgets/inputs/bc_dropdown.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String? role;

  const SignupScreen({
    super.key,
    this.role,
  });

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
  final _instagramHandleController = TextEditingController();
  final _brandNameController = TextEditingController();

  String? _selectedNiche;
  String? _selectedCategory;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showValidationErrors = false;

  late final String _role;

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
    _instagramHandleController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    final roleSpecificValid = (_role == 'creator' && _selectedNiche != null) ||
        (_role == 'brand' && _selectedCategory != null);

    if (!formValid || !roleSpecificValid) {
      setState(() {
        _showValidationErrors = true;
      });

      if (!roleSpecificValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _role == 'creator'
                  ? 'Please select your primary niche'
                  : 'Please select your brand category',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.ink,
          ),
        );
      }

      return;
    }

    // Prepare extra data based on role
    Map<String, dynamic>? extraData;
    if (_role == 'creator') {
      extraData = {
        if (_instagramHandleController.text.isNotEmpty)
          'instagram_handle': _instagramHandleController.text,
        if (_selectedNiche != null) 'primary_niche': _selectedNiche,
      };
    } else {
      extraData = {
        'brand_name': _brandNameController.text,
        if (_selectedCategory != null) 'brand_category': _selectedCategory,
      };
    }

    try {
      await ref.read(authProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _role,
            firstName: _firstNameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            extraData: extraData,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. Please log in.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
      context.go(RouteNames.login);
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
      backgroundColor: Colors.white,
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
                // Top row: Back arrow + Logo
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(RouteNames.roleSelect),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    const BCLogo(isDark: false, fontSize: 18),
                  ],
                ),
                const SizedBox(height: 32),
                // Headline
                Text(
                  'Create your\naccount.',
                  style: AppTypography.displayMD.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtext
                Text(
                  _role == 'creator'
                      ? 'Join as a creator and start getting paid to create.'
                      : 'Join as a brand and discover your next creator.',
                  style: AppTypography.bodyMD.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 32),
                // Role badge
                BCBadge(
                  label: _role == 'creator' ? '🎨 Joining as Creator' : '🏢 Joining as Brand',
                  variant: _role == 'creator'
                      ? BCBadgeVariant.neon
                      : BCBadgeVariant.pink,
                ),
                const SizedBox(height: 24),
                // Common fields
                BCTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  validator: (value) => Validators.minLength(value, 2, 'First name'),
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                BCTextField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  validator: (value) => Validators.minLength(value, 2, 'Full name'),
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
                BCTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  enabled: !isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
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
                // Role-specific fields
                if (_role == 'creator') ...[
                  BCTextField(
                    label: 'Instagram Handle (Optional)',
                    controller: _instagramHandleController,
                    validator: Validators.instagramHandle,
                    enabled: !isLoading,
                    prefixIcon: const Icon(
                      Icons.alternate_email,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BCDropdown(
                    label: 'Primary Niche',
                    value: _selectedNiche,
                    items: _niches,
                    hint: 'Select your niche',
                    validator: (value) =>
                        value == null ? 'Primary niche is required' : null,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _selectedNiche = value;
                      });
                    },
                  ),
                ] else ...[
                  BCTextField(
                    label: 'Brand Name',
                    controller: _brandNameController,
                    validator: (value) => Validators.minLength(value, 2, 'Brand name'),
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
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 32),
                // Submit button
                _role == 'creator'
                    ? BCPrimaryButton.neon(
                        label: 'Create Account →',
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                        isFullWidth: true,
                      )
                    : BCPrimaryButton.pink(
                        label: 'Create Account →',
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                        isFullWidth: true,
                      ),
                const SizedBox(height: 16),
                // Already have account
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () {
                      context.go(RouteNames.login);
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
