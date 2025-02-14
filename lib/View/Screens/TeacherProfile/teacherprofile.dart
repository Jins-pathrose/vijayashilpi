import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_bloc.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_event.dart';
import 'package:vijay_shilpi/Controller/Teacherprofile/bloc/teacherprofile_state.dart';
import 'package:vijay_shilpi/View/Screens/Chatpage/chat_page.dart';
import 'package:vijay_shilpi/View/Widgets/TeaceherProfileWidgets/buildprofileitem.dart';

class TeacherProfilePage extends StatelessWidget {
  final String teacherUuid;

  const TeacherProfilePage({Key? key, required this.teacherUuid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TeacherProfileBloc()..add(FetchTeacherProfile(teacherUuid)),
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
              return _buildProfileContent(state.teacherData, context);
            } else if (state is TeacherProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No teacher data found.'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      Map<String, dynamic> teacherData, BuildContext context) {
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
          Buildprofileitem(
              label: 'Email', value: teacherData['email'] ?? 'No Email'),
          const SizedBox(height: 15),
          Buildprofileitem(
              label: 'Phone Number',
              value: teacherData['number'] ?? 'No Number'),
          const SizedBox(height: 15),
          Buildprofileitem(
              label: 'Class Category',
              value: teacherData['classCategory'] ?? 'Not specified'),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              try {
                // Fetch current user UUID from students_registration
                String currentUserUuid = await getCurrentUserUuid();

                // Fetch teacher's name from teachers_registration
                String teacherName = await getTeacherName(teacherUuid);

                // Navigate to MessageScreen with the fetched details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageScreen(
                      currentUserUuid: currentUserUuid,
                      teacherUuid: teacherUuid,
                      teacherName: teacherName,
                    ),
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Message',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
Future<String> getCurrentUserUuid() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw 'No user is currently logged in';
  }

  String userId = user.uid; // Firebase Authentication user ID

  DocumentSnapshot studentDoc = await FirebaseFirestore.instance
      .collection('students_registration')
      .doc(userId)
      .get();

  if (studentDoc.exists) {
    return studentDoc['studentId'];
  } else {
    throw 'Student UUID not found';
  }
}

// Fetch teacher's name using teacherUuid
Future<String> getTeacherName(String teacherUuid) async {
  var docSnapshot = await FirebaseFirestore.instance
      .collection('teachers_registration')
      .doc(teacherUuid)
      .get();

  if (docSnapshot.exists) {
    return docSnapshot['name'] ?? 'Unknown Teacher';
  } else {
    throw 'Teacher not found';
  }
}

}
