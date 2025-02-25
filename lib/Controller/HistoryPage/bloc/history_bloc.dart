import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vijay_shilpi/Controller/HistoryPage/bloc/history_event.dart';
import 'package:vijay_shilpi/Controller/HistoryPage/bloc/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryLoading()) {
    on<FetchHistoryEvent>(_onFetchHistory);
  }

  void _onFetchHistory(FetchHistoryEvent event, Emitter<HistoryState> emit) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(HistoryError("User not logged in."));
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('history')
          .doc(user.uid)
          .collection('watched_videos')
          .orderBy('timestamp', descending: true)
          .get();

      final videos = querySnapshot.docs.map((doc) => doc.data()).toList();
      emit(HistoryLoaded(videos));
    } catch (e) {
      emit(HistoryError("Failed to fetch history."));
    }
  }
}