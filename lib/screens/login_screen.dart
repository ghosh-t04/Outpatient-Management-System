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

          // Check if the role is 'Doctor' or 'Patient'
          if (role == "Doctor") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DoctorDashboard()));
          } else if (role == "Patient") {
            // Check if the patient has completed their medical history in the 'medical_history' collection
            DocumentSnapshot medicalHistoryDoc = await _firestore.collection('medical_history').doc(user.uid).get();
            if (medicalHistoryDoc.exists) {
              // If medical history exists, navigate to the patient dashboard
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PatientDashboard()));
            } else {
              // If medical history doesn't exist, navigate to the form to enter medical history
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
            colors: [Colors.orange.shade400, Colors.purple.shade700],
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
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(Icons.person, size: 50, color: Colors.black54),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(emailController, "Email", Icons.email),
                    SizedBox(height: 15),
                    _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
                    SizedBox(height: 10),
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
                          child: Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade300,
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                      ),
                      child: Text(isSignUp ? "Sign Up" : "Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() => isSignUp = !isSignUp),
                      child: Text(
                        isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
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
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
