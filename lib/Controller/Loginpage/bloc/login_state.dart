import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String errorMessage;

  LoginFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class LoginPasswordVisibility extends LoginState {
  final bool isObscured;

  LoginPasswordVisibility(this.isObscured);

  @override
  List<Object?> get props => [isObscured];
}
