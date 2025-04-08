import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String name;
  final String age;
  final String contact;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.contact,
  });

  // ✅ Convert Firestore document to PatientModel object (with doc.id)
  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      age: data['age'] ?? 'N/A',
      contact: data['contact'] ?? 'N/A',
    );
  }

  // ✅ Convert Map to PatientModel (Fix for DatabaseService)
  factory PatientModel.fromMap(Map<String, dynamic> data, String id) {
    return PatientModel(
      id: id,
      name: data['name'] ?? 'Unknown',
      age: data['age'] ?? 'N/A',
      contact: data['contact'] ?? 'N/A',
    );
  }

  // ✅ Convert a PatientModel object to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'contact': contact,
    };
  }
}
