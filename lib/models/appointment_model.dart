import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final Timestamp timeSlot;
  final String status;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.timeSlot,
    required this.status,
  });

  /// ✅ Convert Firestore DocumentSnapshot to AppointmentModel
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final patientId = data['patient_id'] ?? '';
    final doctorId = data['doctor_id'] ?? '';
    final doctorName = data['doctor_name'] ?? '';

    Timestamp timeSlot = Timestamp.now();
    if (data['time_slot'] is Timestamp) {
      timeSlot = data['time_slot'];
    } else {
      debugPrint("⚠️ Warning: Invalid or missing time_slot for doc ${doc.id}");
    }

    // Status: use stored if available, otherwise infer from time
    String status = data['status'] ?? 'Upcoming';
    if (status.toLowerCase() == 'upcoming' && timeSlot.toDate().isBefore(DateTime.now())) {
      status = 'Completed';
    }

    return AppointmentModel(
      id: doc.id,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      timeSlot: timeSlot,
      status: status,
    );
  }

  /// ✅ Convert Map to AppointmentModel (e.g., for testing or non-Firestore sources)
  factory AppointmentModel.fromMap(Map<String, dynamic> data, String id) {
    final patientId = data['patient_id'] ?? '';
    final doctorId = data['doctor_id'] ?? '';
    final doctorName = data['doctor_name'] ?? '';
    final timeSlot = data['time_slot'] is Timestamp ? data['time_slot'] : Timestamp.now();

    String status = data['status'] ?? 'Upcoming';
    if (status.toLowerCase() == 'upcoming' && timeSlot.toDate().isBefore(DateTime.now())) {
      status = 'Completed';
    }

    return AppointmentModel(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      timeSlot: timeSlot,
      status: status,
    );
  }

  /// ✅ Convert AppointmentModel to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'time_slot': timeSlot,
      'status': status,
    };
  }
}
