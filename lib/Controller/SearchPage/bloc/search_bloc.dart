import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_event.dart';
import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<LoadTeachersEvent>(_onLoadTeachers);
    on<FilterTeachersEvent>(_onFilterTeachers);
  }

  Future<void> _onLoadLanguage(LoadLanguageEvent event, Emitter<SearchState> emit) async {
    // Get language from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('selected_language') ?? 'en';

    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(selectedLanguage: language));
    } else {
      // In case teachers are not yet loaded, we start with empty values.
      emit(SearchLoaded(
        allTeachers: [],
        filteredTeachers: [],
        subjects: [],
        selectedLanguage: language,
        selectedSubject: null,
        searchQuery: '',
      ));
    }
  }

  Future<void> _onLoadTeachers(LoadTeachersEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final QuerySnapshot teacherSnapshot = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .get();

      final Set<String> uniqueSubjects = {};
      final List<Map<String, dynamic>> teachers = teacherSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final subject = data['subject'] as String? ?? 'Unknown';
        uniqueSubjects.add(subject);
        
        return {
          'uuid': doc.id,
          'name': data['name'] ?? '',
          'subject': subject,
        };
      }).toList();
      
      final List<String> subjects = uniqueSubjects.toList()..sort();

      // Initially filtered list equals all teachers.
      final loadedState = SearchLoaded(
        allTeachers: teachers,
        filteredTeachers: teachers,
        subjects: subjects,
        selectedLanguage: 'en',
        selectedSubject: null,
        searchQuery: '',
      );
      emit(loadedState);
      
      // Also load language
      add(LoadLanguageEvent());
    } catch (e) {
      emit(SearchError('Error loading teachers: $e'));
    }
  }

  void _onFilterTeachers(FilterTeachersEvent event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      final query = event.query;
      final subject = event.subject;
      
      final filtered = currentState.allTeachers.where((teacher) {
        final matchesName = teacher['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
            
        final matchesSubject = subject == null || teacher['subject'] == subject;
        return matchesName && matchesSubject;
      }).toList();
      
      emit(currentState.copyWith(
        filteredTeachers: filtered,
        searchQuery: query,
        selectedSubject: subject,
      ));
    }
  }
}