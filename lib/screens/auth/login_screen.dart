import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/screens/auth/verification_screen.dart';
import 'package:android_dev_final_project/screens/home/home_screen.dart';
import 'package:android_dev_final_project/services/auth_service.dart';
import 'package:android_dev_final_project/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            phoneNumber: _phoneController.text.trim(),
            verificationId: '123456',
          ),
        ),
      );
      // await authService.verifyPhoneNumber(
      //   phoneNumber: _phoneController.text.trim(),
      //   verificationCompleted: (PhoneAuthCredential credential) async {
      //     // Auto-verification completed (Android only)
      //     await authService.signInWithCredential(credential);
      //     if (mounted) {
      //       Navigator.of(context).pushReplacement(
      //         MaterialPageRoute(builder: (_) => const HomeScreen()),
      //       );
      //     }
      //   },
      //   verificationFailed: (FirebaseAuthException e) {
      //     setState(() {
      //       _isLoading = false;
      //       _errorMessage = e.message ?? 'Verification failed. Please try again.';
      //     });
      //   },
      //   codeSent: (String verificationId, int? resendToken) {
      //     setState(() {
      //       _isLoading = false;
      //     });
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (_) => VerificationScreen(
      //           phoneNumber: _phoneController.text.trim(),
      //           verificationId: verificationId,
      //         ),
      //       ),
      //     );
      //   },
      //   codeAutoRetrievalTimeout: (String verificationId) {
      //     // Auto-retrieval timeout
      //   },
      // );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to Peekabook',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in or create an account to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+1 234 567 8900',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          // Basic phone number validation
                          if (!value.contains('+')) {
                            return 'Please include country code (e.g., +1)';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Continue',
                        isLoading: _isLoading,
                        onPressed: _verifyPhoneNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
