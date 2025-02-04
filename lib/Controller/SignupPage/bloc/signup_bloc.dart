import 'package:bloc/bloc.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_event.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_state.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';



class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthService _authService;

  SignupBloc(this._authService) : super(SignupInitial()) {
    on<SignupWithEmailPassword>(_onSignupWithEmailPassword);
  }

  Future<void> _onSignupWithEmailPassword(
    SignupWithEmailPassword event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(SignupSuccess());
      } else {
        emit(SignupFailure(error: 'Signup failed. Please try again.'));
      }
    } catch (e) {
      emit(SignupFailure(error: e.toString()));
    }
  }
}
