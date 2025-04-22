import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

class PatientDashboard extends StatefulWidget {
  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final AppointmentService _appointmentService = AppointmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🏥 Medical history variables
  String medicalCondition = '';
  String medications = '';
  String allergies = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicalHistory();
  }

  // 🔍 Fetch medical history from Firestore
  Future<void> _fetchMedicalHistory() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('medical_history')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            medicalCondition = doc['medicalCondition'] ?? '';
            medications = doc['medications'] ?? '';
            allergies = doc['allergies'] ?? '';
            _isLoading = false;
          });
        } else {
          debugPrint("ℹ️ Medical history not found for user.");
          setState(() => _isLoading = false);
        }
      } catch (e) {
        debugPrint("❌ Error fetching medical history: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  // 🎨 Helper to color-code appointment status
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Patient Dashboard")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchMedicalHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🩺 Medical History
              const Text(
                "Medical History",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInfoRow("Condition", medicalCondition),
              _buildInfoRow("Medications", medications),
              _buildInfoRow("Allergies", allergies),
              const Divider(height: 30),

              // 📅 Upcoming Appointments
              const Text(
                "Upcoming Appointments",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (user != null)
                StreamBuilder<List<AppointmentModel>>(
                  stream: _appointmentService
                      .getPatientAppointmentsStream(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint("❌ Error: ${snapshot.error}");
                      return const SizedBox();
                    }

                    final appointments = snapshot.data ?? [];

                    if (appointments.isEmpty) {
                      return const Text(
                        "No upcoming appointments",
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    return Column(
                      children: appointments.map((appointment) {
                        final formattedDate =
                        DateFormat('MMMM d, y – h:mm a').format(
                            appointment.timeSlot.toDate());

                        return Card(
                          elevation: 2,
                          margin:
                          const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title:
                            Text("Dr. ${appointment.doctorName}"),
                            subtitle: Text("Date: $formattedDate"),
                            trailing: Text(
                              appointment.status,
                              style: TextStyle(
                                color: _statusColor(appointment.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // ➕ Book Appointment Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/book_appointment');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Book Appointment"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // 🔤 Helper for displaying labeled medical fields
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: value.isNotEmpty ? value : 'Not provided',
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
