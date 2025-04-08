import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class DatabaseService {
  final CollectionReference patientsCollection =
  FirebaseFirestore.instance.collection('patients');

  // ✅ Add a new patient to Firestore
  Future<void> addPatient(PatientModel patient) async {
    await patientsCollection.doc(patient.id).set(patient.toMap());
  }

  // ✅ Fetch all patients from Firestore
  Future<List<PatientModel>> getPatients() async {
    QuerySnapshot snapshot = await patientsCollection.get();
    return snapshot.docs
        .map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // ✅ Fixed
        .toList();
  }
}
