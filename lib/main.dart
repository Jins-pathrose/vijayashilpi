import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/Controller/Homepage/bloc/home_bloc.dart';
import 'package:vijay_shilpi/Controller/Homepage/bloc/home_event.dart';
import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_bloc.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_bloc.dart';
import 'package:vijay_shilpi/View/Screens/HomePage/home_page.dart';
import 'package:vijay_shilpi/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance(); // Initialize SharedPreferences

  runApp(MyApp(sharedPreferences: sharedPreferences)); // Pass it to MyApp
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences}); // Receive SharedPreferences

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignupBloc(AuthService()),
        ),
        BlocProvider(create: (context) => LoginBloc()),
        // BlocProvider(
        //   create: (context) => HomeBloc(
        //     firestore: FirebaseFirestore.instance,
        //     auth: FirebaseAuth.instance,
        //     prefs: sharedPreferences, // Use the initialized prefs
        //   )..add(LoadHomeData()),
        // ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vijay Shilpi',
        home: SplashScreen(),
      ),
    );
  }
}
