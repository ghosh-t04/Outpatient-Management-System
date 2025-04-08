import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_dashboard.dart';
import 'patient_dashboard.dart';
import 'doctor_setup_screen.dart';  // ✅ Import Doctor Setup Screen

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
  String selectedRole = "Patient"; // Default role

  void saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
      'name': nameController.text.trim(),
      'age': ageController.text.trim(),
      'contact': contactController.text.trim(),
      'role': selectedRole,
    });

    if (selectedRole == "Doctor") {
      // ✅ Save doctor details in "doctor" collection with empty fields
      await FirebaseFirestore.instance.collection('doctor').doc(widget.uid).set({
        'specialization': "",
        'availableSlots': [],
      });

      // ✅ Redirect to Doctor Setup Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DoctorSetupScreen(doctorId: widget.uid)),
      );
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PatientDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name")),
            TextField(controller: ageController, decoration: InputDecoration(labelText: "Age")),
            TextField(controller: contactController, decoration: InputDecoration(labelText: "Contact Number")),
            SizedBox(height: 20),

            // Role Selection Dropdown
            DropdownButton<String>(
              value: selectedRole,
              items: ["Doctor", "Patient"].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                setState(() => selectedRole = value!);
              },
            ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: saveProfile, child: Text("Save & Continue")),
          ],
        ),
      ),
    );
  }
}
