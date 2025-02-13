// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TeacherProfilePage extends StatefulWidget {
//   final String teacherUuid;

//   const TeacherProfilePage({Key? key, required this.teacherUuid}) : super(key: key);

//   @override
//   _TeacherProfilePageState createState() => _TeacherProfilePageState();
// }

// class _TeacherProfilePageState extends State<TeacherProfilePage> {
//   Map<String, dynamic>? teacherData;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTeacherData();
//   }

//   Future<void> _fetchTeacherData() async {
//     try {
//       DocumentSnapshot teacherDoc = await FirebaseFirestore.instance
//           .collection('teachers_registration')
//           .doc(widget.teacherUuid)
//           .get();

//       if (teacherDoc.exists && teacherDoc.data() != null) {
//         setState(() {
//           teacherData = teacherDoc.data() as Map<String, dynamic>;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           teacherData = null;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         teacherData = null;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching teacher data: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Teacher Profile',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : teacherData == null
//               ? const Center(child: Text('No teacher data found.'))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       /// **Profile Image**
//                       CircleAvatar(
//                         radius: 60,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: teacherData!['image'] != null
//                             ? NetworkImage(teacherData!['image'])
//                             : null,
//                         child: teacherData!['image'] == null
//                             ? const Icon(Icons.person, size: 60, color: Colors.grey)
//                             : null,
//                       ),
//                       const SizedBox(height: 20),

//                       /// **Teacher Name**
//                       Text(
//                         teacherData!['name'] ?? 'No Name',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       /// **Subject**
//                       Text(
//                         teacherData!['subject'] ?? 'No Subject',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 30),

//                       /// **Profile Details**
//                       _buildProfileItem('Email', teacherData!['email'] ?? 'No Email'),
//                       const SizedBox(height: 15),
//                       _buildProfileItem('Phone Number', teacherData!['number'] ?? 'No Number'),
//                       const SizedBox(height: 15),
//                       _buildProfileItem('Class Category', teacherData!['classCategory'] ?? 'Not specified'),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   /// **Reusable Widget for Profile Details**
//   Widget _buildProfileItem(String label, String value) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_bloc.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_event.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_state.dart';

class TeacherProfilePage extends StatelessWidget {
  final String teacherUuid;

  const TeacherProfilePage({Key? key, required this.teacherUuid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeacherProfileBloc()..add(FetchTeacherProfile(teacherUuid)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Teacher Profile',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocConsumer<TeacherProfileBloc, TeacherProfileState>(
          listener: (context, state) {
            if (state is TeacherProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is TeacherProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TeacherProfileLoaded) {
              return _buildProfileContent(state.teacherData);
            } else if (state is TeacherProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No teacher data found.'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> teacherData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: teacherData['image'] != null
                ? NetworkImage(teacherData['image'])
                : null,
            child: teacherData['image'] == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            teacherData['name'] ?? 'No Name',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            teacherData['subject'] ?? 'No Subject',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          _buildProfileItem('Email', teacherData['email'] ?? 'No Email'),
          const SizedBox(height: 15),
          _buildProfileItem('Phone Number', teacherData['number'] ?? 'No Number'),
          const SizedBox(height: 15),
          _buildProfileItem('Class Category', teacherData['classCategory'] ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}