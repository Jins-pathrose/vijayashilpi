// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_bloc.dart';
// import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_event.dart';
// import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_state.dart';
// import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';
// import 'package:vijay_shilpi/Model/Validation/validation.dart';
// import 'package:vijay_shilpi/View/Screens/StudentRegistration/Registration.dart';

// class StudentsSignup extends StatefulWidget {
//   const StudentsSignup({Key? key}) : super(key: key);

//   @override
//   State<StudentsSignup> createState() => _StudentsSignupState();
// }

// class _StudentsSignupState extends State<StudentsSignup> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocProvider(
//         create: (_) => SignupBloc(AuthService()),
//         child: BlocListener<SignupBloc, SignupState>(
//           listener: (context, state) {
//             if (state is SignupSuccess) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Sign-up successful!')),
//               );
//               Navigator.pop(context);
//             } else if (state is SignupFailure) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.error)),
//               );
//             }
//           },
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF1E1E1E), Color(0xFF333333)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 80),
//                       Center(
//                         child: Column(
//                           children: [
//                             const Icon(
//                               Icons.person_add_alt_1_rounded,
//                               color: Colors.white,
//                               size: 80,
//                             ),
//                             Text(
//                               'Create Account',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               'Sign up to get started',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 color: Colors.grey[300],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 50),
//                       TextFormField(
//                         validator: (value) =>
//                             ValidationHelper.validateEmail(value),
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           labelStyle: TextStyle(color: Colors.grey[400]),
//                           filled: true,
//                           fillColor: Colors.grey[850],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           prefixIcon:
//                               const Icon(Icons.email, color: Colors.white),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         validator: (value) =>
//                             ValidationHelper.validatePassword(value),
//                         controller: _passwordController,
//                         obscureText: false,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           labelStyle: TextStyle(color: Colors.grey[400]),
//                           filled: true,
//                           fillColor: Colors.grey[850],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           prefixIcon:
//                               const Icon(Icons.lock, color: Colors.white),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         validator: (value) =>
//                             ValidationHelper.validatePassword(value),
//                         controller: _confirmPasswordController,
//                         obscureText: false,
//                         decoration: InputDecoration(
//                           labelText: 'Confirm Password',
//                           labelStyle: TextStyle(color: Colors.grey[400]),
//                           filled: true,
//                           fillColor: Colors.grey[850],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           prefixIcon:
//                               const Icon(Icons.lock, color: Colors.white),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 30),
//                       BlocBuilder<SignupBloc, SignupState>(
//                         builder: (context, state) {
//                           if (state is SignupLoading) {
//                             return const CircularProgressIndicator();
//                           }
//                           return ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 100, vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               backgroundColor: Colors.red[600],
//                             ),
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 final email = _emailController.text.trim();
//                                 final password =
//                                     _passwordController.text.trim();
//                                 final confirmPassword =
//                                     _confirmPasswordController.text.trim();

//                                 if (password != confirmPassword) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content:
//                                             Text('Passwords do not match')),
//                                   );
//                                   return;
//                                 }

//                                 context.read<SignupBloc>().add(
//                                       SignupWithEmailPassword(
//                                           email: email, password: password),
//                                     );
//                                                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FillYourProfileScreen()));

//                               }
//                             },
//                             child: const Text(
//                               'Sign Up',
//                               style:
//                                   TextStyle(fontSize: 18, color: Colors.white),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Already have an account?",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Text(
//                               'Login',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Color.fromARGB(255, 194, 16, 3),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_bloc.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_event.dart';
import 'package:vijay_shilpi/Controller/SignupPage/bloc/signup_state.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';
import 'package:vijay_shilpi/Model/Validation/validation.dart';
import 'package:vijay_shilpi/View/Screens/StudentRegistration/Registration.dart';

class StudentsSignup extends StatefulWidget {
  final String selectedLanguage;
  const StudentsSignup({Key? key, required this.selectedLanguage}) : super(key: key);

  @override
  State<StudentsSignup> createState() => _StudentsSignupState();
}

class _StudentsSignupState extends State<StudentsSignup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Map<String, String> _texts;

  @override
  void initState() {
    super.initState();
    _setLanguageTexts();
  }

  void _setLanguageTexts() {
    if (widget.selectedLanguage == 'ta') {
      _texts = {
        'createAccount': 'கணக்கு உருவாக்கவும்',
        'signupMessage': 'ஆரம்பிக்க பதிவு செய்யவும்',
        'email': 'மின்னஞ்சல்',
        'password': 'கடவுச்சொல்',
        'confirmPassword': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
        'signup': 'பதிவு செய்யவும்',
        'alreadyAccount': 'ஏற்கனவே ஒரு கணக்கு உள்ளதா?',
        'login': 'உள்நுழையவும்',
        'successMessage': 'பதிவு επιτυχής!',
        'passwordMismatch': 'கடவுச்சொற்கள் பொருந்தவில்லை'
      };
    } else {
      _texts = {
        'createAccount': 'Create Account',
        'signupMessage': 'Sign up to get started',
        'email': 'Email',
        'password': 'Password',
        'confirmPassword': 'Confirm Password',
        'signup': 'Sign Up',
        'alreadyAccount': 'Already have an account?',
        'login': 'Login',
        'successMessage': 'Sign-up successful!',
        'passwordMismatch': 'Passwords do not match'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => SignupBloc(AuthService()),
        child: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_texts['successMessage']!)),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FillYourProfileScreen(selectedLanguage: widget.selectedLanguage),
                ),
              );
            } else if (state is SignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF333333)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            Text(
                              _texts['createAccount']!,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _texts['signupMessage']!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFormField(
                        validator: (value) => ValidationHelper.validateEmail(value),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: _texts['email'],
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) => ValidationHelper.validatePassword(value),
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: _texts['password'],
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) => ValidationHelper.validatePassword(value),
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: _texts['confirmPassword'],
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                      BlocBuilder<SignupBloc, SignupState>(
                        builder: (context, state) {
                          if (state is SignupLoading) {
                            return const CircularProgressIndicator();
                          }
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.red[600],
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();
                                final confirmPassword = _confirmPasswordController.text.trim();

                                if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(_texts['passwordMismatch']!)),
                                  );
                                  return;
                                }

                                context.read<SignupBloc>().add(SignupWithEmailPassword(email: email, password: password));
                              }
                            },
                            child: Text(
                              _texts['signup']!,
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_texts['alreadyAccount']!, style: const TextStyle(color: Colors.white)),
                          
                        ],
                      ),
                      TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              _texts['login']!,
                              style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 194, 16, 3)),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
