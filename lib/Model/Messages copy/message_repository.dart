import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRepository {
  final FirebaseFirestore _firestore;

  MessageRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMessages(String currentUserUuid, String teacherUuid) {
    List<String> sortedParticipants = [currentUserUuid, teacherUuid]..sort();
    
    return _firestore
        .collection('messages')
        .where('participants', isEqualTo: sortedParticipants)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String content,
    required String senderId,
    required String receiverId,
  }) async {
    List<String> sortedParticipants = [senderId, receiverId]..sort();

    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'participants': sortedParticipants,
      'lastMessage': content,
    });
  }
}