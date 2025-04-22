import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class DoctorDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Fetch upcoming appointments for a doctor
  Future<List<AppointmentModel>> getUpcomingAppointments(String doctorId) async {
    List<AppointmentModel> appointments = [];
    try {
      QuerySnapshot query = await _firestore
          .collection("appointments")
          .where("doctorId", isEqualTo: doctorId)
          .where("status", isEqualTo: "Upcoming")
          .orderBy("time_slot", descending: false) // Updated to use time_slot
          .get();

      for (var doc in query.docs) {
        appointments.add(AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)); // ✅ Include document ID
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
    return appointments;
  }

  // ✅ Fetch patient details
  Future<PatientModel?> getPatientDetails(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("patients").doc(patientId).get();
      if (doc.exists) {
        return PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // ✅ Include document ID
      }
    } catch (e) {
      print("Error fetching patient details: $e");
    }
    return null;
  }

  // ✅ Fetch doctor's availability
  Future<bool> getDoctorAvailability(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("doctors").doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)["available"] ?? false;
      }
    } catch (e) {
      print("Error fetching availability: $e");
    }
    return false;
  }

  // ✅ Update doctor's availability
  Future<bool> updateDoctorAvailability(String doctorId, bool newAvailability) async {
    try {
      await _firestore.collection("doctors").doc(doctorId).update({"available": newAvailability});
      print("Doctor availability updated: $newAvailability");
      return newAvailability;
    } catch (e) {
      print("Error updating availability: $e");
    }
    return !newAvailability; // Return previous state if update fails
  }
}
