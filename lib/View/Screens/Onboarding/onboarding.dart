// import 'package:flutter/material.dart';
// import 'package:vijay_shilpi/View/authenticatioin/Login/students_login.dart';
// import 'package:vijay_shilpi/View/Widgets/onboarding/onboarding_footer.dart';
// import 'package:vijay_shilpi/View/Widgets/onboarding/onboarding_page.dart';

// class OnboardingScreen extends StatefulWidget {
//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<Map<String, String>> _onboardingData = [
//     {
//       "title": "Welcome to VIjay Shilpi",
//       "description": "Discover amazing features to improve your knowledge.",
//       "image": "assets/images/download.jpeg",
//     },
//     {
//       "title": "Stay Connected",
//       "description": "Keep in touch with teachers, anytime, anywhere.",
//       "image": "assets/images/download (2).jpeg",
//     },
//     {
//       "title": "Get Started Today",
//       "description": "Join us and experience the future of productivity.",
//       "image": "assets/images/download (3).jpeg",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.red, Colors.yellow], // Gradient colors
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentPage = index;
//                   });
//                 },
//                 itemCount: _onboardingData.length,
//                 itemBuilder: (context, index) {
//                   return OnboardingPage(
//                     title: _onboardingData[index]["title"]!,
//                     description: _onboardingData[index]["description"]!,
//                     image: _onboardingData[index]["image"]!,
//                   );
//                 },
//               ),
//             ),
//             OnboardingFooter(
//               currentPage: _currentPage,
//               pageCount: _onboardingData.length,
//               onSkip: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                 );
//               },
//               onNext: () {
//                 if (_currentPage == _onboardingData.length - 1) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => LoginScreen()),
//                   );
//                 } else {
//                   _pageController.nextPage(
//                     duration: Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/View/authenticatioin/Login/students_login.dart';
import 'package:vijay_shilpi/View/Widgets/onboarding/onboarding_footer.dart';
import 'package:vijay_shilpi/View/Widgets/onboarding/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  final String selectedLanguage;
  OnboardingScreen({required this.selectedLanguage});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Map<String, List<Map<String, String>>> _translations = {
    'en': [
      {
        "title": "Welcome to Vijay Shilpi",
        "description": "Discover amazing features to improve your knowledge.",
        "image": "assets/images/download.jpeg",
      },
      {
        "title": "Stay Connected",
        "description": "Keep in touch with teachers, anytime, anywhere.",
        "image": "assets/images/download (2).jpeg",
      },
      {
        "title": "Get Started Today",
        "description": "Join us and experience the future of productivity.",
        "image": "assets/images/download (3).jpeg",
      },
    ],
    'ta': [
      {
        "title": "விஜய் ஷில்பிக்கு வரவேற்கிறோம்",
        "description":
            "உங்கள் அறிவை மேம்படுத்த அற்புதமான அம்சங்களை கண்டுபிடிக்கவும்.",
        "image": "assets/images/download.jpeg",
      },
      {
        "title": "தொடர்ந்து இணைந்திருங்கள்",
        "description":
            "ஆசிரியர்களுடன் எப்போதும் எங்கு வேண்டுமானாலும் தொடர்பில் இருங்கள்.",
        "image": "assets/images/download (2).jpeg",
      },
      {
        "title": "இன்று தொடங்குங்கள்",
        "description":
            "எங்களைச் சேர்ந்து உற்பத்தித்திறன் மேம்பாட்டை அனுபவிக்கவும்.",
        "image": "assets/images/download (3).jpeg",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> _onboardingData =
        _translations[widget.selectedLanguage] ?? _translations['en']!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red, Colors.yellow],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: _onboardingData[index]["title"]!,
                    description: _onboardingData[index]["description"]!,
                    image: _onboardingData[index]["image"]!,
                  );
                },
              ),
            ),
            OnboardingFooter(
              currentPage: _currentPage,
              pageCount: _onboardingData.length,
              onSkip: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen(selectedLanguage: widget.selectedLanguage),
                  ),
                );
              },
              onNext: () {
                if (_currentPage == _onboardingData.length - 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                          selectedLanguage: widget.selectedLanguage),
                    ),
                  );
                } else {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
