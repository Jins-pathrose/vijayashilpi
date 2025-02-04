import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/View/Screens/Chatpage/chat_page.dart';
import 'package:vijay_shilpi/View/Screens/HomePage/home_page.dart';
import 'package:vijay_shilpi/View/Screens/ProfilePage/profile_page.dart';
import 'package:vijay_shilpi/View/Screens/SearchPage/search_page.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> with TickerProviderStateMixin {
  int indexNum = 0;
  String selectedLanguage = 'en'; // Default to English

  late List<Widget> screens;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
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
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
      screens = [
        HomePage(),
        SearchPage(),
        Chatpage(),
        ProfilePage(), // Pass the language
      ];
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
