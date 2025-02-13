abstract class TeacherProfileState {}

class TeacherProfileInitial extends TeacherProfileState {}

class TeacherProfileLoading extends TeacherProfileState {}

class TeacherProfileLoaded extends TeacherProfileState {
  final Map<String, dynamic> teacherData;
  TeacherProfileLoaded(this.teacherData);
}

class TeacherProfileError extends TeacherProfileState {
  final String message;
  TeacherProfileError(this.message);
}