import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'constants.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey            = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  //final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool  _obscurePassword    = true;
  bool  _isLoading          = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    //_phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      // Navigate to the training screen, replacing this page
      Navigator.pushReplacementNamed(context, '/training');
    } on FirebaseAuthException catch (e) {
      // Show the specific Firebase error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? e.code)),
      );
    } catch (e) {
      // Fallback for any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) =>
                  (v != null && v.isNotEmpty) ? null : 'Enter username',
                ),
                const SizedBox(height: 12),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                  (v != null && v.contains('@')) ? null : 'Enter valid email',
                ),
                const SizedBox(height: 12),

                // Phone number field
                // TextFormField(
                //   controller: _phoneController,
                //   keyboardType: TextInputType.phone,
                //   decoration: const InputDecoration(labelText: 'Phone Number'),
                //   validator: (v) =>
                //   (v != null && v.length >= 10) ? null : 'Enter valid phone number',
                // ),
                // const SizedBox(height: 12),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                  (v != null && v.length >= 6) ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 20),

                // Sign Up button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _handleSignup,
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 12),

                // Link back to Login
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
