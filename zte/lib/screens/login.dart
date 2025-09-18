import 'package:flutter/material.dart';
import 'package:eWarranty/screens/retailer_drawer.dart';
import 'package:eWarranty/services/login_service.dart';
import 'package:eWarranty/utils/pixelutil.dart';
import 'package:eWarranty/utils/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isPasswordVisible = false;

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff244D9C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: ScreenUtil.unitHeight * 18,
          fontWeight: FontWeight.w500,
          color: Color(0xff000000),
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: const Color.fromARGB(255, 92, 91, 91),
            fontSize: ScreenUtil.unitHeight * 20,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: Icon(
            icon,
            color: Colors.grey[800],
            size: ScreenUtil.unitHeight * 24,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffffffff), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.unitHeight * 24,
            vertical: ScreenUtil.unitHeight * 24,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    bool isLoading = false,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: ScreenUtil.unitHeight * 65,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : backgroundColor,
          foregroundColor: textColor,
          elevation: isOutlined ? 0 : 2,
          shadowColor: backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isOutlined
                    ? BorderSide(color: backgroundColor, width: 2)
                    : BorderSide.none,
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: ScreenUtil.unitHeight * 20,
                  width: ScreenUtil.unitHeight * 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: ScreenUtil.unitHeight * 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response.success && response.data != null) {
        final token = response.data!.token;
        final user = response.data!.user;
        final userType = user?['userType']?.toString().toUpperCase();

        print('token: $token user: $user userType: $userType');

        if (token != null) {
          await SharedPreferenceHelper.instance.setString('token', token);
        }

        await SharedPreferenceHelper.instance.setString(
          'userId',
          user!['userId'],
        );

        _showSuccessMessage();

        if (!mounted) return;
        if (userType == 'RETAILER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomDrawer()),
          );
        }
      } else {
        _showErrorMessage(response.message);
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Login successful!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff244D9C),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Builder(
                  builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        Center(
                          child: Container(
                            width: ScreenUtil.unitHeight * 100,
                            height: ScreenUtil.unitHeight * 100,
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffffffff).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: const Color(0xff244D9C),
                              size: ScreenUtil.unitHeight * 50,
                            ),
                          ),
                        ),

                        SizedBox(height: ScreenUtil.unitHeight * 60),

                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffffffff),
                          ),
                        ),

                        SizedBox(height: ScreenUtil.unitHeight * 15),

                        Text(
                          'Sign in to your account',
                          style: TextStyle(
                            fontSize: ScreenUtil.unitHeight * 18,
                            color: Colors.grey[200],
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: ScreenUtil.unitHeight * 60),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildInputField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              SizedBox(height: ScreenUtil.unitHeight * 25),

                              _buildInputField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                validator: _validatePassword,
                                isPassword: true,
                              ),

                              SizedBox(height: ScreenUtil.unitHeight * 40),

                              _buildButton(
                                text: 'Sign In',
                                onPressed: _handleLogin,
                                backgroundColor: Color(0xffffffff),
                                textColor: Colors.black,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
