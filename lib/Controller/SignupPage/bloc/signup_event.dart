import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignupWithEmailPassword extends SignupEvent {
  final String email;
  final String password;

  const SignupWithEmailPassword({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
