import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/Model/Homeservice/home_service.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';
import 'package:vijay_shilpi/View/Widgets/HomePage/videolist_items.dart';

class TeacherVideosSection extends StatelessWidget {
  final String teacherUuid;
  final String teacherName;
  final String studentClass;
  final HomeService homeService;
  final String Function(String) getTranslatedText;
  final void Function(String) showMessage;

  const TeacherVideosSection({
    Key? key,
    required this.teacherUuid,
    required this.teacherName,
    required this.studentClass,
    required this.homeService,
    required this.getTranslatedText,
    required this.showMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('teacher_uuid', isEqualTo: teacherUuid)
          .where('classCategory', isEqualTo: studentClass)
          .where('isapproved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(getTranslatedText('Error fetching videos')));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(); // No videos found for this teacher
        }

        final videos = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                teacherName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                var video = videos[index].data() as Map<String, dynamic>;
                return VideoListItem(
                  video: video,
                  homeService: homeService,
                  getTranslatedText: getTranslatedText,
                  showMessage: showMessage,
                );
              },
            ),
          ],
        );
      },
    );
  }
}