

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';
// import 'package:intl/intl.dart'; 
// class HistoryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return Scaffold(
//         body: Center(
//           child: Text("Please log in to view history."),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("My History",style: TextStyle(color: Colors.white),),
//         backgroundColor: Colors.black,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('history')
//             .doc(user.uid)
//             .collection('watched_videos')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No history available."));
//           }

//           final videos = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: videos.length,
//             itemBuilder: (context, index) {
//               var video = videos[index].data() as Map<String, dynamic>;
//               final timestamp = video['timestamp'] as Timestamp?;
//               final formattedDate = timestamp != null
//                   ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate())
//                   : 'Unknown Date';

//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => VideoPlayerScreen(video: video),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 1,
//                           blurRadius: 3,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: ListTile(
//                       leading: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: video['thumbnail_url'] != null
//                             ? Image.network(video['thumbnail_url'],
//                                 width: 80, height: 80, fit: BoxFit.cover)
//                             : Container(
//                                 width: 80,
//                                 height: 80,
//                                 color: Colors.grey.shade200,
//                                 child: Icon(Icons.video_library, size: 40),
//                               ),
//                       ),
//                       title: Text(
//                         video['chapter'] ?? "No Title",
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.bold,
//                           color: const Color.fromARGB(255, 0, 0, 0),
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             video['teacher_name'] ?? "Unknown Teacher",
//                             style: GoogleFonts.poppins(
//                               fontStyle: FontStyle.normal,
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                             ),
//                           ),
//                           Text(
//                             "Watched on: $formattedDate",
//                             style: GoogleFonts.poppins(
//                               fontStyle: FontStyle.italic,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vijay_shilpi/Controller/HistoryPage/bloc/history_bloc.dart';
import 'package:vijay_shilpi/Controller/HistoryPage/bloc/history_event.dart';
import 'package:vijay_shilpi/Controller/HistoryPage/bloc/history_state.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryBloc()..add(FetchHistoryEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text("My History", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is HistoryError) {
              return Center(child: Text(state.message));
            }

            if (state is HistoryLoaded) {
              if (state.videos.isEmpty) {
                return Center(child: Text("No history available."));
              }

              return ListView.builder(
                itemCount: state.videos.length,
                itemBuilder: (context, index) {
                  var video = state.videos[index];
                  final timestamp = video['timestamp'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate())
                      : 'Unknown Date';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(video: video),
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
                          title: Text(
                            video['chapter'] ?? "No Title",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['teacher_name'] ?? "Unknown Teacher",
                                style: GoogleFonts.poppins(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Watched on: $formattedDate",
                                style: GoogleFonts.poppins(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
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

            return Container();
          },
        ),
      ),
    );
  }
}
