import 'package:flutter/material.dart';
import 'package:flutter_application_1/user/forgot_password_otp_page.dart';
import '../email_service.dart';
import '../repositories/user_repository.dart';

class ForgotPasswordEmailPage extends StatefulWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  State<ForgotPasswordEmailPage> createState() =>
      _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState extends State<ForgotPasswordEmailPage> {
  final _emailController = TextEditingController();
  final _userRepo = UserRepository();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    final user = await _userRepo.getUserByEmail(email);
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email not found ❌')));
      setState(() => _isLoading = false);
      return;
    }

    // Generate OTP
    final otp = (DateTime.now().millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');

    bool emailSent = await EmailService.sendOtp(email, otp);
    if (!emailSent) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to send OTP ❌')));
      setState(() => _isLoading = false);
      return;
    }

    // Go to OTP verification page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordOtpPage(email: email, otp: otp),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0dcaf0);
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password"), backgroundColor: blue),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Enter your email'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: blue)
                : ElevatedButton(
                    onPressed: _sendOtp,
                    style: ElevatedButton.styleFrom(backgroundColor: blue),
                    child: const Text("Send OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
