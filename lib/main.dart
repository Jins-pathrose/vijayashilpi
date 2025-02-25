// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vijay_shilpi/Controller/Homepage/bloc/home_bloc.dart';
// import 'package:vijay_shilpi/Controller/Homepage/bloc/home_event.dart';
// import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_bloc.dart';
// import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_bloc.dart';
// import 'package:vijay_shilpi/splash_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   final SharedPreferences sharedPreferences =
//       await SharedPreferences.getInstance();

//   runApp(MyApp(sharedPreferences: sharedPreferences));
// }

// class MyApp extends StatelessWidget {
//   final SharedPreferences sharedPreferences;

//   const MyApp({super.key, required this.sharedPreferences});

//   @override
//   Widget build(BuildContext context) {
//     final authService = AuthService(); // Create a single instance of AuthService
//     final firestore = FirebaseFirestore.instance;
//     final auth = FirebaseAuth.instance;

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => SignupBloc(authService),
//         ),
//         BlocProvider(
//           create: (context) => LoginBloc(),
//         ),
//         BlocProvider(
//           create: (context) => HomeBloc(
//             firestore: firestore,
//             auth: auth,
//             prefs: sharedPreferences,
//           )..add(LoadHomeData()),
//         ),
        
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Vijay Sirpi',
//         home: SplashScreen(),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/Controller/ChatScreen/bloc/chat_bloc.dart';
import 'package:vijay_shilpi/Controller/GeminiAI/bloc/gemini_bloc.dart';
import 'package:vijay_shilpi/Controller/HistoryPage/bloc/history_bloc.dart';
import 'package:vijay_shilpi/Controller/Homepage/bloc/home_bloc.dart';
import 'package:vijay_shilpi/Controller/Homepage/bloc/home_event.dart';
import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_bloc.dart';
import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_bloc.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_bloc.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_bloc.dart';
import 'package:vijay_shilpi/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}
class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignupBloc(authService),
        ),
        BlocProvider(
          create: (context) => LoginBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
            firestore: firestore,
            auth: auth,
            prefs: sharedPreferences,
          )..add(LoadHomeData()),
        ),
        BlocProvider(
          create: (context) => TeacherProfileBloc(firestore: firestore),
        ),
        BlocProvider(
          create: (context) => MessageBloc(),
        ),
        BlocProvider(
          create: (context) => ChatBloc(),
        ),
        BlocProvider(
          create: (context) => HistoryBloc(),
        ),
         BlocProvider(
          create: (context) => SearchBloc(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vijay Sirpi',
        home: SplashScreen(),
      ),
    );
  }
}
