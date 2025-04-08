import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/doctor_dashboard.dart';
import '../screens/patient_dashboard.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _role = "patient";
  bool isLogin = true;

  void handleAuth() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    int age = int.tryParse(_ageController.text.trim()) ?? 0;
    String phoneNumber = _phoneController.text.trim();

    User? user;
    if (isLogin) {
      user = await _authService.loginUser(email, password);
    } else {
      user = await _authService.registerUser(email, password, name, age, phoneNumber, _role);
    }

    if (user != null && mounted) {
      if (_role == "doctor") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DoctorDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PatientDashboard()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("We Care", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/healthcare_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Dark overlay for better contrast
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (!isLogin)
                            _buildTextField(_nameController, "Full Name", Icons.person),
                          _buildTextField(_emailController, "Email", Icons.email),
                          _buildTextField(_passwordController, "Password", Icons.lock, isPassword: true),
                          if (!isLogin)
                            _buildTextField(_ageController, "Age", Icons.calendar_today, isNumber: true),
                          if (!isLogin)
                            _buildTextField(_phoneController, "Phone Number", Icons.phone, isNumber: true),
                          if (!isLogin)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: DropdownButtonFormField<String>(
                                value: _role,
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: ["patient", "doctor"].map((role) {
                                  return DropdownMenuItem(value: role, child: Text(role));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _role = value!);
                                },
                              ),
                            ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: Center(
                              child: Text(
                                isLogin ? "Login" : "Register",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              setState(() => isLogin = !isLogin);
                            },
                            child: Text(
                              isLogin ? "Create an account" : "Already have an account? Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}
