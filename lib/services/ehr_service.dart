import 'package:cloud_firestore/cloud_firestore.dart';

class EHRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update a patient's medical record
  Future<void> addOrUpdateRecord(String patientId, Map<String, dynamic> recordData) async {
    try {
      await _firestore.collection("medical_records").doc(patientId).set(recordData, SetOptions(merge: true));
    } catch (e) {
      print("Error updating record: $e");
    }
  }

  // Fetch a patient's medical history
  Stream<DocumentSnapshot> getPatientRecords(String patientId) {
    return _firestore.collection("medical_records").doc(patientId).snapshots();
  }
}
