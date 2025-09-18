import 'package:flutter/material.dart';
import 'package:eWarranty/services/retailer_profile_service.dart';
import 'package:eWarranty/utils/pixelutil.dart';
import 'package:eWarranty/utils/wooden_container.dart';

class RetailerChangePasswordScreen extends StatefulWidget {
  const RetailerChangePasswordScreen({super.key});

  @override
  _RetailerChangePasswordScreenState createState() =>
      _RetailerChangePasswordScreenState();
}

class _RetailerChangePasswordScreenState
    extends State<RetailerChangePasswordScreen> {
  bool isLoading = false;

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    final currentPassword = _currentController.text.trim();
    final newPassword = _newController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final updatedUser = await changeRetailerPassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
        ),
        centerTitle: true, // You can make it false if needed
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xff0878fe))),

          // Foreground content
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil.unitHeight * 20,
                vertical: ScreenUtil.unitHeight * 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                        controller: _currentController,
                        label: "Current Password",
                        hint: "Enter your current password",
                        isVisible: _isCurrentPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isCurrentPasswordVisible =
                                !_isCurrentPasswordVisible;
                          });
                        },
                        icon: Icons.lock_outline,
                      ),
                      SizedBox(height: ScreenUtil.unitHeight * 20),
                      _buildPasswordField(
                        controller: _newController,
                        label: "New Password",
                        hint: "Enter your new password",
                        isVisible: _isNewPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                        icon: Icons.lock_reset,
                      ),
                      SizedBox(height: ScreenUtil.unitHeight * 20),
                      _buildPasswordField(
                        controller: _confirmController,
                        label: "Confirm New Password",
                        hint: "Re-enter your new password",
                        isVisible: _isConfirmPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        icon: Icons.check_circle_outline,
                      ),
                      SizedBox(height: ScreenUtil.unitHeight * 40),
                      SizedBox(
                        width: double.infinity,
                        height: ScreenUtil.unitHeight * 70,
                        child:
                            isLoading
                                ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.blue.withOpacity(0.7),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFffffff),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                       8,
                                      ), 
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.save_outlined,
                                        color: Color(0xff0878fe),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Update Password",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xff0878fe),
                                          fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ScreenUtil.unitHeight * 10),
        TextField(
          controller: controller,
          style: TextStyle(color: Color(0xff0878fe)),
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xff0878fe)),
            prefixIcon: Icon(icon, color: Color(0xff0878fe)),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Color(0xff0878fe),
              ),
              onPressed: onVisibilityToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xff0878fe)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xff0878fe)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xff0878fe), width: 2),
            ),
            filled: true,
            fillColor: Color(0xffffffff),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
