import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Book an appointment
  Future<void> bookAppointment(
      String patientId,
      String doctorId,
      String doctorName,
      String dateTime,
      ) async {
    try {
      if (dateTime.trim().isEmpty) {
        throw FormatException("❌ Provided dateTime string is empty");
      }

      print("📅 Received dateTime string: $dateTime");

      DateTime parsedDate = DateTime.tryParse(dateTime) ?? DateTime(1970, 1, 1);
      if (parsedDate.year == 1970) {
        print("⚠️ Warning: Parsed date is defaulting to 1970. Please check format.");
      }

      Timestamp timestamp = Timestamp.fromDate(parsedDate);

      await _firestore.collection("appointments").add({
        "patient_id": patientId,
        "doctor_id": doctorId,
        "doctor_name": doctorName,
        "time_slot": timestamp,
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Appointment booked successfully at $parsedDate");
    } catch (e, stackTrace) {
      print("❌ Error booking appointment: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
    }
  }

  // ✅ Get upcoming appointments for a specific patient (Today onwards)
  Future<List<AppointmentModel>> getUpcomingAppointments(String patientId) async {
    try {
      DateTime now = DateTime.now();
      DateTime todayMidnight = DateTime(now.year, now.month, now.day);
      Timestamp startTimestamp = Timestamp.fromDate(todayMidnight);

      QuerySnapshot querySnapshot = await _firestore
          .collection("appointments")
          .where("patient_id", isEqualTo: patientId)
          .where("time_slot", isGreaterThanOrEqualTo: startTimestamp)
          .orderBy("time_slot")
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      print("❌ Error fetching upcoming appointments: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
      return [];
    }
  }

  // ✅ Real-time: All appointments for a patient
  Stream<List<AppointmentModel>> getPatientAppointmentsStream(String patientId) {
    try {
      return _firestore
          .collection("appointments")
          .where("patient_id", isEqualTo: patientId)
          .orderBy("time_slot")
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
    } catch (e, stackTrace) {
      print("❌ Error in getPatientAppointmentsStream: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
      return const Stream.empty();
    }
  }

  // ✅ Real-time: Get all appointments for a doctor
  Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    try {
      return _firestore
          .collection("appointments")
          .where("doctor_id", isEqualTo: doctorId)
          .orderBy("time_slot")
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
    } catch (e, stackTrace) {
      print("❌ Error in getDoctorAppointmentsStream: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
      return const Stream.empty();
    }
  }

  // ✅ One-time: Get all appointments for a doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("appointments")
          .where("doctor_id", isEqualTo: doctorId)
          .orderBy("time_slot")
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      print("❌ Error fetching doctor's appointments: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
      return [];
    }
  }

  // ✅ Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore.collection("appointments").doc(appointmentId).update({
        "status": status,
      });
    } catch (e, stackTrace) {
      print("❌ Error updating appointment status: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
    }
  }

  // ⚠️ Optional: Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection("appointments").doc(appointmentId).delete();
    } catch (e, stackTrace) {
      print("❌ Error deleting appointment: $e");
      if (e is FirebaseException) {
        print("🔥 FirebaseException [${e.code}]: ${e.message}");
      }
      print("🧵 StackTrace:\n$stackTrace");
    }
  }
}
