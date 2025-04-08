import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_dashboard.dart';

class DoctorSetupScreen extends StatefulWidget {
  final String doctorId;
  DoctorSetupScreen({required this.doctorId});

  @override
  _DoctorSetupScreenState createState() => _DoctorSetupScreenState();
}

class _DoctorSetupScreenState extends State<DoctorSetupScreen> {
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController slotsController = TextEditingController();
  List<String> availableSlots = [];

  void saveDoctorProfile() async {
    await FirebaseFirestore.instance.collection('doctor').doc(widget.doctorId).set({
      'specialization': specializationController.text.trim(),
      'availableSlots': availableSlots,
    }, SetOptions(merge: true));

    // ✅ Navigate to Doctor Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DoctorDashboard()),
    );
  }

  void addSlot() {
    if (slotsController.text.trim().isNotEmpty) {
      setState(() {
        availableSlots.add(slotsController.text.trim());
        slotsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Setup")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: specializationController, decoration: InputDecoration(labelText: "Specialization")),

            TextField(controller: slotsController, decoration: InputDecoration(labelText: "Add Time Slot")),

            ElevatedButton(onPressed: addSlot, child: Text("Add Slot")),

            SizedBox(height: 10),
            Text("Available Slots:"),
            Expanded(
              child: ListView.builder(
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(availableSlots[index]));
                },
              ),
            ),

            ElevatedButton(onPressed: saveDoctorProfile, child: Text("Save & Continue")),
          ],
        ),
      ),
    );
  }
}
