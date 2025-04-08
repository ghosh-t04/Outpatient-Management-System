import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Fetch upcoming appointments for a doctor
  Future<List<AppointmentModel>> getUpcomingAppointments(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'upcoming')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc)) // ✅ Fixed
          .toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  // ✅ Fetch doctor's availability
  Future<bool> getDoctorAvailability(String doctorId) async {
    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(doctorId).get();

      if (docSnapshot.exists) {
        return docSnapshot['isAvailable'] ?? false;
      } else {
        print("Doctor not found!");
        return false;
      }
    } catch (e) {
      print("Error fetching availability: $e");
      return false;
    }
  }

  // ✅ Update doctor's availability
  Future<bool> updateDoctorAvailability(String doctorId, bool availability) async {
    try {
      await _firestore.collection('users').doc(doctorId).update({
        'isAvailable': availability,
      });
      return availability;
    } catch (e) {
      print("Error updating availability: $e");
      return !availability;
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
      print("Error fetching patient details: $e");
    }
    return null;
  }
}
