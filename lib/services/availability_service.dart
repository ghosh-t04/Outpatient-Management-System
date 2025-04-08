import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get available time slots for a doctor
  Future<List<String>> getAvailableSlots(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("doctors").doc(doctorId).get();
      if (doc.exists && doc.data() != null) {
        return List<String>.from(doc["availableSlots"] ?? []);
      }
    } catch (e) {
      print("Error fetching availability: $e");
    }
    return [];
  }

  // Add a new time slot
  Future<void> addSlot(String doctorId, String timeSlot) async {
    try {
      DocumentReference docRef = _firestore.collection("doctors").doc(doctorId);
      await docRef.update({
        "availableSlots": FieldValue.arrayUnion([timeSlot])
      });
    } catch (e) {
      print("Error adding slot: $e");
    }
  }

  // Remove a time slot
  Future<void> removeSlot(String doctorId, String timeSlot) async {
    try {
      DocumentReference docRef = _firestore.collection("doctors").doc(doctorId);
      await docRef.update({
        "availableSlots": FieldValue.arrayRemove([timeSlot])
      });
    } catch (e) {
      print("Error removing slot: $e");
    }
  }
}
