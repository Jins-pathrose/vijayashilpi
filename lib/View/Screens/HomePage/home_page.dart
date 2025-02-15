
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/View/Screens/TeacherProfile/teacherprofile.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? studentClass;
  bool isLoading = true;
  String selectedLanguage = 'en'; // Default language
  bool hasError = false;
  String? studentname;
  final Map<String, String> teacherNames = {};

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchStudentClass();
  }

  Future<void> _fetchStudentClass() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students_registration')
          .doc(user.uid)
          .get();

      if (studentDoc.exists && studentDoc.data() != null) {
        studentname = studentDoc['name'].toString().toUpperCase();

        if (studentDoc['class'] != null) {
          studentClass = studentDoc['class'].toString().trim();
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en'; // Load saved language
    });
  }

  String _getTranslatedText(String label) {
    // Add translations for Tamil and English
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
    } else {
      // Default to English
      return label;
    }
  }

  Future<String> _getTeacherName(String teacherUuid) async {
    // Check if we already have the teacher name cached
    if (teacherNames.containsKey(teacherUuid)) {
      return teacherNames[teacherUuid]!;
    }

    try {
      DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .doc(teacherUuid)
          .get();

      if (teacherDoc.exists && teacherDoc.data() != null) {
        String teacherName = teacherDoc['name'] ?? 'Unknown Teacher';
        // Cache the teacher name
        teacherNames[teacherUuid] = teacherName;
        return teacherName;
      }
      return 'Unknown Teacher';
    } catch (e) {
      return 'Unknown Teacher';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || studentClass == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Error fetching class data. Please check your internet connection.",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 216, 215, 215),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Section
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

          // Suggestions Section
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

          // Suggestions ListView
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
                      child: Text(
                        _getTranslatedText("No videos found for your class")
                        ));
                }

                final videos = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    var video = videos[index].data() as Map<String, dynamic>;
                    return FutureBuilder<String>(
                      future: _getTeacherName(video['teacher_uuid'] ?? ''),
                      builder: (context, teacherSnapshot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to TeacherProfilePage
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
                                          width: 80, height: 80, fit: BoxFit.cover)
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey.shade200,
                                          child: Icon(Icons.video_library, size: 40),
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
                                            color: const Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                        Text('${teacherSnapshot.data ?? 'Loading...'}')
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
                                      _trackSubjectProgress(video); 
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

// Future<void> _trackSubjectProgress(Map<String, dynamic> video) async {
//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
    
//     // Get teacher_uuid from the video
//     String teacherUuid = video['teacher_uuid'] ?? '';
//     if (teacherUuid.isEmpty) return;
    
//     // Fetch teacher document to get the subject
//     DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
//         .collection('teachers_registration')
//         .doc(teacherUuid)
//         .get();
    
//     if (!teacherDoc.exists || teacherDoc.data() == null) return;
    
//     // Get the subject
//     String subject = teacherDoc['subject'] ?? 'unknown';
    
//     // Get the current progress from Firestore
//     DocumentSnapshot progressDoc = await FirebaseFirestore.instance
//         .collection('student_progress')
//         .doc(user.uid)
//         .get();
    
//     Map<String, dynamic> progressData = {};
//     if (progressDoc.exists && progressDoc.data() != null) {
//       progressData = progressDoc.data() as Map<String, dynamic>;
//     }
    
//     // Get the current subject progress
//     int currentProgress = progressData[subject] ?? 0;
    
//     // Calculate new progress (increment by 1 for each video watched)
//     int newProgress = currentProgress + 1;
    
//     // Update the progress in Firestore
//     await FirebaseFirestore.instance
//         .collection('student_progress')
//         .doc(user.uid)
//         .set({
//           subject: newProgress,
//           'last_updated': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
    
//     // Show a success message or update UI as needed
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Your progress in $subject has been updated!'),
//         duration: Duration(seconds: 2),
//       ),
//     );
    
//   } catch (e) {
//     print('Error tracking subject progress: $e');
//     // Handle error as needed
//   }
// }

Future<void> _trackSubjectProgress(Map<String, dynamic> video) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get teacher_uuid from the video
    String teacherUuid = video['teacher_uuid'] ?? '';
    if (teacherUuid.isEmpty) return;

    // Fetch teacher document to get the subject
    DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
        .collection('teachers_registration')
        .doc(teacherUuid)
        .get();

    if (!teacherDoc.exists || teacherDoc.data() == null) return;

    // Get the subject
    String subject = teacherDoc['subject'] ?? 'unknown';

    // Get the current progress from Firestore
    DocumentSnapshot progressDoc = await FirebaseFirestore.instance
        .collection('student_progress')
        .doc(user.uid)
        .get();

    Map<String, dynamic> progressData = {};
    if (progressDoc.exists && progressDoc.data() != null) {
      progressData = progressDoc.data() as Map<String, dynamic>;
    }

    // Get the current subject progress
    int currentProgress = progressData[subject] ?? 0;

    // Calculate new progress (increment by 1 for each video watched)
    int newProgress = currentProgress + 1;

    // Update the progress in Firestore
    await FirebaseFirestore.instance
        .collection('student_progress')
        .doc(user.uid)
        .set({
          subject: newProgress,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    // Check if the video already exists in the history collection
    QuerySnapshot historySnapshot = await FirebaseFirestore.instance
        .collection('history')
        .doc(user.uid)
        .collection('watched_videos')
        .where('chapter', isEqualTo: video['chapter'])
        .where('teacher_uuid', isEqualTo: video['teacher_uuid'])
        .get();

    if (historySnapshot.docs.isNotEmpty) {
      // Update the existing document with a new timestamp
      await FirebaseFirestore.instance
          .collection('history')
          .doc(user.uid)
          .collection('watched_videos')
          .doc(historySnapshot.docs.first.id)
          .update({
            'timestamp': FieldValue.serverTimestamp(),
          });
    } else {
      // Add a new document to the history collection
      await FirebaseFirestore.instance
          .collection('history')
          .doc(user.uid)
          .collection('watched_videos')
          .add({
            'chapter': video['chapter'],
            'description': video['description'],
            'video_url': video['video_url'],
            'thumbnail_url': video['thumbnail_url'],
            'teacher_uuid': video['teacher_uuid'],
            'teacher_name': await _getTeacherName(video['teacher_uuid'] ?? ''),
            'timestamp': FieldValue.serverTimestamp(),
          });
    }

    // Show a success message or update UI as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your progress in $subject has been updated!'),
        duration: Duration(seconds: 2),
      ),
    );

  } catch (e) {
    print('Error tracking subject progress: $e');
    // Handle error as needed
  }
}
}