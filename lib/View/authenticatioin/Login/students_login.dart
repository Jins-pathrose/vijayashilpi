

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_bloc.dart';
// import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_event.dart';
// import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_state.dart';
// import 'package:vijay_shilpi/Model/Validation/validation.dart';
// import 'package:vijay_shilpi/View/Bottomnavigation/sudentss_navigation.dart';
// import 'package:vijay_shilpi/View/authenticatioin/Forgotpassword/forgot_password.dart';
// import 'package:vijay_shilpi/View/authenticatioin/SignUp/students_signup.dart';

// class LoginScreen extends StatelessWidget {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocProvider(
//         create: (context) => LoginBloc(),
//         child: BlocConsumer<LoginBloc, LoginState>(listener: (context, state) {
//           if (state is LoginSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Login successful!')),
//             );
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => Bottomnav()),
//               (Route<dynamic> route) => false,
//             );
//           } else if (state is LoginFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage)),
//             );
//           }
//         }, builder: (context, state) {
//           return Container(
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
//                       const SizedBox(height: 100),
//                       Center(
//                         child: Column(
//                           children: [
//                             const Icon(
//                               Icons.person_rounded,
//                               color: Colors.white,
//                               size: 80,
//                             ),
//                             Text(
//                               'Welcome Back!',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               'Login to continue',
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
//                           fillColor: const Color.fromARGB(255, 90, 89, 89),
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
//                         obscureText: state is LoginPasswordVisibility
//                             ? state.isObscured
//                             : true,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           labelStyle: TextStyle(color: Colors.grey[400]),
//                           filled: true,
//                           fillColor: const Color.fromARGB(255, 90, 89, 89),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                           prefixIcon:
//                               const Icon(Icons.lock, color: Colors.white),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               state is LoginPasswordVisibility &&
//                                       state.isObscured
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               context
//                                   .read<LoginBloc>()
//                                   .add(TogglePasswordVisibility());
//                             },
//                           ),
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 20),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const Forgotpass()),
//                             );
//                           },
//                           child: const Text(
//                             'Forgot Password?',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Show CircularProgressIndicator when login is in progress
//                       state is LoginLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 100, vertical: 15),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 backgroundColor: Colors.red[600],
//                               ),
//                               onPressed: state is LoginLoading
//                                   ? null
//                                   : () {
//                                       if (_formKey.currentState!.validate()) {
//                                         context
//                                             .read<LoginBloc>()
//                                             .add(LoginSubmitted(
//                                               _emailController.text.trim(),
//                                               _passwordController.text.trim(),
//                                             ));
//                                       }
//                                     },
//                               child: const Text(
//                                 'Login',
//                                 style: TextStyle(
//                                     fontSize: 18, color: Colors.white),
//                               ),
//                             ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Don't have an account?",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         const StudentsSignup()),
//                               );
//                             },
//                             child: const Text(
//                               'Sign Up',
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
//           );
//         }),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_bloc.dart';
import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_event.dart';
import 'package:vijay_shilpi/Controller/Loginpage/bloc/login_state.dart';
import 'package:vijay_shilpi/Model/Validation/validation.dart';
import 'package:vijay_shilpi/View/Bottomnavigation/sudentss_navigation.dart';
import 'package:vijay_shilpi/View/authenticatioin/Forgotpassword/forgot_password.dart';
import 'package:vijay_shilpi/View/authenticatioin/SignUp/students_signup.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage; // Language passed from language selection screen

  const LoginScreen({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // English and Tamil translations
  Map<String, Map<String, String>> translations = {
    "en": {
      "welcome": "Welcome Back!",
      "login_continue": "Login to continue",
      "email": "Email",
      "password": "Password",
      "forgot_password": "Forgot Password?",
      "login": "Login",
      "no_account": "Don't have an account?",
      "signup": "Sign Up",
      "login_success": "Login successful!",
    },
    "ta": {
      "welcome": "மீண்டும் வருக!",
      "login_continue": "தொடர உங்கள் கணக்கில் உள்நுழையுங்கள்",
      "email": "மின்னஞ்சல்",
      "password": "கடவுச்சொல்",
      "forgot_password": "கடவுச்சொல்லை மறந்துவிட்டீர்களா?",
      "login": "உள்நுழைய",
      "no_account": "கணக்கு இல்லையா?",
      "signup": "பதிவுசெய்",
      "login_success": "உள்நுழைவு வெற்றிகரமாக!",
    }
  };

  @override
  Widget build(BuildContext context) {
    String lang = widget.selectedLanguage; // Get selected language

    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocConsumer<LoginBloc, LoginState>(listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(translations[lang]!["login_success"]!)),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Bottomnav()),
              (Route<dynamic> route) => false,
            );
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        }, builder: (context, state) {
          return Container(
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
                      const SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 80,
                            ),
                            Text(
                              translations[lang]!["welcome"]!,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              translations[lang]!["login_continue"]!,
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
                        validator: (value) =>
                            ValidationHelper.validateEmail(value),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: translations[lang]!["email"]!,
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 90, 89, 89),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            ValidationHelper.validatePassword(value),
                        controller: _passwordController,
                        obscureText: state is LoginPasswordVisibility
                            ? state.isObscured
                            : true,
                        decoration: InputDecoration(
                          labelText: translations[lang]!["password"]!,
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 90, 89, 89),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state is LoginPasswordVisibility &&
                                      state.isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              context
                                  .read<LoginBloc>()
                                  .add(TogglePasswordVisibility());
                            },
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Forgotpass()),
                            );
                          },
                          child: Text(
                            translations[lang]!["forgot_password"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      state is LoginLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.red[600],
                              ),
                              onPressed: state is LoginLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<LoginBloc>()
                                            .add(LoginSubmitted(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            ));
                                      }
                                    },
                              child: Text(
                                translations[lang]!["login"]!,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            translations[lang]!["no_account"]!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StudentsSignup(selectedLanguage: widget.selectedLanguage)),
                              );
                            },
                            child: Text(
                              translations[lang]!["signup"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 194, 16, 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
