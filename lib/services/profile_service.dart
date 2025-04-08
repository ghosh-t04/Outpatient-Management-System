import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  // Update User Profile (Name)
  Future<void> updateUserProfile(String uid, String name) async {
    try {
      await _firestore.collection("users").doc(uid).update({
        "name": name,
      });
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // ✅ Update Doctor Profile (Specialization & Time Slots)
  Future<void> updateDoctorProfile(String uid, String specialization, List<String> slots) async {
    try {
      await _firestore.collection("doctor").doc(uid).set({  // ✅ Changed from "doctors" to "doctor"
        "specialization": specialization,
        "availableSlots": slots,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating doctor profile: $e");
    }
  }
}