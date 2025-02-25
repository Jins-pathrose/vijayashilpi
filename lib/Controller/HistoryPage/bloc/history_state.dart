import 'package:equatable/equatable.dart';

abstract class HistoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> videos;

  HistoryLoaded(this.videos);

  @override
  List<Object> get props => [videos];
}

class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);

  @override
  List<Object> get props => [message];
}