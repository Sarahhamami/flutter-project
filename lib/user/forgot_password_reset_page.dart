import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import '../repositories/user_repository.dart';
import 'login_page.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  final String email;
  const ForgotPasswordResetPage({super.key, required this.email});

  @override
  State<ForgotPasswordResetPage> createState() =>
      _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _userRepo = UserRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields ❌')));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match ❌')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Hash the new password
      final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
      // Update the password in SQLite
      await _userRepo.updatePassword(widget.email, hashed);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password reset ✅')));

      // Redirect to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e ❌')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0dcaf0);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"), backgroundColor: blue),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: blue)
                : ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(backgroundColor: blue),
                    child: const Text("Reset Password"),
                  ),
          ],
        ),
      ),
    );
  }
}
