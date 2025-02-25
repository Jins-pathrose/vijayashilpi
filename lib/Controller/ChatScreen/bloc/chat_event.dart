import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MessageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMessages extends MessageEvent {
  final String currentUserUuid;
  final String studentUuid;

  LoadMessages({required this.currentUserUuid, required this.studentUuid});

  @override
  List<Object> get props => [currentUserUuid, studentUuid];
}

class SendMessage extends MessageEvent {
  final String senderId;
  final String receiverId;
  final String content;

  SendMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object> get props => [senderId, receiverId, content];
}