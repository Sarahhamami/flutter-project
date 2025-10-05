import 'package:flutter/material.dart';
import 'package:flutter_application_1/email_service.dart';
import 'package:flutter_application_1/user/otp_verification_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';
import '../repositories/user_repository.dart';
import 'login_page.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _userRepo = UserRepository();

  // Controllers for text fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedRole = 'Patient';
  bool _isLoading = false;
  bool _obscurePassword = true;

  // 🧩 Save user to database
Future<void> _saveUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final email = _emailController.text.trim();

  // 1️⃣ Check if email exists
  if (await _userRepo.userExists(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This email is already registered ❌')),
    );
    setState(() => _isLoading = false);
    return;
  }

  // 2️⃣ Hash password
  final hashedPassword =
      BCrypt.hashpw(_passwordController.text.trim(), BCrypt.gensalt());

  // 3️⃣ Create user map
  final user = {
    'nom': _lastNameController.text.trim(),
    'prenom': _firstNameController.text.trim(),
    'email': email,
    'mot_de_passe': hashedPassword,
    'telephone': _phoneController.text.trim(),
    'adresse': _addressController.text.trim(),
    'sexe': _selectedGender,
    'role': _selectedRole,
    'is_verified': 0, // not verified yet
  };

  // 4️⃣ Generate OTP
  final otp = (DateTime.now().millisecondsSinceEpoch % 1000000)
      .toString()
      .padLeft(6, '0');

  // 5️⃣ Send OTP email
  bool emailSent = await EmailService.sendOtp(email, otp);

  if (!emailSent) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to send OTP ❌')),
    );
    setState(() => _isLoading = false);
    return;
  }

  // 6️⃣ Redirect to OTP page
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => OtpVerificationPage(
        email: email,
        otp: otp,
        user: user,
      ),
    ),
  );

  setState(() => _isLoading = false);
}
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF20c997);
    const blue = Color(0xFF0dcaf0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🩺 Logo
              Image.asset('assets/images/splash.png', height: 120),
              const SizedBox(height: 20),

              Text(
                "Create an Account",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_firstNameController, "First Name"),
              _buildTextField(_lastNameController, "Last Name"),
              _buildTextField(_emailController, "Email",
    type: TextInputType.emailAddress, validator: (val) {
  if (val == null || val.isEmpty) return 'This field is required';
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
  return null;
}),
              _buildPasswordField(_passwordController, "Password"),
              _buildTextField(_phoneController, "Phone",
                  type: TextInputType.phone),
              _buildTextField(_addressController, "Address"),

              const SizedBox(height: 10),

              _buildDropdown(
                label: "Gender",
                value: _selectedGender,
                items: const ['Male', 'Female'],
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),

              _buildDropdown(
                label: "Role",
                value: _selectedRole,
                items: const ['Patient', 'Doctor'],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),

              const SizedBox(height: 25),

              _isLoading
                  ? const CircularProgressIndicator(color: blue)
                  : ElevatedButton(
                      onPressed: _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 80),
                      ),
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Already have an account? "),
    GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
      child: Text(
        "Login",
        style: TextStyle(
          color: blue,
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
    );
  }

Widget _buildTextField(TextEditingController controller, String label,
    {bool obscure = false, TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
  final gray = Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        validator: (val) =>
            val == null || val.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: gray.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
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
          if (val.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: gray.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final gray = Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: gray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
