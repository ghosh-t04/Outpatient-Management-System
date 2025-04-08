import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Book an appointment
  Future<void> bookAppointment(
      String patientId, String doctorId, String doctorName, String dateTime) async {
    try {
      await _firestore.collection("appointments").add({
        "patientId": patientId,
        "doctorId": doctorId,
        "doctorName": doctorName,
        "date": dateTime,
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error booking appointment: $e");
    }
  }

  // ✅ Get upcoming appointments for a specific patient
  Future<List<AppointmentModel>> getUpcomingAppointments(String patientId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("appointments")
          .where("patientId", isEqualTo: patientId)
          .orderBy("timestamp", descending: false)
          .get();

      return querySnapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("❌ Error fetching appointments: $e");
      return [];
    }
  }

  // ✅ Get all appointments for a specific doctor (Real-time)
  Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    return _firestore
        .collection("appointments")
        .where("doctorId", isEqualTo: doctorId)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  // ✅ Fetch appointments for a specific doctor (One-time)
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("appointments")
          .where("doctorId", isEqualTo: doctorId)
          .orderBy("timestamp", descending: false)
          .get();

      return querySnapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("❌ Error fetching doctor's appointments: $e");
      return [];
    }
  }

  // ✅ Get all appointments for a specific patient (Real-time)
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _firestore
        .collection("appointments")
        .where("patientId", isEqualTo: patientId)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  // ✅ Cancel an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection("appointments").doc(appointmentId).delete();
    } catch (e) {
      print("❌ Error canceling appointment: $e");
    }
  }
}
