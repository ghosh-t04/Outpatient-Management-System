import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  Future<void> sendMessage(String doctorId, String patientId, String senderId, String message) async {
    String chatRoomId = _getChatRoomId(doctorId, patientId);
    await _firestore.collection("chats").doc(chatRoomId).collection("messages").add({
      "senderId": senderId,
      "message": message,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // Retrieve messages in real-time
  Stream<QuerySnapshot> getMessages(String doctorId, String patientId) {
    String chatRoomId = _getChatRoomId(doctorId, patientId);
    return _firestore.collection("chats").doc(chatRoomId).collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Generate a unique chat room ID
  String _getChatRoomId(String doctorId, String patientId) {
    return doctorId.hashCode <= patientId.hashCode ? "$doctorId\_$patientId" : "$patientId\_$doctorId";
  }
}
