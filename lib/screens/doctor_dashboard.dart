import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchAvailability();
  }

  Future<void> _fetchDashboardData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      List<AppointmentModel> appointments =
      await _firestoreService.getUpcomingAppointments(currentUser.uid);

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailability() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      bool availability =
      await _firestoreService.getDoctorAvailability(currentUser.uid);
      setState(() {
        _isAvailable = availability;
      });
    }
  }

  Future<void> _toggleAvailability() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      bool updatedAvailability = await _firestoreService
          .updateDoctorAvailability(currentUser.uid, !_isAvailable);

      setState(() {
        _isAvailable = updatedAvailability;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Dashboard")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upcoming Appointments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _appointments.isEmpty
                ? Text("No upcoming appointments", style: TextStyle(color: Colors.grey))
                : Column(
              children: _appointments.map((appointment) {
                return FutureBuilder<PatientModel?>(
                  future: _firestoreService.getPatientDetails(appointment.patientId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(title: Text("Loading patient details..."));
                    }
                    if (!snapshot.hasData) {
                      return ListTile(title: Text("Patient not found"));
                    }

                    PatientModel patient = snapshot.data!;
                    return ListTile(
                      title: Text("Patient: ${patient.name}"),
                      subtitle: Text("Date: ${appointment.date}"),
                      trailing: Text(appointment.status,
                          style: TextStyle(color: Colors.green)),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _toggleAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAvailable ? Colors.green : Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _isAvailable ? "Available (Click to Set Unavailable)" : "Unavailable (Click to Set Available)",
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
