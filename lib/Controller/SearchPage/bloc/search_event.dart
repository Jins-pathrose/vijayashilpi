import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTeachersEvent extends SearchEvent {}

class FilterTeachersEvent extends SearchEvent {
  final String query;
  final String? subject;

  const FilterTeachersEvent({required this.query, required this.subject});
  
  @override
  List<Object?> get props => [query, subject];
}

class LoadLanguageEvent extends SearchEvent {}
