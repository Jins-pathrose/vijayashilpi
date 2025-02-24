import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';

class TeacherVideosSection extends StatefulWidget {
  final String teacherUuid;
  final String teacherName;
  final String studentClass;

  const TeacherVideosSection({
    Key? key,
    required this.teacherUuid,
    required this.teacherName,
    required this.studentClass,
  }) : super(key: key);

  @override
  State<TeacherVideosSection> createState() => _TeacherVideosSectionState();
}

class _TeacherVideosSectionState extends State<TeacherVideosSection> {
   @override
  void initState() {
    super.initState();
    _loadLanguage();
  }
  String selectedLanguage = 'en';
  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  String _getTranslatedText(String label) {
    if (selectedLanguage == 'ta') {
      switch (label) {
       case 'Watch now':
          return 'காண';
        default:
          return label;
      }
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('teacher_uuid', isEqualTo: widget.teacherUuid)
          .where('classCategory', isEqualTo: widget.studentClass)
          .where('isapproved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(); // Hide if no videos
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.teacherName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...snapshot.data!.docs.map((doc) {
              final video = doc.data() as Map<String, dynamic>;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: video['thumbnail_url'] != null
                          ? Image.network(
                              video['thumbnail_url'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.video_library, size: 40),
                            ),
                    ),
                    title: Text(
                      video['chapter'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(video: video),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _getTranslatedText('Watch now'),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}