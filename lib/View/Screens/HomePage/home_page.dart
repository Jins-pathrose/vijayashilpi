// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String? studentClass;
//   bool isLoading = true;
//   bool hasError = false;
// String? studentname;
//   @override
//   void initState() {
//     super.initState();
//     _fetchStudentClass();
//   }

//   Future<void> _fetchStudentClass() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print("No user logged in.");
//         setState(() {
//           hasError = true;
//           isLoading = false;
//         });
//         return;
//       }

//       print("Fetching student document for UID: ${user.uid}");

//       DocumentSnapshot studentDoc = await FirebaseFirestore.instance
//           .collection('students_registration')
//           .doc(user.uid)
//           .get();

//       if (studentDoc.exists && studentDoc.data() != null) {
//         studentname = studentDoc['name'].toString().toUpperCase();
//         print("Student document found: ${studentDoc.data()}");

//         if (studentDoc['class'] != null) {
//           studentClass = studentDoc['class'].toString().trim();
//           print("Fetched student class: $studentClass");
//           setState(() {
//             isLoading = false;
//           });
//         } else {
//           print("Class field is missing in Firestore document.");
//           setState(() {
//             hasError = true;
//             isLoading = false;
//           });
//         }
//       } else {
//         print("Student document does not exist!");
//         setState(() {
//           hasError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching student class: $e");
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (hasError || studentClass == null) {
//       return Scaffold(
//         body: Center(
//           child: Text(
//             "Error fetching class data. Please check your internet connection.",
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       floatingActionButton: FloatingActionButton(onPressed: (){}, child: Icon(Icons.notifications),),
//       appBar: AppBar(title:  Text("Hi, $studentname ")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('videos')
//             .where('classCategory', isEqualTo: studentClass)
//             .where('isapproved', isEqualTo: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           print("Fetching videos for class: $studentClass");

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             print("Error fetching videos: ${snapshot.error}");
//             return const Center(child: Text("Error fetching videos"));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             print("No videos found for class: $studentClass");
//             return const Center(child: Text("No videos found for your class"));
//           }

//           final videos = snapshot.data!.docs;
//           print("Videos found: ${videos.length}");

//           return ListView.builder(
//             itemCount: videos.length,
//             itemBuilder: (context, index) {
//               var video = videos[index].data() as Map<String, dynamic>;
//               return ListTile(
//                 leading: video['thumbnail_url'] != null
//                     ? Image.network(video['thumbnail_url'],
//                         width: 80, fit: BoxFit.cover)
//                     : const Icon(Icons.video_library, size: 50),
//                 title: Text(video['chapter'] ?? "No Title"),
//                 subtitle: Text(video['description'] ?? "No Description"),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VideoPlayerScreen(video: video),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? studentClass;
  bool isLoading = true;
  bool hasError = false;
  String? studentname;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || studentClass == null) {
      return Scaffold(
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
            padding: EdgeInsets.only(top: 35, left: 5, right: 5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20), // Adjust the radius as needed
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $studentname',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Let’s start learning with',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VIJAYA SHILPI',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
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
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Suggestions...',
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
                  return const Center(
                      child: Text("No videos found for your class"));
                }

                final videos = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    var video = videos[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            video['description'] ?? "No Description",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
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
                              'Watch now',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add notification functionality
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.notifications, color: Colors.white),
      ),
    );
  }
}
