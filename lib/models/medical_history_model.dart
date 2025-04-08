class MedicalHistoryModel {
  final String id;
  final String patientId;
  final String diagnosis;
  final String treatment;
  final String date;

  MedicalHistoryModel({
    required this.id,
    required this.patientId,
    required this.diagnosis,
    required this.treatment,
    required this.date,
  });

  // ✅ Convert Firestore Document to MedicalHistoryModel
  factory MedicalHistoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return MedicalHistoryModel(
      id: docId,
      patientId: map['patientId'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      treatment: map['treatment'] ?? '',
      date: map['date'] ?? '',
    );
  }

  // ✅ Convert MedicalHistoryModel to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'date': date,
    };
  }
}
