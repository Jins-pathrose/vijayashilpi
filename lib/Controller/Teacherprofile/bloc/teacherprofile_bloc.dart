import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_event.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_state.dart';

class TeacherProfileBloc extends Bloc<TeacherProfileEvent, TeacherProfileState> {
  final FirebaseFirestore _firestore;

  TeacherProfileBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(TeacherProfileInitial()) {
    on<FetchTeacherProfile>(_onFetchTeacherProfile);
  }

  Future<void> _onFetchTeacherProfile(
    FetchTeacherProfile event,
    Emitter<TeacherProfileState> emit,
  ) async {
    emit(TeacherProfileLoading());
    try {
      final teacherDoc = await _firestore
          .collection('teachers_registration')
          .doc(event.teacherUuid)
          .get();

      if (teacherDoc.exists && teacherDoc.data() != null) {
        emit(TeacherProfileLoaded(teacherDoc.data()!));
      } else {
        emit(TeacherProfileError('No teacher data found'));
      }
    } catch (e) {
      emit(TeacherProfileError('Error fetching teacher data: $e'));
    }
  }
}