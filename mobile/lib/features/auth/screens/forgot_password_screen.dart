import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/buttons/bc_primary_button.dart';
import '../../../widgets/inputs/bc_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(authProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );

      if (!mounted) return;

      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send reset link: ${e.toString()}',
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
          child: _emailSent ? _buildSuccessState() : _buildFormState(isLoading),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back arrow
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Large emoji
          const Text(
            '🔑',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          // Headline
          Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: AppTypography.displayMD.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          // Subtext
          Text(
            'Enter your email and we\'ll send you a reset link.',
            textAlign: TextAlign.center,
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
          const SizedBox(height: 24),
          // Submit button
          BCPrimaryButton.neon(
            label: 'Send Reset Link →',
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),
          // Back to login
          TextButton(
            onPressed: isLoading ? null : () => context.pop(),
            child: Text(
              'Back to Login',
              style: AppTypography.buttonMD.copyWith(
                color: AppColors.ink,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        // Success emoji
        const Text(
          '✅',
          style: TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 24),
        // Headline
        Text(
          'Check your inbox!',
          textAlign: TextAlign.center,
          style: AppTypography.displayMD.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        // Body
        Text(
          'We\'ve sent a password reset link to your email.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMD.copyWith(
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 40),
        // Back to login button
        BCPrimaryButton.dark(
          label: 'Back to Login',
          onPressed: () {
            context.go(RouteNames.login);
          },
          isFullWidth: true,
        ),
      ],
    );
  }
}
