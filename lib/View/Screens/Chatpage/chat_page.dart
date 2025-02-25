// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class MessageScreen extends StatefulWidget {
//   final String currentUserUuid;
//   final String teacherUuid;
//   final String teacherName;

//   const MessageScreen({
//     Key? key,
//     required this.currentUserUuid,
//     required this.teacherUuid,
//     required this.teacherName,
//   }) : super(key: key);

//   @override
//   State<MessageScreen> createState() => _MessageScreenState();
// }

// class _MessageScreenState extends State<MessageScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendMessage() async {
//     final String messageText = _messageController.text.trim();
//     if (messageText.isEmpty) return;

//     try {
//       // Sort participant IDs to ensure consistent order
//       List<String> sortedParticipants = [
//         widget.currentUserUuid,
//         widget.teacherUuid,
//       ]..sort(); // This ensures participants are always in the same order

//       await _firestore.collection('messages').add({
//         'senderId': widget.currentUserUuid,
//         'receiverId': widget.teacherUuid,
//         'content': messageText,
//         'timestamp': FieldValue.serverTimestamp(),
//         'participants': sortedParticipants, // Use sorted participants
//         'lastMessage': messageText,
//       });

//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending message: $e')),
//       );
//     }
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.teacherName, style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('messages')
//                   .where('participants',
//                       isEqualTo: [widget.currentUserUuid, widget.teacherUuid]
//                         ..sort())
//                   .orderBy('timestamp', descending: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text("No messages yet"));
//                 }

//                 final messages = snapshot.data!.docs;
//                 DateTime? previousDate;

//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message =
//                         messages[index].data() as Map<String, dynamic>;
//                     final isCurrentUser =
//                         message['senderId'] == widget.currentUserUuid;
//                     final timestamp =
//                         (message['timestamp'] as Timestamp?)?.toDate() ??
//                             DateTime.now();
//                     final currentDate = DateTime(
//                         timestamp.year, timestamp.month, timestamp.day);

//                     // Display date if it's different from the previous message's date
//                     Widget? dateWidget;
//                     if (previousDate == null || previousDate != currentDate) {
//                       dateWidget = Center(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             DateFormat('MMMM d, y').format(currentDate),
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       );
//                       previousDate = currentDate;
//                     }

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         if (dateWidget != null) dateWidget,
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: Row(
//                             mainAxisAlignment: isCurrentUser
//                                 ? MainAxisAlignment.end
//                                 : MainAxisAlignment.start,
//                             children: [
//                               Container(
//                                 constraints: BoxConstraints(
//                                   maxWidth:
//                                       MediaQuery.of(context).size.width * 0.7,
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 10),
//                                 decoration: BoxDecoration(
//                                   color: isCurrentUser
//                                       ? Colors.amber
//                                       : Colors.grey[300],
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: isCurrentUser
//                                       ? CrossAxisAlignment.end
//                                       : CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       message['content'],
//                                       style: TextStyle(
//                                         color: isCurrentUser
//                                             ? Colors.white
//                                             : Colors.black,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       DateFormat('HH:mm').format(timestamp),
//                                       style: TextStyle(
//                                         color: isCurrentUser
//                                             ? Colors.white.withOpacity(0.7)
//                                             : Colors.black54,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                     ),
//                     textCapitalization: TextCapitalization.sentences,
//                     maxLines: null,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.amber,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white),
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vijay_shilpi/Controller/ChatScreen/bloc/chat_bloc.dart';
import 'package:vijay_shilpi/Controller/ChatScreen/bloc/chat_event.dart';
import 'package:vijay_shilpi/Controller/ChatScreen/bloc/chat_state.dart';

class MessageScreen extends StatefulWidget {
  final String currentUserUuid;
  final String teacherUuid;
  final String teacherName;

  const MessageScreen({
    Key? key,
    required this.currentUserUuid,
    required this.teacherUuid,
    required this.teacherName,
  }) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessageBloc _messageBloc;

  @override
  void initState() {
    super.initState();
    _messageBloc = MessageBloc();
    _messageBloc.add(LoadMessages(
      currentUserUuid: widget.currentUserUuid,
      studentUuid: widget.teacherUuid,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageBloc.close();
    super.dispose();
  }

  void _sendMessage() {
    final String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageBloc.add(SendMessage(
      content: messageText,
      senderId: widget.currentUserUuid,
      receiverId: widget.teacherUuid,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _messageBloc,
      child: BlocListener<MessageBloc, MessageState>(
        listener: (context, state) {
          if (state is MessageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(widget.teacherName, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<MessageBloc, MessageState>(
                  builder: (context, state) {
                    if (state is MessageLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MessageError) {
                      return Center(child: Text('Error: ${state.error}'));
                    }

                    if (state is MessageLoaded ||
                        state is MessageSendingWithMessages) {
                      // Get the correct stream based on the state
                      final messagesStream = state is MessageLoaded
                          ? state.messagesStream
                          : (state as MessageSendingWithMessages)
                              .messagesStream;

                      return StreamBuilder<QuerySnapshot>(
                        stream: messagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No messages yet"));
                          }

                          final messages = snapshot.data!.docs;
                          DateTime? previousDate;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index].data()
                                  as Map<String, dynamic>;
                              final isCurrentUser =
                                  message['senderId'] == widget.currentUserUuid;
                              final timestamp =
                                  (message['timestamp'] as Timestamp?)
                                          ?.toDate() ??
                                      DateTime.now();
                              final currentDate = DateTime(timestamp.year,
                                  timestamp.month, timestamp.day);

                              // Display date if it's different from the previous message's date
                              Widget? dateWidget;
                              if (previousDate == null ||
                                  previousDate != currentDate) {
                                dateWidget = Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      DateFormat('MMMM d, y')
                                          .format(currentDate),
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                                previousDate = currentDate;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (dateWidget != null) dateWidget,
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment: isCurrentUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isCurrentUser
                                                ? Colors.amber
                                                : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: isCurrentUser
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message['content'],
                                                style: TextStyle(
                                                  color: isCurrentUser
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('HH:mm')
                                                    .format(timestamp),
                                                style: TextStyle(
                                                  color: isCurrentUser
                                                      ? Colors.white
                                                          .withOpacity(0.7)
                                                      : Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }

                    return const Center(child: Text("Start a conversation"));
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<MessageBloc, MessageState>(
                      builder: (context, state) {
                        final isSending = state is MessageSending ||
                            state is MessageSendingWithMessages;

                        return Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber,
                          ),
                          child: IconButton(
                            icon: state is MessageSending
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: isSending ? null : _sendMessage,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
