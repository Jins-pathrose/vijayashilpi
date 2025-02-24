import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Model/Homeservice/home_service.dart';
import 'package:vijay_shilpi/View/Screens/TeacherProfile/teacherprofile.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          Container(
            padding: const EdgeInsets.only(top: 35, left: 5, right: 5),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getTranslatedText('Hi, '),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (' $studentname'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getTranslatedText('''Let's start learning with'''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTranslatedText('VIJAYA SIRPI'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage('assets/images/download (4).jpeg'),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16),
            child: Text(
              _getTranslatedText('Suggestions...'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
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
                    return FutureBuilder<String>(
                      future: _homeService
                          .getTeacherName(video['teacher_uuid'] ?? ''),
                      builder: (context, teacherSnapshot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeacherProfilePage(
                                    teacherUuid: video['teacher_uuid'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: video['thumbnail_url'] != null
                                      ? Image.network(video['thumbnail_url'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover)
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade200,
                                          child: Icon(Icons.video_library,
                                              size: 40),
                                        ),
                                ),
                                title: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          _getTranslatedText("Teacher:"),
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                          ),
                                        ),
                                        Text(
                                            '${teacherSnapshot.data ?? 'Loading...'}')
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  video['chapter'] ?? "No Title",
                                  style: GoogleFonts.poppins(
                                    fontStyle: FontStyle.normal,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _homeService.trackSubjectProgress(
                                        video, _showMessage);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VideoPlayerScreen(video: video),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    _getTranslatedText('Watch now'),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
