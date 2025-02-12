import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class UpdateLanguage extends HomeEvent {
  final String language;

  UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class LoadTeacherName extends HomeEvent {
  final String teacherUuid;

  LoadTeacherName(this.teacherUuid);

  @override
  List<Object?> get props => [teacherUuid];
}
