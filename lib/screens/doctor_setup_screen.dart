import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'doctor_dashboard.dart';

class DoctorSetupScreen extends StatefulWidget {
  final String doctorId;
  DoctorSetupScreen({required this.doctorId});

  @override
  _DoctorSetupScreenState createState() => _DoctorSetupScreenState();
}

class _DoctorSetupScreenState extends State<DoctorSetupScreen> {
  final TextEditingController specializationController = TextEditingController();
  DateTime? selectedDateTime;
  List<Timestamp> availableSlots = [];

  // Date and Time picker
  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // Add slot to list
  void addSlot() {
    if (selectedDateTime != null) {
      setState(() {
        availableSlots.add(Timestamp.fromDate(selectedDateTime!));
        selectedDateTime = null;
      });
    }
  }

  // Save profile to Firestore
  void saveDoctorProfile() async {
    await FirebaseFirestore.instance.collection('doctor').doc(widget.doctorId).set({
      'specialization': specializationController.text.trim(),
      'availableSlots': availableSlots,
    }, SetOptions(merge: true));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DoctorDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Setup")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Specialization input
            TextField(
              controller: specializationController,
              decoration: InputDecoration(labelText: "Specialization"),
            ),

            SizedBox(height: 16),

            // Date & Time picker
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                selectedDateTime == null
                    ? "Pick Date & Time"
                    : "Picked: ${DateFormat('MMMM d, y – h:mm a').format(selectedDateTime!.toLocal())}",
              ),
            ),

            SizedBox(height: 8),

            ElevatedButton(onPressed: addSlot, child: Text("Add Slot")),

            SizedBox(height: 20),

            // Display added slots
            Text("Available Slots:"),
            Expanded(
              child: ListView.builder(
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  DateTime dt = availableSlots[index].toDate();
                  return ListTile(
                    title: Text(DateFormat('MMMM d, y – h:mm a').format(dt)),
                  );
                },
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveDoctorProfile,
              child: Text("Save & Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
