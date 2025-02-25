import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vijay_shilpi/Controller/GeminiAI/bloc/gemini_event.dart';
import 'package:vijay_shilpi/Controller/GeminiAI/bloc/gemini_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GenerativeModel _model;
  late ChatSession _chat;

  ChatBloc() : 
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyB_e1PtBGVShO-f6_Ek4lsvHdIjpo9T7Ag',
    ),
    super(ChatInitial()) {
    on<InitializeGeminiEvent>(_onInitializeGemini);
    on<SendMessageEvent>(_onSendMessage);
  }

  void _onInitializeGemini(InitializeGeminiEvent event, Emitter<ChatState> emit) {
    _chat = _model.startChat();
    emit(const ChatLoaded(messages: []));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.message.trim().isEmpty) return;

    final currentState = state;
    if (currentState is ChatLoaded) {
      final updatedMessages = List<ChatMessage>.from(currentState.messages)
        ..add(ChatMessage(text: event.message, isUser: true));
      
      emit(currentState.copyWith(
        messages: updatedMessages,
        isLoading: true,
      ));

      try {
        final response = await _chat.sendMessage(Content.text(event.message));
        final responseText = response.text ?? 'No response';

        final newMessages = List<ChatMessage>.from(updatedMessages)
          ..add(ChatMessage(text: responseText, isUser: false));
        
        emit(currentState.copyWith(
          messages: newMessages,
          isLoading: false,
        ));
      } catch (e) {
        final newMessages = List<ChatMessage>.from(updatedMessages)
          ..add(ChatMessage(text: 'Error: $e', isUser: false));
        
        emit(currentState.copyWith(
          messages: newMessages,
          isLoading: false,
        ));
      }
    }
  }
}