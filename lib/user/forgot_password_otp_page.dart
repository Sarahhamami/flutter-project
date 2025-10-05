import 'package:flutter/material.dart';
import 'package:flutter_application_1/user/forgot_password_reset_page.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final String email;
  final String otp;

  const ForgotPasswordOtpPage({super.key, required this.email, required this.otp});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtp() {
    setState(() => _isLoading = true);

    if (_otpController.text.trim() == widget.otp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordResetPage(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP ❌')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0dcaf0);
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP"), backgroundColor: blue),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: blue)
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(backgroundColor: blue),
                    child: const Text("Verify OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
