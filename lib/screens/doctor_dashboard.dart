import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore
import '../services/firestore_service.dart';
import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  DoctorDashboardState createState() => DoctorDashboardState();
}

class DoctorDashboardState extends State<DoctorDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<AppointmentModel>>? _appointmentFuture;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Fetch appointments for the current doctor
      _appointmentFuture = _firestoreService.getUpcomingAppointments(currentUser.uid);

      // Fetch availability status
      bool availability = await _firestoreService.getDoctorAvailability(currentUser.uid);
      setState(() {
        _isAvailable = availability;
      });
    }
  }

  Future<void> _toggleAvailability() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      bool updatedAvailability = await _firestoreService.updateDoctorAvailability(currentUser.uid, !_isAvailable);
      setState(() {
        _isAvailable = updatedAvailability;
      });
    }
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    await _firestoreService.updateAppointmentStatus(appointmentId, newStatus);
  }

  String _formatDate(dynamic rawDate) {
    try {
      if (rawDate is Timestamp) {
        return DateFormat('MMMM d, y – h:mm a').format(rawDate.toDate());
      } else if (rawDate is String) {
        return DateFormat('MMMM d, y – h:mm a').format(DateTime.parse(rawDate));
      } else {
        return rawDate.toString();
      }
    } catch (e) {
      return rawDate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upcoming Appointments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: _appointmentFuture == null
                  ? Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<AppointmentModel>>(
                future: _appointmentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No upcoming appointments",
                        style: TextStyle(color: Colors.grey));
                  }

                  final appointments = snapshot.data!;
                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return FutureBuilder<PatientModel?>(
                        future: _firestoreService.getPatientDetails(appointment.patientId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                                title: Text("Loading patient details..."));
                          }
                          if (!snapshot.hasData) {
                            return ListTile(title: Text("Patient not found"));
                          }

                          final patient = snapshot.data!;
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text("Patient: ${patient.name}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text("Date: ${_formatDate(appointment.timeSlot)}"),
                                  Text("Status: ${appointment.status}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (appointment.status != "confirmed" &&
                                      appointment.status != "cancelled")
                                    IconButton(
                                      icon: Icon(Icons.check_circle, color: Colors.green),
                                      tooltip: "Confirm",
                                      onPressed: () {
                                        _updateAppointmentStatus(appointment.id, "confirmed");
                                      },
                                    ),
                                  if (appointment.status != "cancelled")
                                    IconButton(
                                      icon: Icon(Icons.cancel, color: Colors.red),
                                      tooltip: "Cancel",
                                      onPressed: () {
                                        _updateAppointmentStatus(appointment.id, "cancelled");
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _toggleAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAvailable ? Colors.green : Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                child: Text(
                  _isAvailable
                      ? "Available (Click to Set Unavailable)"
                      : "Unavailable (Click to Set Available)",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
