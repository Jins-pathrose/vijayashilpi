import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class TeacherProfileEvent {}

class FetchTeacherProfile extends TeacherProfileEvent {
  final String teacherUuid;
  FetchTeacherProfile(this.teacherUuid);
}