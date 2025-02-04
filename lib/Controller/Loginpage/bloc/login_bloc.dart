import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService = AuthService();
  bool isObscured = true;

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user = await _authService.loginUserWithEmailAndPassword(
          event.email, event.password);
      if (user != null) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure('Login failed. Please try again.'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<LoginState> emit) {
    isObscured = !isObscured;
    emit(LoginPasswordVisibility(isObscured));
  }
}
