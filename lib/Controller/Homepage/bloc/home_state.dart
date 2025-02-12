import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String? studentClass;
  final String? studentName;
  final bool isLoading;
  final bool hasError;
  final String selectedLanguage;
  final Map<String, String> teacherNames;
  final String? errorMessage;

  const HomeState({
    this.studentClass,
    this.studentName,
    this.isLoading = true,
    this.hasError = false,
    this.selectedLanguage = 'en',
    this.teacherNames = const {},
    this.errorMessage,
  });

  HomeState copyWith({
    String? studentClass,
    String? studentName,
    bool? isLoading,
    bool? hasError,
    String? selectedLanguage,
    Map<String, String>? teacherNames,
    String? errorMessage,
  }) {
    return HomeState(
      studentClass: studentClass ?? this.studentClass,
      studentName: studentName ?? this.studentName,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      teacherNames: teacherNames ?? this.teacherNames,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        studentClass,
        studentName,
        isLoading,
        hasError,
        selectedLanguage,
        teacherNames,
        errorMessage,
      ];
}