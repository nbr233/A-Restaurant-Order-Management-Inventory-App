import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPasswordExpanded = false;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword(AuthProvider authProvider) async {
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Please enter a new password', AppColors.error);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', AppColors.error);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', AppColors.error);
      return;
    }

    setState(() => _isLoading = true);
    final success = await authProvider.changePassword(_newPasswordController.text);
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('Password updated successfully!', AppColors.success);
      setState(() {
        _isPasswordExpanded = false;
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } else {
      _showSnackBar(authProvider.errorMessage, AppColors.error);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = authProvider.displayName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ── Profile Header ──────────────────────────────────────
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.1),
                  border: Border.all(color: AppColors.primaryColor, width: 1),
                ),
                child: const Icon(Icons.person, size: 50, color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'admin@foodierest.com',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            
            const SizedBox(height: 40),

            // ── Information Section ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleInfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Account Holder',
                    value: userName,
                  ),
                  _buildSimpleInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? 'admin@foodierest.com',
                  ),
                  
                  // ── Change Password Dropdown (Accordion) ──────────
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline, color: AppColors.primaryColor, size: 20),
                          title: const Text('Password', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: const Text('Change Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryColor)),
                          trailing: Icon(
                            _isPasswordExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.primaryColor,
                          ),
                          onTap: () {
                            setState(() {
                              _isPasswordExpanded = !_isPasswordExpanded;
                            });
                          },
                        ),
                        if (_isPasswordExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                const Divider(),
                                const SizedBox(height: 12),
                                _buildPasswordField(_newPasswordController, 'New Password'),
                                const SizedBox(height: 12),
                                _buildPasswordField(_confirmPasswordController, 'Confirm New Password'),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : () => _handleChangePassword(authProvider),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Text('Update Password', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
            
            // ── Logout Button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => authProvider.signOut(),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
