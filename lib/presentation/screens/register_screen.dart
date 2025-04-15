import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/black_theme.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'login_screen.dart';

/// Register screen for the application
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = AppConstants.roleStudent;
  String? _selectedClass;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _classes = [
    'Playgroup',
    'Nursery',
    'KG',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      final user = User(
        id: const Uuid().v4(),
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        className:
            _selectedRole == AppConstants.roleStudent ? _selectedClass : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<AuthBloc>().add(RegisterEvent(user: user));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: BlackTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            // Changed from Authenticated to RegistrationSuccess
            // Show success toast
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green, // Added for better visibility
              ),
            );

            // Navigate to login screen after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red, // Added for better visibility
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24.0 : screenSize.width * 0.1,
                vertical: 24.0,
              ),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: 600, // Maximum width for larger screens
                ),
                decoration: BoxDecoration(
                  color: BlackTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: BlackTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 30 : 40),
                      Text(
                        'User ID',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Enter your user ID',
                        isPassword: false,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Password',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '************',
                        isPassword: true,
                        isPasswordField: true,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: '************',
                        isPassword: _obscureConfirmPassword,
                        isConfirmPasswordField: true,
                      ),
                      const SizedBox(height: 20),
                      _buildRoleSelector(),
                      if (_selectedRole == AppConstants.roleStudent) ...[
                        const SizedBox(height: 20),
                        _buildClassSelector(),
                      ],
                      const SizedBox(height: 30),
                      _buildRegisterButton(),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    bool isPasswordField = false,
    bool isConfirmPasswordField = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BlackTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: BlackTheme.primaryColor, width: 1.5),
          ),
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
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
                  : isConfirmPasswordField
                  ? IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  )
                  : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (isPasswordField && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (isConfirmPasswordField && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleSelector() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: BlackTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonFormField<String>(
            value: _selectedRole,
            isExpanded: true,
            hint: Text(
              'Select your role',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 16,
              ),
              filled: false,
            ),
            dropdownColor: BlackTheme.cardColor,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items: [
              DropdownMenuItem(
                value: AppConstants.roleStudent,
                child: Text(
                  'Student',
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
              DropdownMenuItem(
                value: AppConstants.roleAdmin,
                child: Text(
                  'Admin',
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
                if (value != AppConstants.roleStudent) {
                  _selectedClass = null;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Class', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: BlackTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonFormField<String>(
            value: _selectedClass,
            isExpanded: true,
            hint: Text(
              'Select your class',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 16,
              ),
              filled: false,
            ),
            dropdownColor: BlackTheme.cardColor,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items:
                _classes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  );
                }).toList(),
            validator: (value) {
              if (_selectedRole == AppConstants.roleStudent &&
                  (value == null || value.isEmpty)) {
                return 'Please select a class';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedClass = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: BlackTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: const Center(
          // Ensure text is centered
          child: Text(
            'Sign Up',
            textAlign: TextAlign.center, // Center align the text
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing:
                  0.5, // Add slight letter spacing for better readability
            ),
          ),
        ),
      ),
    );
  }
}
