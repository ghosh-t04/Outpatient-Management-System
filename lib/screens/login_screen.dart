import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_setup_screen.dart';
import 'doctor_dashboard.dart';
import 'patient_dashboard.dart';
import 'medical_history_form_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSignUp = false;
  bool rememberMe = false;

  void handleAuth() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    UserCredential userCredential;

    try {
      if (isSignUp) {
        userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      }

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          String role = userDoc["role"];

          if (role == "Doctor") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DoctorDashboard()));
          } else if (role == "Patient") {
            DocumentSnapshot medicalHistoryDoc = await _firestore.collection('medical_history').doc(user.uid).get();
            if (medicalHistoryDoc.exists) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PatientDashboard()));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MedicalHistoryFormScreen(userId: user.uid)));
            }
          }
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileSetupScreen(user.uid)));
        }
      }
    } catch (e) {
      print("Auth Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE5F1FB), Color(0xFFC6E1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.person, size: 50, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 24),
                    _buildTextField(emailController, "Email", Icons.email),
                    SizedBox(height: 16),
                    _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) => setState(() => rememberMe = value!),
                            ),
                            Text("Remember me", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {}, // TODO: Implement Forgot Password
                          child: Text("Forgot Password?", style: TextStyle(color: Color(0xFF3B82F6))),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B82F6),
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                      child: Text(
                        isSignUp ? "Sign Up" : "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => isSignUp = !isSignUp),
                      child: Text(
                        isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
