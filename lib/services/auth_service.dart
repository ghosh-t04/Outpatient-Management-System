import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Register User
  Future<User?> registerUser(String email, String password, String name, int age, String phoneNumber, String role) async {
    try {
      print("📌 Registering user...");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        print("✅ User created with UID: ${user.uid}");

        // Prepare user data
        Map<String, dynamic> userData = {
          "uid": user.uid,
          "name": name.trim(),
          "age": age,
          "phone": phoneNumber.trim(),
          "email": email.trim(),
          "role": role,
          "createdAt": FieldValue.serverTimestamp(),
        };

        // 🔹 If user is a doctor, add them to "doctor" collection
        if (role.toLowerCase() == "doctor") {
          print("📌 User is a doctor. Adding to 'doctor' collection...");

          userData["specialization"] = ""; // Placeholder
          userData["availableSlots"] = []; // Empty array

          await _firestore.collection("doctor").doc(user.uid).set(userData);
          print("✅ Doctor added to 'doctor' collection successfully!");
        } else {
          // 🔹 If user is a patient, add medical history field
          print("📌 User is a patient. Adding 'medicalHistoryCompleted' field...");
          userData["medicalHistoryCompleted"] = false;
          userData["medicalHistory"] = {
            "allergies": "",
            "chronicDiseases": "",
            "medications": "",
          };

          await _firestore.collection("users").doc(user.uid).set(userData);
          print("✅ Patient added with medical history requirement.");
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("⚠️ Registration Error: ${e.message}");
      return null;
    } catch (e) {
      print("⚠️ Unknown Error during registration: $e");
      return null;
    }
  }

  // 🔹 Login User (Now checks medical history)
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        print("✅ User logged in successfully!");

        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            bool medicalHistoryCompleted = userData["medicalHistoryCompleted"] ?? false;
            if (!medicalHistoryCompleted) {
              print("⚠️ User has NOT completed medical history. Redirect required!");
              // Redirect logic should be implemented in the UI
            } else {
              print("✅ Medical history is completed. Proceeding to dashboard...");
            }
          }
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("⚠️ Login Error: ${e.message}");
      return null;
    } catch (e) {
      print("⚠️ Unknown Error during login: $e");
      return null;
    }
  }

  // 🔹 Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 🔹 Check Medical History Status (Helper method)
  Future<bool> isMedicalHistoryCompleted(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(userId).get();
      if (userDoc.exists) {
        return userDoc["medicalHistoryCompleted"] ?? false;
      }
    } catch (e) {
      print("⚠️ Error checking medical history: $e");
    }
    return false;
  }

  // 🔹 Sign Out
  Future<void> logoutUser() async {
    await _auth.signOut();
    print("✅ User signed out successfully!");
  }
}
