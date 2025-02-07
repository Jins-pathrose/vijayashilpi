
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/View/Bottomnavigation/sudentss_navigation.dart';
import 'package:vijay_shilpi/View/Screens/Onboarding/onboarding.dart';
import 'package:vijay_shilpi/View/Screens/SelectLanguage/language_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  Future<void> _startSplashScreen() async {
    await Future.delayed(const Duration(seconds: 5)); // Wait for 5 seconds

    // Check if user is already logged in
    final user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedLanguage = prefs.getString('selected_language');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => selectedLanguage == null
              ? LanguageScreen() // Show language selection if not set
              : (user != null
                  ? Bottomnav() // Navigate to home if user is logged in
                  : OnboardingScreen(selectedLanguage: selectedLanguage)), // Show onboarding with selected language
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/vijatDP.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 4), // Fade-in effect
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vijaya',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: const AssetImage(
                                  'assets/images/download (4).jpeg'),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Shilpi',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Empowering Creativity',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
