import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/bc_logo.dart';
import '../../../widgets/buttons/bc_back_button.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      // Use response metadata to avoid timing issues with auth stream updates.
      final role = response.user?.userMetadata?['role'] as String?;
      if (role == 'creator') {
        context.go(RouteNames.creatorHome);
      } else if (role == 'brand') {
        context.go(RouteNames.brandHome);
      } else if (role == 'agency') {
        context.go(RouteNames.agencyHome);
      } else {
        context.go(RouteNames.roleSelect);
      }
    } catch (e) {
      if (!mounted) return;

      final rawMessage = ref.read(authProvider).error ?? e.toString();
      final message = rawMessage.replaceFirst('Exception: ', '').trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'Login failed. Please try again.' : message,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Back arrow + Logo
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
                const SizedBox(height: 48),
                // Headline with emoji
                RichText(
                  text: TextSpan(
                    style: AppTypography.displayLG.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                    children: const [
                      TextSpan(text: 'Welcome\n'),
                      TextSpan(
                        text: 'back.',
                        style: TextStyle(color: AppColors.neon),
                      ),
                      TextSpan(text: ' 👋'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to continue your collab journey.',
                  style: AppTypography.bodyMD.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 40),
                // Email field
                BCTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                // Password field
                BCTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) => Validators.required(value, 'Password'),
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
                const SizedBox(height: 8),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.push(RouteNames.forgotPassword);
                          },
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.buttonMD.copyWith(
                        color: AppColors.pink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login button
                BCPrimaryButton.dark(
                  label: 'Log In →',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                  isFullWidth: true,
                ),
                const SizedBox(height: 24),
                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.muted)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: AppTypography.bodySM.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 16),
                // Google login (UI only)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Google Sign-In coming soon!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.ink,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.ink,
                        width: AppSpacing.borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                      boxShadow: AppShadows.ink,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.ink,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'G',
                              style: AppTypography.labelSM.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: AppTypography.buttonMD.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Don't have account - Sign up
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                          context.push(RouteNames.roleSelect);
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                      border: Border.all(
                        color: AppColors.ink,
                        width: AppSpacing.borderWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple,
                          blurRadius: 0,
                          offset: const Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Don\'t have an account? Sign up',
                            style: AppTypography.buttonMD.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
