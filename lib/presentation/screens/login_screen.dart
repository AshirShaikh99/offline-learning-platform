import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import '../../core/theme/app_theme.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'admin/admin_dashboard.dart';
import 'register_screen.dart';
import 'student/student_dashboard.dart';

/// Login screen for the application
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Random color generator
  final Random _random = Random();
  Color _getRandomColor() {
    return Color.fromRGBO(
      _random.nextInt(200), // Limiting to 200 for softer colors
      _random.nextInt(200),
      _random.nextInt(200),
      0.7, // Adding some transparency
    );
  }

  // List of education icons
  final List<IconData> _educationIcons = [
    Icons.school,
    Icons.book,
    Icons.auto_stories,
    Icons.science,
    Icons.calculate,
    Icons.history_edu,
    Icons.psychology,
    Icons.language,
    Icons.computer,
    Icons.brush,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          username: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final padding = size.width * 0.05; // 5% of screen width for padding

    return Scaffold(
      backgroundColor: const Color(0xFFF8E8C8),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) =>
                        state.user.isAdmin
                            ? const AdminDashboard()
                            : const StudentDashboard(),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width:
                          isSmallScreen
                              ? double.infinity
                              : 600, // Max width on larger screens
                      constraints: BoxConstraints(
                        maxWidth: 800, // Maximum width constraint
                        minHeight: size.height * 0.5, // Minimum height
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.02),
                          _buildTitle(isSmallScreen),
                          SizedBox(height: size.height * 0.04),
                          _buildLoginForm(state, isSmallScreen),
                          SizedBox(height: size.height * 0.03),
                          _buildEducationIcons(isSmallScreen),
                          SizedBox(height: size.height * 0.02),
                          _buildSignUpText(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          'to Edutech',
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthState state, bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            hintText: 'User ID',
            isPassword: false,
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildTextField(
            controller: _passwordController,
            hintText: 'Password',
            isPassword: _obscurePassword,
            isPasswordField: true,
          ),
          SizedBox(height: isSmallScreen ? 24 : 32),
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: state is! AuthLoading ? _login : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero, // Remove default padding
              ),
              child:
                  state is AuthLoading
                      ? Center(
                        child: SizedBox(
                          height: isSmallScreen ? 20 : 24,
                          width: isSmallScreen ? 20 : 24,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                      : FittedBox(
                        fit: BoxFit.none,
                        child: Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    bool isPasswordField = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none, // Remove focus border
          enabledBorder: InputBorder.none, // Remove enabled border
          errorBorder: InputBorder.none, // Remove error border
          disabledBorder: InputBorder.none, // Remove disabled border
          fillColor: Colors.transparent,
          filled: true,
          suffixIcon:
              isPasswordField
                  ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                  : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEducationIcons(bool isSmallScreen) {
    final List<Map<String, dynamic>> educationItems = [
      {'color': const Color(0xFFFF6B6B), 'icon': Icons.school},
      {'color': const Color(0xFF4ECDC4), 'icon': Icons.auto_stories},
      {'color': const Color(0xFFFFBE0B), 'icon': Icons.science},
      {'color': const Color(0xFF7400B8), 'icon': Icons.calculate},
      {'color': const Color(0xFF80ED99), 'icon': Icons.computer},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            educationItems.map((item) {
              return Container(
                margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                width: isSmallScreen ? 50 : 60,
                height: isSmallScreen ? 50 : 60,
                decoration: BoxDecoration(
                  color: item['color'],
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: item['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'],
                  size: isSmallScreen ? 24 : 30,
                  color: Colors.white,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSignUpText() {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey,
            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
          ),
          children: const [
            TextSpan(text: 'New to Edutech? '),
            TextSpan(
              text: 'Sign up',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
