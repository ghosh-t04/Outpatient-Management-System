import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Firestore operations
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

class PatientDashboard extends StatefulWidget {
  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final AppointmentService _appointmentService = AppointmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  // Variables to store medical history data
  String medicalCondition = '';
  String medications = '';
  String allergies = '';

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _fetchMedicalHistory(); // Fetch medical history as well
  }

  // ✅ Fetch appointments from Firestore
  Future<void> _fetchAppointments() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        List<AppointmentModel> appointments =
        await _appointmentService.getUpcomingAppointments(currentUser.uid);

        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      } catch (e) {
        print("Error fetching appointments: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ✅ Fetch medical history from Firestore
  Future<void> _fetchMedicalHistory() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot medicalHistoryDoc = await FirebaseFirestore.instance
            .collection('medical_history')
            .doc(currentUser.uid)
            .get();

        if (medicalHistoryDoc.exists) {
          setState(() {
            medicalCondition = medicalHistoryDoc['medicalCondition'] ?? '';
            medications = medicalHistoryDoc['medications'] ?? '';
            allergies = medicalHistoryDoc['allergies'] ?? '';
          });
        }
      } catch (e) {
        print("Error fetching medical history: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Dashboard")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Medical History Section
            const Text(
              "Medical History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Medical Condition: $medicalCondition"),
                Text("Medications: $medications"),
                Text("Allergies: $allergies"),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Upcoming Appointments Section
            const Text(
              "Upcoming Appointments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _appointments.isEmpty
                ? const Text("No upcoming appointments",
                style: TextStyle(color: Colors.grey))
                : Column(
              children: _appointments.map((appointment) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("Dr. ${appointment.doctorName}"),
                    subtitle: Text("Date: ${appointment.date}"),
                    trailing: Text(
                      appointment.status,
                      style: TextStyle(
                          color: appointment.status == "Pending"
                              ? Colors.orange
                              : Colors.green),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ✅ Book Appointment Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/book_appointment');
                },
                child: const Text("Book Appointment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
