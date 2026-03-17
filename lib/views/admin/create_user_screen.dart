import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/admin_controller.dart';
import '../../core/utils/snackbar_utils.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _role = 'receptionist';
  bool _hidePass = true;

  final List<String> _roles = ['receptionist', 'patient', 'doctor'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(adminControllerProvider.notifier).createUser(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _role,
          phone: _phoneCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'User created successfully.');
      context.pop();
    } else {
      final err = ref.read(adminControllerProvider).error;
      SnackbarUtils.showError(context, err ?? 'Failed to create user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Create User'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                ctrl: _nameCtrl,
                label: 'Full Name',
                hint: 'Enter full name',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              _field(
                ctrl: _emailCtrl,
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _field(
                ctrl: _passCtrl,
                label: 'Password',
                hint: 'Enter password',
                icon: Icons.lock_outline,
                obscure: _hidePass,
                suffix: IconButton(
                  icon: Icon(
                    _hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _field(
                ctrl: _phoneCtrl,
                label: 'Phone (optional)',
                hint: 'Enter phone number',
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r[0].toUpperCase() + r.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Create User',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }


}
