import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_app_bar.dart';
import 'package:flutter_application_1/repositories/user_repository.dart';
import '../user/current_user.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final userRepo = UserRepository();
  final user = CurrentUser().getUser();

  late TextEditingController prenomController;
  late TextEditingController nomController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;

  @override
  void initState() {
    super.initState();
    prenomController = TextEditingController(text: user?['prenom']);
    nomController = TextEditingController(text: user?['nom']);
    telephoneController = TextEditingController(text: user?['telephone']);
    adresseController = TextEditingController(text: user?['adresse']);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user data")));
    }

    return Scaffold(
     appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("First Name", prenomController),
              _buildField("Last Name", nomController),
              _buildField("Phone", telephoneController),
              _buildField("Address", adresseController),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0DCAF0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await userRepo.updateUser(user!['user_id'], {
                      'prenom': prenomController.text,
                      'nom': nomController.text,
                      'telephone': telephoneController.text,
                      'adresse': adresseController.text,
                    });

                    // Update local user
                    CurrentUser().setUser({
                      ...user!,
                      'prenom': prenomController.text,
                      'nom': nomController.text,
                      'telephone': telephoneController.text,
                      'adresse': adresseController.text,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated!")),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF20C997)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0DCAF0), width: 2),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6C757D)),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        validator: (val) =>
            val!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }
}
