import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'doctor_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String role = 'Patient'; // Default role
  int age = 0;

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print("🔹 Registering user as: $role"); // Debugging step

      User? user = await _authService.registerUser(email, password, name, age, phoneNumber, role);

      if (user != null) {
        print("✅ User created! Checking role...");

        if (role.toLowerCase() == "doctor") {
          print("📌 Redirecting to Doctor Setup Screen...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSetupScreen(doctorId: user.uid),
            ),
          );
        } else {
          print("📌 Redirecting to Patient Dashboard...");
          Navigator.pushReplacementNamed(context, "/patient_dashboard");
        }
      } else {
        print("⚠️ Signup failed. User is null.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Create an Account",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 15),
                      _buildTextField("Full Name", Icons.person, (value) => name = value!),
                      _buildTextField("Email", Icons.email, (value) => email = value!, TextInputType.emailAddress),
                      _buildTextField("Password", Icons.lock, (value) => password = value!, TextInputType.text, true),
                      _buildTextField("Phone Number", Icons.phone, (value) => phoneNumber = value!, TextInputType.phone),
                      _buildTextField("Age", Icons.calendar_today, (value) => age = int.parse(value!), TextInputType.number),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: role,
                        items: ["Patient", "Doctor"].map((role) {
                          return DropdownMenuItem(value: role, child: Text(role));
                        }).toList(),
                        onChanged: (value) => setState(() => role = value!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.work, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                        ),
                        child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Already have an account? Login", style: TextStyle(color: Colors.black87, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, Function(String?) onSaved,
      [TextInputType keyboardType = TextInputType.text, bool isObscure = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        obscureText: isObscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onSaved: onSaved,
        validator: (value) {
          if (value!.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
