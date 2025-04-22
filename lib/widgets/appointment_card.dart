import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert Timestamp to DateTime and format it
    final dateTime = appointment.timeSlot.toDate();
    final formattedDate = DateFormat('MMM dd, yyyy – hh:mm a').format(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          "Dr. ${appointment.doctorName}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Time: $formattedDate"),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: onTap,
        ),
      ),
    );
  }
}