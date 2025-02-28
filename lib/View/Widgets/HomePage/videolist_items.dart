import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Model/Homeservice/home_service.dart';
import 'package:vijay_shilpi/View/Screens/TeacherProfile/teacherprofile.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';

class VideoListItem extends StatelessWidget {
  final Map<String, dynamic> video;
  final HomeService homeService;
  final String Function(String) getTranslatedText;
  final void Function(String) showMessage;

  const VideoListItem({
    Key? key,
    required this.video,
    required this.homeService,
    required this.getTranslatedText,
    required this.showMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: homeService.getTeacherName(video['teacher_uuid'] ?? ''),
      builder: (context, teacherSnapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
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
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: video['thumbnail_url'] != null
                          ? Image.network(
                              video['thumbnail_url'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error, size: 40),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.video_library, size: 40),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Content - Teacher & Chapter info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                getTranslatedText("Teacher:"),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${teacherSnapshot.data ?? 'Loading...'}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            video['chapter'] ?? "No Title",
                            style: GoogleFonts.poppins(
                              fontStyle: FontStyle.normal,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Watch now button
                    ElevatedButton(
                      onPressed: () {
                        homeService.trackSubjectProgress(video, showMessage);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(video: video),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        getTranslatedText('Watch now'),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}