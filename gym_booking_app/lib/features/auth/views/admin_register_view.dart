import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

class AdminRegisterView extends StatefulWidget {
  const AdminRegisterView({super.key});

  @override
  State<AdminRegisterView> createState() => _AdminRegisterViewState();
}

class _AdminRegisterViewState extends State<AdminRegisterView> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  final _setupKeyCtrl   = TextEditingController();
  final _authCtrl       = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _obscureKey      = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _setupKeyCtrl.dispose();
    super.dispose();
  }

  // Accepts any valid email — not just gmail
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _authCtrl.registerAdmin(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        setupKey: _setupKeyCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Back
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios,
                          size: 16, color: AppTheme.textMedium),
                      Text('Back to Login',
                          style: TextStyle(color: AppTheme.textMedium)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.admin_panel_settings,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Setup',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark)),
                        Text('Create the gym owner account',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textMedium)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.warning.withOpacity(0.4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: AppTheme.warning, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin accounts require a Setup Key. '
                          'Find it in your backend .env file as ADMIN_SETUP_KEY.',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'Gym Owner Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'owner@yourgym.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textMedium),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _confirmCtrl,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textMedium),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please confirm your password';
                    if (v != _passwordCtrl.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Setup Key',
                          style: TextStyle(
                              color: AppTheme.textMedium, fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _setupKeyCtrl,
                  label: 'Admin Setup Key',
                  hint: 'Enter the key from your .env file',
                  obscureText: _obscureKey,
                  prefixIcon: Icons.vpn_key_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureKey ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMedium),
                    onPressed: () =>
                        setState(() => _obscureKey = !_obscureKey),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Setup key is required' : null,
                ),

                const SizedBox(height: 28),
                Obx(() => AppButton(
                      label: 'Create Admin Account',
                      isLoading: _authCtrl.isLoading.value,
                      onPressed: _submit,
                    )),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
