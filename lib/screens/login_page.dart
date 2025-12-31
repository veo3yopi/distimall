import 'package:distimall/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredential?> _loginGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final isValid =
        email.toLowerCase() == 'admin@mail.com' && password == 'admin';

    if (isValid) {
      Navigator.of(context).pushReplacementNamed('/root');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau password salah.'),
          backgroundColor: Color(0xFF2F5A3D),
        ),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  void _handleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur Sign Up belum tersedia.'),
        backgroundColor: Color(0xFF2F5A3D),
      ),
    );
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login dengan Google belum tersedia.'),
        backgroundColor: Color(0xFF2F5A3D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront, size: 86, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'DISTY',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tampil Syari Gaya Masa Kini',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _LoginField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _LoginField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF5E8E6F),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LoginButton(
                      label: 'Sign in',
                      onPressed: _handleLogin,
                      isLoading: _isSubmitting,
                    ),
                    _LoginButton(label: 'Sign up', onPressed: _handleSignUp),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white, thickness: 0.6, height: 40),
                Text(
                  'Atau masuk dengan',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final UserCredential = await _loginGoogle();
                    if (UserCredential != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DistyMallApp()),
                      );
                    }
                  },
                  child: Text("Login Google"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Color(0xFF3A5C49)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8FB49E)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 1.4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );
  }
}
