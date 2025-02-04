import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_bloc.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_bloc.dart';
import 'package:vijay_shilpi/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignupBloc(AuthService()),
        ),
        BlocProvider(create: (context)=> LoginBloc())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vijay Shilpi',
        home: SplashScreen(),
      ),
    );
  }
}
