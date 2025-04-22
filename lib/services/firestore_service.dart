import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch upcoming appointments for a doctor
  Future<List<AppointmentModel>> getUpcomingAppointments(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctor_id', isEqualTo: doctorId)  // Use snake_case to match Firestore fields
          .orderBy('time_slot', descending: false) // Correctly order by 'time_slot'
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc)) // Dynamically determine status based on 'time_slot'
          .toList();
    } catch (e) {
      print("❌ Error fetching appointments: $e");
      return [];
    }
  }

  // ✅ Fetch doctor's availability status (whether they are available or not)
  Future<bool> getDoctorAvailability(String doctorId) async {
    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(doctorId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        return data?['isAvailable'] ?? false;  // Use 'isAvailable' field to get availability
      } else {
        print("⚠️ Doctor not found!");
        return false;
      }
    } catch (e) {
      print("❌ Error fetching availability: $e");
      return false;
    }
  }

  // ✅ Update doctor's availability status
  Future<bool> updateDoctorAvailability(String doctorId, bool availability) async {
    try {
      await _firestore.collection('users').doc(doctorId).update({
        'isAvailable': availability,
      });
      return availability;
    } catch (e) {
      print("❌ Error updating availability: $e");
      return !availability; // Optimistically revert
    }
  }

  // ✅ Fetch patient details
  Future<PatientModel?> getPatientDetails(String patientId) async {
    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(patientId).get();

      if (docSnapshot.exists) {
        return PatientModel.fromFirestore(docSnapshot);
      }
    } catch (e) {
      print("❌ Error fetching patient details: $e");
    }
    return null;
  }

  // ✅ Fetch the available time slots for a doctor (array of Timestamps)
  Future<List<Timestamp>> getDoctorAvailableSlots(String doctorId) async {
    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(doctorId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('availableSlots')) {
          // Extract availableSlots as List<Timestamp>
          List<Timestamp> availableSlots = List.from(data['availableSlots'] ?? []);
          return availableSlots;
        }
      }
    } catch (e) {
      print("❌ Error fetching available slots: $e");
    }
    return []; // Return empty list if no available slots or error occurs
  }

  // ✅ Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus});
      print("✅ Appointment status updated to: $newStatus");
    } catch (e) {
      print("❌ Error updating appointment status: $e");
    }
  }
}
