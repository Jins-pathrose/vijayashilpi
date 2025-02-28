import 'package:flutter/material.dart';
import 'package:vijay_shilpi/Model/Homeservice/home_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vijay_shilpi/View/Widgets/HomePage/videolist_items.dart';
import 'package:vijay_shilpi/View/Widgets/HomePage/widgets.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService _homeService = HomeService();
  String? studentClass;
  bool isLoading = true;
  String selectedLanguage = 'en';
  bool hasError = false;
  String? studentname;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    final language = await _homeService.loadLanguage();
    final studentData = await _homeService.fetchStudentClass();

    setState(() {
      selectedLanguage = language;
      hasError = studentData['hasError'];
      studentClass = studentData['studentClass'];
      studentname = studentData['studentName'];
      isLoading = false;
    });
  }

  String _getTranslatedText(String label) {
    if (selectedLanguage == 'ta') {
      switch (label) {
        case 'Hi, ':
          return 'ஹாய்,';
        case '''Let's start learning with''':
          return 'கற்க ஆரம்பிப்போம்';
        case 'VIJAYA SIRPI':
          return 'விஜயா சிற்பி';
        case 'Suggestions...':
          return 'கருத்துகளை...';
        case 'No videos found for your class':
          return 'உங்கள் வகுப்பிற்கு வீடியோக்கள் எதுவும் கிடைக்கவில்லை';
        case 'Teacher:':
          return 'ஆசிரியர்';
        case 'Watch now':
          return 'காண';
        default:
          return label;
      }
    }
    return label;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        floatingActionButton: null,
      );
    }

    if (hasError || studentClass == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Error fetching class data. Please check your internet connection.",
            style: TextStyle(color: Colors.red),
          ),
        ),
        floatingActionButton: null,
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 216, 215, 215),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            studentname: studentname,
            getTranslatedText: _getTranslatedText,
          ),
          SuggestionsText(getTranslatedText: _getTranslatedText),
          _buildVideoList(),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .where('classCategory', isEqualTo: studentClass)
            .where('isapproved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching videos"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(_getTranslatedText(
                    "No videos found for your class")));
          }

          final videos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var video = videos[index].data() as Map<String, dynamic>;
              return VideoListItem(
                video: video,
                homeService: _homeService,
                getTranslatedText: _getTranslatedText,
                showMessage: _showMessage,
              );
            },
          );
        },
      ),
    );
  }
}