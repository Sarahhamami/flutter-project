import 'package:flutter/material.dart';
import 'package:flutter_application_1/com/articles_display.dart';
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/user/current_user.dart';
import 'package:flutter_application_1/user/forget_password.dart';
import 'package:flutter_application_1/user/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';
import '../repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userRepo = UserRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _userRepo.getUserByEmail(email);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not registered ❌")),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!BCrypt.checkpw(password, user['mot_de_passe'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect password ❌")),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (user['is_verified'] != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your email first ❌")),
      );
      setState(() => _isLoading = false);
      return;
    }
    CurrentUser().setUser(user);
    final prefs = await SharedPreferences.getInstance();
if (_rememberMe) {
  await prefs.setString('remembered_email', email);
} else {
  await prefs.remove('remembered_email');
}
    // ✅ Login successful → go to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ArticlesDisplay()),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0dcaf0);
    const green = Color(0xFF20c997);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/splash.png', height: 120),
                const SizedBox(height: 20),
                Text(
                  "Login",
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold, color: blue),
                ),
                const SizedBox(height: 20),
                _buildTextField(_emailController, "Email",
                    type: TextInputType.emailAddress),
                _buildPasswordField(_passwordController, "Password"),
                Row(
  children: [
    Checkbox(
      value: _rememberMe,
      onChanged: (value) {
        setState(() {
          _rememberMe = value!;
        });
      },
    ),
    const Text("Remember Me"),
  ],
),
                const SizedBox(height: 25),
            _isLoading
    ? const CircularProgressIndicator(color: blue)
    : ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            padding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 80),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Text(
          "Login",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
const SizedBox(height: 10),

// ✅ Add this forgot password link
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ForgotPasswordEmailPage(),
        ),
      );
    },
    child: const Text(
      "Forgot Password?",
      style: TextStyle(color: Color(0xFF0dcaf0)),
    ),
  ),
),

const SizedBox(height: 15),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Don't have an account? "),
    GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignUpPage()),
        );
      },
      child: Text(
        "Sign Up",
        style: TextStyle(
          color: const Color(0xFF0dcaf0),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  ],
),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType type = TextInputType.text}) {
    final gray = Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (val) =>
            val == null || val.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: gray.withOpacity(0.2),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    final gray = Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: _obscurePassword,
        validator: (val) {
          if (val == null || val.isEmpty) return 'This field is required';
          if (val.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: gray.withOpacity(0.2),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }
}
