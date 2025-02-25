import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MessageState extends Equatable {
  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final Stream<QuerySnapshot> messagesStream;

  MessageLoaded(this.messagesStream);

  @override
  List<Object> get props => [messagesStream];
}

class MessageSending extends MessageState {}

class MessageSent extends MessageState {}

class MessageError extends MessageState {
  final String error;

  MessageError(this.error);

  @override
  List<Object> get props => [error];
}
class MessageSendingWithMessages extends MessageState {
  final Stream<QuerySnapshot> messagesStream;

  MessageSendingWithMessages(this.messagesStream);

  @override
  List<Object> get props => [messagesStream];
}