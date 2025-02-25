import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Map<String, dynamic>> allTeachers;
  final List<Map<String, dynamic>> filteredTeachers;
  final List<String> subjects;
  final String selectedLanguage;
  final String? selectedSubject;
  final String searchQuery;

  const SearchLoaded({
    required this.allTeachers,
    required this.filteredTeachers,
    required this.subjects,
    required this.selectedLanguage,
    required this.selectedSubject,
    required this.searchQuery,
  });
  
  @override
  List<Object?> get props => [allTeachers, filteredTeachers, subjects, selectedLanguage, selectedSubject, searchQuery];

  SearchLoaded copyWith({
    List<Map<String, dynamic>>? allTeachers,
    List<Map<String, dynamic>>? filteredTeachers,
    List<String>? subjects,
    String? selectedLanguage,
    String? selectedSubject,
    String? searchQuery,
  }) {
    return SearchLoaded(
      allTeachers: allTeachers ?? this.allTeachers,
      filteredTeachers: filteredTeachers ?? this.filteredTeachers,
      subjects: subjects ?? this.subjects,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  
  @override
  List<Object?> get props => [message];
}