import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/Controller/Homepage/bloc/home_event.dart';
import 'package:vijay_shilpi/Controller/Homepage/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;

  HomeBloc({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required SharedPreferences prefs,
  })  : _firestore = firestore,
        _auth = auth,
        _prefs = prefs,
        super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<LoadTeacherName>(_onLoadTeacherName);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(state.copyWith(
          hasError: true,
          isLoading: false,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      final studentDoc = await _firestore
          .collection('students_registration')
          .doc(user.uid)
          .get();

      if (!studentDoc.exists || studentDoc.data() == null) {
        emit(state.copyWith(
          hasError: true,
          isLoading: false,
          errorMessage: 'Student data not found',
        ));
        return;
      }

      final data = studentDoc.data()!;
      final studentName = data['name']?.toString().toUpperCase();
      final studentClass = data['class']?.toString().trim();

      if (studentClass == null) {
        emit(state.copyWith(
          hasError: true,
          isLoading: false,
          errorMessage: 'Class information not found',
        ));
        return;
      }

      // Load saved language
      final savedLanguage = _prefs.getString('selected_language') ?? 'en';

      emit(state.copyWith(
        studentName: studentName,
        studentClass: studentClass,
        isLoading: false,
        selectedLanguage: savedLanguage,
      ));
    } catch (e) {
      emit(state.copyWith(
        hasError: true,
        isLoading: false,
        errorMessage: 'Error loading data: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<HomeState> emit,
  ) async {
    await _prefs.setString('selected_language', event.language);
    emit(state.copyWith(selectedLanguage: event.language));
  }

  Future<void> _onLoadTeacherName(
    LoadTeacherName event,
    Emitter<HomeState> emit,
  ) async {
    if (state.teacherNames.containsKey(event.teacherUuid)) {
      return;
    }

    try {
      final teacherDoc = await _firestore
          .collection('teachers_registration')
          .doc(event.teacherUuid)
          .get();

      if (teacherDoc.exists && teacherDoc.data() != null) {
        final teacherName = teacherDoc.data()!['name'] ?? 'Unknown Teacher';
        final updatedTeacherNames = Map<String, String>.from(state.teacherNames)
          ..addAll({event.teacherUuid: teacherName});

        emit(state.copyWith(teacherNames: updatedTeacherNames));
      }
    } catch (e) {
      // Handle error silently as it's not critical
      final updatedTeacherNames = Map<String, String>.from(state.teacherNames)
        ..addAll({event.teacherUuid: 'Unknown Teacher'});
      emit(state.copyWith(teacherNames: updatedTeacherNames));
    }
  }
}