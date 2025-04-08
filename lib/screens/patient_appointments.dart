import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  final AppointmentService _appointmentService = AppointmentService();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Appointments")),
      body: user == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<List<AppointmentModel>>(
        stream: _appointmentService.getPatientAppointments(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No appointments found."));
          }

          var appointments = snapshot.data!;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.local_hospital, color: Colors.green),
                  title: Text("Doctor: ${appointment.doctorName}"),
                  subtitle: Text(
                    "Date: ${appointment.date}\nStatus: ${appointment.status}",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _cancelAppointment(context, appointment.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _cancelAppointment(BuildContext context, String appointmentId) async {
    bool confirmCancel = await _showConfirmationDialog(context);
    if (confirmCancel) {
      await _appointmentService.cancelAppointment(appointmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment cancelled successfully")),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Appointment"),
        content: Text("Are you sure you want to cancel this appointment?"),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Yes"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;
  }
}
