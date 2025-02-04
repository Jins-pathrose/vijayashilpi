import 'package:flutter/material.dart';
import 'onboarding_dot.dart';

class OnboardingFooter extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingFooter({
    required this.currentPage,
    required this.pageCount,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onSkip,
            child: Text(
              "Skip",
              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 119, 112, 112)),
            ),
          ),
          Row(
            children: List.generate(
              pageCount,
              (index) => OnboardingDot(
                isActive: currentPage == index,
              ),
            ),
          ),
          ElevatedButton(
  onPressed: onNext,
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
  ),
  child: Text(currentPage == pageCount - 1 ? "Get Started" : "Next"),
)

        ],
      ),
    );
  }
}
