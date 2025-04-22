import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed to get email
import 'doctor_dashboard.dart';
import 'patient_dashboard.dart';
import 'doctor_setup_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String uid;
  ProfileSetupScreen(this.uid);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String selectedRole = "Patient";

  void saveProfile() async {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String contact = contactController.text.trim();
    String? email = FirebaseAuth.instance.currentUser?.email;

    // Save to users collection
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
      'name': name,
      'age': age,
      'contact': contact,
      'role': selectedRole,
    });

    if (selectedRole == "Doctor") {
      // Save to doctor collection with additional fields
      await FirebaseFirestore.instance.collection('doctor').doc(widget.uid).set({
        'name': name,
        'email': email ?? '',
        'phone': contact,
        'specialization': "",
        'availableSlots': [],
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DoctorSetupScreen(doctorId: widget.uid)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PatientDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D9EEB), Color(0xFF3C78D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Complete Your Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Contact Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                      items: ["Doctor", "Patient"].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save & Continue",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
}
