import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, String> teacherNames = {};

  Future<Map<String, dynamic>> fetchStudentClass() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'hasError': true, 'studentClass': null, 'studentName': null};
      }

      DocumentSnapshot studentDoc = await _firestore
          .collection('students_registration')
          .doc(user.uid)
          .get();

      if (studentDoc.exists && studentDoc.data() != null) {
        String? studentName = studentDoc['name']?.toString().toUpperCase();
        String? studentClass = studentDoc['class']?.toString().trim();

        if (studentClass != null) {
          return {
            'hasError': false,
            'studentClass': studentClass,
            'studentName': studentName
          };
        }
      }
      return {'hasError': true, 'studentClass': null, 'studentName': null};
    } catch (e) {
      return {'hasError': true, 'studentClass': null, 'studentName': null};
    }
  }

  Future<String> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_language') ?? 'en';
  }

  Future<String> getTeacherName(String teacherUuid) async {
    if (teacherNames.containsKey(teacherUuid)) {
      return teacherNames[teacherUuid]!;
    }

    try {
      DocumentSnapshot teacherDoc = await _firestore
          .collection('teachers_registration')
          .doc(teacherUuid)
          .get();

      if (teacherDoc.exists && teacherDoc.data() != null) {
        String teacherName = teacherDoc['name'] ?? 'Unknown Teacher';
        teacherNames[teacherUuid] = teacherName;
        return teacherName;
      }
      return 'Unknown Teacher';
    } catch (e) {
      return 'Unknown Teacher';
    }
  }
Future<void> trackSubjectProgress(Map<String, dynamic> video, Function(String) showMessage) async {
  try {
    final user = _auth.currentUser;
    if (user == null) return;

    String teacherUuid = video['teacher_uuid'] ?? '';
    if (teacherUuid.isEmpty) return;

    // Get teacher document to determine the subject
    DocumentSnapshot teacherDoc = await _firestore
        .collection('teachers_registration')
        .doc(teacherUuid)
        .get();

    if (!teacherDoc.exists || teacherDoc.data() == null) return;

    String subject = teacherDoc['subject'] ?? 'unknown';

    // Check history to see if the video is already watched.
    QuerySnapshot historySnapshot = await _firestore
        .collection('history')
        .doc(user.uid)
        .collection('watched_videos')
        .where('chapter', isEqualTo: video['chapter'])
        .where('teacher_uuid', isEqualTo: teacherUuid)
        .get();

    // If the video is already watched, update only the history timestamp.
    if (historySnapshot.docs.isNotEmpty) {
      await _firestore
          .collection('history')
          .doc(user.uid)
          .collection('watched_videos')
          .doc(historySnapshot.docs.first.id)
          .update({
            'timestamp': FieldValue.serverTimestamp(),
          });
      
      // No progress update if video was already watched.
      showMessage('This video has already been watched.');
      return;
    }

    // If the video is not already watched, update progress.
    DocumentSnapshot progressDoc = await _firestore
        .collection('student_progress')
        .doc(user.uid)
        .get();

    Map<String, dynamic> progressData = {};
    if (progressDoc.exists && progressDoc.data() != null) {
      progressData = progressDoc.data() as Map<String, dynamic>;
    }

    int currentProgress = progressData[subject] ?? 0;
    int newProgress = currentProgress + 1;

    await _firestore
        .collection('student_progress')
        .doc(user.uid)
        .set({
          subject: newProgress,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    // Then add a new history record
    await _firestore
        .collection('history')
        .doc(user.uid)
        .collection('watched_videos')
        .add({
          'chapter': video['chapter'],
          'description': video['description'],
          'video_url': video['video_url'],
          'thumbnail_url': video['thumbnail_url'],
          'teacher_uuid': teacherUuid,
          'teacher_name': await getTeacherName(teacherUuid),
          'timestamp': FieldValue.serverTimestamp(),
        });

    showMessage('Your progress in $subject has been updated!');
  } catch (e) {
    print('Error tracking subject progress: $e');
  }
}
}
