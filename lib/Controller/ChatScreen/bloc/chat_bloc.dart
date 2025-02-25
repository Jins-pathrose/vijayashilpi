import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vijay_shilpi/Controller/ChatScreen/bloc/chat_event.dart';
import 'package:vijay_shilpi/Controller/ChatScreen/bloc/chat_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _messagesStream;

  MessageBloc() : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  void _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) {
    try {
      emit(MessageLoading());
      
      // Sort participant IDs to ensure consistent order
      List<String> sortedParticipants = [
        event.currentUserUuid,
        event.studentUuid,
      ]..sort();

      _messagesStream = _firestore
          .collection('messages')
          .where('participants', isEqualTo: sortedParticipants)
          .orderBy('timestamp', descending: false)
          .snapshots();

      emit(MessageLoaded(_messagesStream!));
    } catch (e) {
      emit(MessageError('Failed to load messages: $e'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessageState> emit) async {
    // Only change to MessageSending if we have a current stream
    if (_messagesStream != null) {
      // Create a combined state that has both sending status and messages
      emit(MessageSendingWithMessages(_messagesStream!));
    } else {
      emit(MessageSending());
    }
    
    try {
      // Sort participant IDs to ensure consistent order
      List<String> sortedParticipants = [
        event.senderId,
        event.receiverId,
      ]..sort();

      await _firestore.collection('messages').add({
        'senderId': event.senderId,
        'receiverId': event.receiverId,
        'content': event.content,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': sortedParticipants,
        'lastMessage': event.content,
      });

      // Return to MessageLoaded state if we have a stream
      if (_messagesStream != null) {
        emit(MessageLoaded(_messagesStream!));
      } else {
        emit(MessageSent());
      }
    } catch (e) {
      emit(MessageError('Error sending message: $e'));
    }
  }
}