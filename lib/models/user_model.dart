class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // "doctor" or "patient"

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // Convert from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }
}
