import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/medical_history_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Fetch Upcoming Appointments
  Future<List<AppointmentModel>> getUpcomingAppointments(String patientId) async {
    List<AppointmentModel> appointments = [];
    try {
      QuerySnapshot query = await _firestore
          .collection("appointments")
          .where("patientId", isEqualTo: patientId)
          .where("status", isEqualTo: "Upcoming")
          .orderBy("date", descending: false)
          .get();

      for (var doc in query.docs) {
        appointments.add(AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
    return appointments;
  }

  // ✅ Fetch Medical History
  Future<List<MedicalHistoryModel>> getMedicalHistory(String patientId) async {
    List<MedicalHistoryModel> history = [];
    try {
      QuerySnapshot query = await _firestore
          .collection("medical_history")
          .where("patientId", isEqualTo: patientId)
          .orderBy("date", descending: true)
          .get();

      for (var doc in query.docs) {
        history.add(MedicalHistoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      }
    } catch (e) {
      print("Error fetching medical history: $e");
    }
    return history;
  }
}
