import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import 'login_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String otp;
  final Map<String, dynamic> user;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.otp,
    required this.user,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _userRepo = UserRepository();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    if (_otpController.text.trim() == widget.otp) {
      // OTP correct → insert user into SQLite
     final verifiedUser = {...widget.user, 'is_verified': 1};
      await _userRepo.insertUser(verifiedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified ✅')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
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
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Enter the 6-digit OTP sent to your email."),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: blue)
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(backgroundColor: blue),
                    child: const Text("Verify"),
                  ),
          ],
        ),
      ),
    );
  }
}
