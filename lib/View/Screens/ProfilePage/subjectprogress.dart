// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class StudentProgressPage extends StatefulWidget {
//   @override
//   _StudentProgressPageState createState() => _StudentProgressPageState();
// }

// class _StudentProgressPageState extends State<StudentProgressPage> {
//   bool isLoading = true;
//   Map<String, int> subjectProgress = {};
//   List<String> allSubjects = [];
//   String selectedLanguage = 'en';
//   String? studentName;

//   @override
//   void initState() {
//     super.initState();
//     _loadLanguage();
//     _fetchStudentData();
//     _fetchAllSubjects();
//   }

//   Future<void> _loadLanguage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedLanguage = prefs.getString('selected_language') ?? 'en';
//     });
//   }

//   Future<void> _fetchStudentData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         setState(() {
//           isLoading = false;
//         });
//         return;
//       }

//       // Fetch student name
//       DocumentSnapshot studentDoc = await FirebaseFirestore.instance
//           .collection('students_registration')
//           .doc(user.uid)
//           .get();

//       if (studentDoc.exists && studentDoc.data() != null) {
//         setState(() {
//           studentName = studentDoc['name'].toString().toUpperCase();
//         });
//       }

//       // Fetch student progress
//       DocumentSnapshot progressDoc = await FirebaseFirestore.instance
//           .collection('student_progress')
//           .doc(user.uid)
//           .get();

//       if (progressDoc.exists && progressDoc.data() != null) {
//         Map<String, dynamic> data = progressDoc.data() as Map<String, dynamic>;
//         // Filter out non-subject fields like 'last_updated'
//         data.forEach((key, value) {
//           if (key != 'last_updated' && value is int) {
//             subjectProgress[key] = value;
//           }
//         });
//       }

//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching student data: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchAllSubjects() async {
//     try {
//       QuerySnapshot subjectDocs =
//           await FirebaseFirestore.instance.collection('subject').get();

//       List<String> subjects = [];
//       for (var doc in subjectDocs.docs) {
//         String subject = doc.id;
//         subjects.add(subject);
//       }

//       setState(() {
//         allSubjects = subjects;
//       });
//     } catch (e) {
//       print('Error fetching subjects: $e');
//     }
//   }

//   String _getTranslatedText(String label) {
//     if (selectedLanguage == 'ta') {
//       switch (label) {
//         case 'Progress Report':
//           return 'முன்னேற்ற அறிக்கை';
//         case 'Subject Progress':
//           return 'பாடம் முன்னேற்றம்';
//         case 'No progress data available':
//           return 'முன்னேற்ற தரவு இல்லை';
//         case 'Videos watched':
//           return 'பார்த்த வீடியோக்கள்';
//         default:
//           return label;
//       }
//     } else {
//       return label;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(_getTranslatedText('Progress Report')),
//           backgroundColor: Colors.black,
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Combine all subjects with progress data
//     Map<String, int> combinedData = {};
//     for (String subject in allSubjects) {
//       combinedData[subject] = subjectProgress[subject] ?? 0;
//     }

//     // Add any subjects in progress data that might not be in allSubjects
//     subjectProgress.forEach((subject, progress) {
//       if (!combinedData.containsKey(subject)) {
//         combinedData[subject] = progress;
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_getTranslatedText('Progress Report')),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (studentName != null)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Hi, $studentName',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               _getTranslatedText('Subject Progress'),
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           if (combinedData.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Text(
//                   _getTranslatedText('No progress data available'),
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             )
//           else
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: BarChartWidget(subjectProgress: combinedData),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class BarChartWidget extends StatelessWidget {
//   final Map<String, int> subjectProgress;

//   BarChartWidget({required this.subjectProgress});

//   @override
//   Widget build(BuildContext context) {
//     final List<String> subjects = subjectProgress.keys.toList();

//     return Column(
//       children: [
//         Expanded(
//           child: BarChart(
//             BarChartData(
//               alignment: BarChartAlignment.spaceAround,
//               maxY: _getMaxProgress() + 2, // Add some space at the top

//               barTouchData: BarTouchData(
//                 enabled: true,
//                 touchTooltipData: BarTouchTooltipData(
//                   getTooltipColor: (group) => Colors.black
//                       .withOpacity(0.8), // Set tooltip background color
//                   getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                     return BarTooltipItem(
//                       '${subjects[groupIndex]}\n${rod.toY.toInt()} videos',
//                       const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               titlesData: FlTitlesData(
//                 show: true,
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       if (value.toInt() >= 0 &&
//                           value.toInt() < subjects.length) {
//                         return Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Transform.rotate(
//                             angle: 0.5, // Angle in radians (about 30 degrees)
//                             child: Text(
//                               subjects[value.toInt()],
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       return const SizedBox();
//                     },
//                     reservedSize: 40,
//                   ),
//                 ),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       if (value % 1 == 0) {
//                         return Text(
//                           value.toInt().toString(),
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         );
//                       }
//                       return const SizedBox();
//                     },
//                     reservedSize: 30,
//                   ),
//                 ),
//                 topTitles:
//                     AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles:
//                     AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(
//                 show: true,
//                 border: Border.all(color: const Color(0xff37434d), width: 1),
//               ),
//               barGroups: _buildBarGroups(),
//               gridData: FlGridData(
//                 show: true,
//                 horizontalInterval: 1,
//                 drawVerticalLine: false,
//                 getDrawingHorizontalLine: (value) {
//                   return FlLine(
//                     color: Colors.grey.withOpacity(0.3),
//                     strokeWidth: 1,
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Videos watched',
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   double _getMaxProgress() {
//     if (subjectProgress.isEmpty) return 10;
//     return subjectProgress.values.reduce((a, b) => a > b ? a : b).toDouble();
//   }

//   List<BarChartGroupData> _buildBarGroups() {
//     List<BarChartGroupData> groups = [];
//     final List<String> subjects = subjectProgress.keys.toList();

//     for (int i = 0; i < subjects.length; i++) {
//       groups.add(
//         BarChartGroupData(
//           x: i,
//           barRods: [
//             BarChartRodData(
//               toY: subjectProgress[subjects[i]]!.toDouble(),
//               color: _getSubjectColor(i),
//               width: 20,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(6),
//                 topRight: Radius.circular(6),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return groups;
//   }

//   Color _getSubjectColor(int index) {
//     // Create a list of colors for the bars
//     final List<Color> colors = [
//       Colors.blue,
//       Colors.red,
//       Colors.green,
//       Colors.purple,
//       Colors.orange,
//       Colors.teal,
//       Colors.pink,
//       Colors.amber,
//       Colors.cyan,
//       Colors.deepPurple,
//     ];

//     return colors[index % colors.length];
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProgressPage extends StatefulWidget {
  @override
  _StudentProgressPageState createState() => _StudentProgressPageState();
}

class _StudentProgressPageState extends State<StudentProgressPage> {
  bool isLoading = true;
  Map<String, int> subjectProgress = {};
  List<String> allSubjects = [];
  String selectedLanguage = 'en';
  String? studentName;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchStudentData();
    _fetchAllSubjects();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Future<void> _fetchStudentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch student name
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students_registration')
          .doc(user.uid)
          .get();

      if (studentDoc.exists && studentDoc.data() != null) {
        setState(() {
          studentName = studentDoc['name'].toString().toUpperCase();
        });
      }

      // Fetch student progress
      DocumentSnapshot progressDoc = await FirebaseFirestore.instance
          .collection('student_progress')
          .doc(user.uid)
          .get();

      if (progressDoc.exists && progressDoc.data() != null) {
        Map<String, dynamic> data = progressDoc.data() as Map<String, dynamic>;
        // Filter out non-subject fields like 'last_updated'
        data.forEach((key, value) {
          if (key != 'last_updated' && value is int) {
            subjectProgress[key] = value;
          }
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAllSubjects() async {
    try {
      QuerySnapshot subjectDocs =
          await FirebaseFirestore.instance.collection('subject').get();

      List<String> subjects = [];
      for (var doc in subjectDocs.docs) {
        String subject = doc.id;
        subjects.add(subject);
      }

      setState(() {
        allSubjects = subjects;
      });
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  String _getTranslatedText(String label) {
    if (selectedLanguage == 'ta') {
      switch (label) {
        case 'Progress Report':
          return 'முன்னேற்ற அறிக்கை';
        case 'Subject Progress':
          return 'பாடம் முன்னேற்றம்';
        case 'No progress data available':
          return 'முன்னேற்ற தரவு இல்லை';
        case 'Videos watched':
          return 'பார்த்த வீடியோக்கள்';
        default:
          return label;
      }
    } else {
      return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getTranslatedText('Progress Report')),
          backgroundColor: Colors.black,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Use only the subjects that have progress data
    Map<String, int> graphData = Map.from(subjectProgress);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedText('Progress Report')),
        backgroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (studentName != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hi, $studentName',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getTranslatedText('Subject Progress'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (graphData.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _getTranslatedText('No progress data available'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChartWidget(subjectProgress: graphData),
              ),
            ),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, int> subjectProgress;

  BarChartWidget({required this.subjectProgress});

  @override
  Widget build(BuildContext context) {
    final List<String> subjects = subjectProgress.keys.toList();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxProgress() + 2, // Add some space at the top

              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.black
                      .withOpacity(0.8), // Set tooltip background color
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${subjects[groupIndex]}\n${rod.toY.toInt()} videos',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),

              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < subjects.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: 0.5, // Angle in radians (about 30 degrees)
                            child: Text(
                              subjects[value.toInt()],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 30,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              barGroups: _buildBarGroups(),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Videos watched',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  double _getMaxProgress() {
    if (subjectProgress.isEmpty) return 10;
    return subjectProgress.values.reduce((a, b) => a > b ? a : b).toDouble();
  }

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> groups = [];
    final List<String> subjects = subjectProgress.keys.toList();

    for (int i = 0; i < subjects.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: subjectProgress[subjects[i]]!.toDouble(),
              color: _getSubjectColor(i),
              width: 20,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  Color _getSubjectColor(int index) {
    // Create a list of colors for the bars
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepPurple,
    ];

    return colors[index % colors.length];
  }
}