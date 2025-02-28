// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:vijay_shilpi/View/Screens/Chatpage/chat_list.dart';
// import 'package:vijay_shilpi/View/Screens/GeminiAi/gemini_ai.dart';
// import 'package:vijay_shilpi/View/Screens/HomePage/home_page.dart';
// import 'package:vijay_shilpi/View/Screens/ProfilePage/profile_page.dart';
// import 'package:vijay_shilpi/View/Screens/SearchPage/search_page.dart';

// class Bottomnav extends StatefulWidget {
//   const Bottomnav({super.key});

//   @override
//   State<Bottomnav> createState() => _BottomnavState();
// }

// class _BottomnavState extends State<Bottomnav> with TickerProviderStateMixin {
//   int indexNum = 0;
//   String selectedLanguage = 'en';
//   String? studentClass;
//   bool isLoading = true;
//   Razorpay? _razorpay;

//   late List<Widget> screens;
//   late List<AnimationController> _animationControllers;
//   late List<Animation<double>> _animations;

//   @override
//   void initState() {
//     super.initState();
//     _loadSelectedLanguage();
//     _fetchStudentClass();
//     _animationControllers = List.generate(
//       4,
//       (index) => AnimationController(
//         duration: const Duration(milliseconds: 200),
//         vsync: this,
//       ),
//     );
//     _animations = _animationControllers
//         .map(
//           (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
//             CurvedAnimation(parent: controller, curve: Curves.easeInOut),
//           ),
//         )
//         .toList();
//     _animationControllers[0].forward();
//     _razorpay = Razorpay(); // Initialize Razorpay here
//     _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   Future<void> _fetchStudentClass() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot studentDoc = await FirebaseFirestore.instance
//             .collection('students_registration')
//             .doc(user.uid)
//             .get();

//         if (studentDoc.exists && studentDoc.data() != null) {
//           setState(() {
//             studentClass = studentDoc['class']?.toString().trim();
//             isLoading = false;
//             _initializeScreens(); // Initialize screens after getting studentClass
//           });
//         }
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _initializeScreens() {
//     setState(() {
//       screens = [
//         HomePage(),
//         SearchPage(studentClass: studentClass ?? ''), 
//         ChatListScreen(),
//         ProfilePage(),
//       ];
//     });
//   }

//   Future<void> openCheck() async {
//     var options = {
//       'key': 'rzp_test_aaPtOi8SSaUyku', // Replace with your test key
//       'amount': 10000, // Amount in paisa (e.g., 100 rupees = 10000 paisa)
//       'name': 'Vijaya Sirpi',
//       'description': 'Payment for your AI',
//       'prefill': {
//         'contact': '9074267478',
//         'email': 'jinspathrose560@gmail.com'
//       },
//       'external': {
//         'wallets': ['paytm']
//       }
//     };

//     try {
//       _razorpay?.open(options);
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     debugPrint('Payment Success: ${response.paymentId}');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Payment Successful!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//      Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const GeminiChatScreen()),
//                 );
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugPrint(
//         'Error Code: ${response.code}\nError Message: ${response.message}');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Payment Failed: ${response.message}'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugPrint('External Wallet: ${response.walletName}');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('External Wallet Selected: ${response.walletName}'),
//       ),
//     );
//   }

//   Future<void> _loadSelectedLanguage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
//     });
//   }

//   @override
//   void dispose() {
//     for (var controller in _animationControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//     _razorpay!.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (screens == null) {
//       return const Scaffold(
//         body: Center(child: Text('Error loading data')),
//       );
//     }

//     return Scaffold(
//       extendBody: true,
//       bottomNavigationBar: Builder(
//         builder: (newContext) => Container(
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(255, 0, 0, 0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: List.generate(
//                   4,
//                   (index) => _buildNavItem(index, newContext),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//   onPressed: () {
//     openCheck();
//   },
//   elevation: 0,
//   backgroundColor: Colors.transparent,
//   tooltip: 'AI chat', // Tooltip should now work
//   child: Container(
//     width: double.infinity,
//     height: double.infinity,
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           Color.fromARGB(255, 2, 149, 168),
//           Color.fromARGB(255, 2, 149, 168),
//         ],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(30),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.yellow[900]!.withOpacity(0.3),
//           spreadRadius: 2,
//           blurRadius: 8,
//           offset: Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//           Icons.smart_toy_rounded,
//           color: Colors.white,
//           size: 28,
//         ),
//         const SizedBox(height: 4), // Spacing between icon and text
//         const Text(
//           'AI Chat',
//           style: TextStyle(
//             color: Color.fromARGB(255, 255, 255, 255),
//             fontSize: 10, // Small text to fit in FAB
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     ),
//   ),
// ),

//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       body: screens[indexNum],
//     );
//   }

//   Widget _buildNavItem(int index, BuildContext newContext) {
//     final isSelected = indexNum == index;
//     final IconData icon;
//     final String label;

//     switch (index) {
//       case 0:
//         icon = Icons.home_rounded;
//         label = 'Home';
//         break;
//       case 1:
//         icon = Icons.search_rounded;
//         label = 'Search';
//         break;
//       case 2:
//         icon = Icons.chat_bubble_rounded;
//         label = 'Chat';
//         break;
//       case 3:
//         icon = Icons.person_rounded;
//         label = 'Profile';
//         break;
//       default:
//         icon = Icons.home_rounded;
//         label = 'Home';
//     }

//     return GestureDetector(
//       onTap: () {
//         if (indexNum != index) {
//           setState(() {
//             indexNum = index;
//           });
//           _animationControllers[indexNum].forward();
//           for (var i = 0; i < _animationControllers.length; i++) {
//             if (i != indexNum) {
//               _animationControllers[i].reverse();
//             }
//           }
//         }
//       },
//       child: ScaleTransition(
//         scale: _animations[index],
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color.fromARGB(255, 255, 0, 0).withOpacity(0.1)
//                 : const Color.fromARGB(0, 255, 255, 255),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected
//                     ? const Color.fromARGB(255, 255, 0, 0)
//                     : const Color.fromARGB(255, 255, 255, 255),
//                 size: 28,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected
//                       ? const Color.fromARGB(255, 255, 0, 0)
//                       : const Color.fromARGB(255, 255, 255, 255),
//                   fontSize: 12,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vijay_shilpi/View/Screens/Chatpage/chat_list.dart';
import 'package:vijay_shilpi/View/Screens/GeminiAi/gemini_ai.dart';
import 'package:vijay_shilpi/View/Screens/HomePage/home_page.dart';
import 'package:vijay_shilpi/View/Screens/ProfilePage/profile_page.dart';
import 'package:vijay_shilpi/View/Screens/SearchPage/search_page.dart';
import 'package:vijay_shilpi/Model/Homeservice/home_service.dart'; // Import HomeService

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> with TickerProviderStateMixin {
  int indexNum = 0;
  String selectedLanguage = 'en';
  String? studentClass;
  bool isLoading = true;
  Razorpay? _razorpay;
  late HomeService _homeService; // Declare HomeService instance

  late List<Widget> screens;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _homeService = HomeService(); // Initialize HomeService
    _loadSelectedLanguage();
    _fetchStudentClass();
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _animations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();
    _animationControllers[0].forward();
    _razorpay = Razorpay(); // Initialize Razorpay here
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _fetchStudentClass() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('students_registration')
            .doc(user.uid)
            .get();

        if (studentDoc.exists && studentDoc.data() != null) {
          setState(() {
            studentClass = studentDoc['class']?.toString().trim();
            isLoading = false;
            _initializeScreens(); // Initialize screens after getting studentClass
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeScreens() {
    setState(() {
      screens = [
        HomePage(),
        SearchPage(
          studentClass: studentClass ?? '',
          homeService: _homeService, // Pass HomeService to SearchPage
        ),
        ChatListScreen(),
        ProfilePage(),
      ];
    });
  }

  Future<void> openCheck() async {
    var options = {
      'key': 'rzp_test_aaPtOi8SSaUyku', // Replace with your test key
      'amount': 10000, // Amount in paisa (e.g., 100 rupees = 10000 paisa)
      'name': 'Vijaya Sirpi',
      'description': 'Payment for your AI',
      'prefill': {
        'contact': '9074267478',
        'email': 'jinspathrose560@gmail.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GeminiChatScreen(),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        'Error Code: ${response.code}\nError Message: ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
    _razorpay!.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (screens == null) {
      return const Scaffold(
        body: Center(child: Text('Error loading data')),
      );
    }

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Builder(
        builder: (newContext) => Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  4,
                  (index) => _buildNavItem(index, newContext),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCheck();
        },
        elevation: 0,
        backgroundColor: Colors.transparent,
        tooltip: 'AI chat', // Tooltip should now work
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 2, 149, 168),
                Color.fromARGB(255, 2, 149, 168),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow[900]!.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 4), // Spacing between icon and text
              const Text(
                'AI Chat',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 10, // Small text to fit in FAB
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: screens[indexNum],
    );
  }

  Widget _buildNavItem(int index, BuildContext newContext) {
    final isSelected = indexNum == index;
    final IconData icon;
    final String label;

    switch (index) {
      case 0:
        icon = Icons.home_rounded;
        label = 'Home';
        break;
      case 1:
        icon = Icons.search_rounded;
        label = 'Search';
        break;
      case 2:
        icon = Icons.chat_bubble_rounded;
        label = 'Chat';
        break;
      case 3:
        icon = Icons.person_rounded;
        label = 'Profile';
        break;
      default:
        icon = Icons.home_rounded;
        label = 'Home';
    }

    return GestureDetector(
      onTap: () {
        if (indexNum != index) {
          setState(() {
            indexNum = index;
          });
          _animationControllers[indexNum].forward();
          for (var i = 0; i < _animationControllers.length; i++) {
            if (i != indexNum) {
              _animationControllers[i].reverse();
            }
          }
        }
      },
      child: ScaleTransition(
        scale: _animations[index],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 255, 0, 0).withOpacity(0.1)
                : const Color.fromARGB(0, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color.fromARGB(255, 255, 0, 0)
                    : const Color.fromARGB(255, 255, 255, 255),
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color.fromARGB(255, 255, 0, 0)
                      : const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}