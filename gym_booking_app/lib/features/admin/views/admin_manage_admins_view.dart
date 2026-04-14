import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../../../core/theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

// Shared email validator — accepts any valid email, not just @gmail.com
String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
  return null;
}

class AdminManageAdminsView extends StatelessWidget {
  const AdminManageAdminsView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final authCtrl  = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAdminSheet(context, adminCtrl),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Add Admin', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (adminCtrl.isAdminLoading.value && adminCtrl.admins.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final admins    = adminCtrl.admins;
        final currentId = authCtrl.currentUser.value?.id ?? '';

        return RefreshIndicator(
          onRefresh: adminCtrl.fetchAdmins,
          child: admins.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(children: [
                      Icon(Icons.admin_panel_settings_outlined,
                          size: 64, color: AppTheme.textLight),
                      SizedBox(height: 16),
                      Text('No admins found',
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textMedium)),
                    ]),
                  ),
                ])
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: admins.length,
                  itemBuilder: (ctx, i) {
                    final admin  = admins[i];
                    final isSelf = admin.id == currentId;
                    return _AdminCard(
                      admin: admin,
                      isSelf: isSelf,
                      onRemove: () => _confirmRemove(admin, adminCtrl),
                    );
                  },
                ),
        );
      }),
    );
  }

  void _showAddAdminSheet(BuildContext context, AdminController adminCtrl) {
    final formKey  = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool obscure   = true;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Row(children: [
                    Icon(Icons.person_add_alt_1, color: AppTheme.primary),
                    SizedBox(width: 10),
                    Text('Add New Admin',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark)),
                  ]),
                  const SizedBox(height: 4),
                  const Text(
                    'The new admin will have full access to manage slots and bookings.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
                  ),
                  const SizedBox(height: 20),

                  // Tip banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'If you enter an email of an existing member, '
                            'they will be upgraded to admin automatically.',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    hint: 'e.g. Jane Smith',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // ✅ Fixed: uses regex validator, accepts any domain
                  AppTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    hint: 'admin@yourgym.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    obscureText: obscure,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textMedium,
                          size: 20),
                      onPressed: () =>
                          setState(() => obscure = !obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Obx(() => AppButton(
                        label: 'Create Admin Account',
                        isLoading: adminCtrl.isAdminLoading.value,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final ok = await adminCtrl.addAdmin(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text,
                            );
                            if (ok) Get.back();
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmRemove(UserModel admin, AdminController adminCtrl) {
    Get.dialog(AlertDialog(
      title: const Text('Remove Admin'),
      content: Text(
          'Remove ${admin.name} as admin? They will become a regular member.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            adminCtrl.removeAdmin(admin.id, admin.name);
          },
          child: const Text('Remove',
              style: TextStyle(color: AppTheme.error)),
        ),
      ],
    ));
  }
}

class _AdminCard extends StatelessWidget {
  final UserModel admin;
  final bool isSelf;
  final VoidCallback onRemove;

  const _AdminCard(
      {required this.admin,
      required this.isSelf,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primary.withOpacity(0.12),
              child: Text(
                admin.name.isNotEmpty
                    ? admin.name[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(admin.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppTheme.textDark)),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('You',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(admin.email,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textMedium)),
                ],
              ),
            ),

            // Badge + remove
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Admin',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600)),
                ),
                if (!isSelf) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Text('Remove',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.error,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
