
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
//           title: Text(_getTranslatedText('Progress Report'),style: GoogleFonts.poppins(color: Colors.white),),
//           backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Use only the subjects that have progress data
//     Map<String, int> graphData = Map.from(subjectProgress);

//     return Scaffold(
//        appBar: AppBar(
//           title: Text(_getTranslatedText('Progress Report'),style: GoogleFonts.poppins(color: Colors.white),),
//           backgroundColor: const Color.fromARGB(255, 0, 0, 0),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
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
//           if (graphData.isEmpty)
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
//                 child: BarChartWidget(subjectProgress: graphData),
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

class _StudentProgressPageState extends State<StudentProgressPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  Map<String, int> subjectProgress = {};
  List<String> allSubjects = [];
  String selectedLanguage = 'en';
  String? studentName;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadLanguage();
    _fetchStudentData();
    _fetchAllSubjects();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          title: Text(_getTranslatedText('Progress Report'), style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 4,
            ),
          ),
        ),
      );
    }

    // Use only the subjects that have progress data
    Map<String, int> graphData = Map.from(subjectProgress);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedText('Progress Report'), style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey.shade900,
              Colors.grey.shade100,
            ],
            stops: [0.0, 0.1, 0.3],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (studentName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Hi, $studentName',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.purple.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_graph,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    _getTranslatedText('Subject Progress'),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (graphData.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _getTranslatedText('No progress data available'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: FadeTransition(
                    opacity: _animation,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: EnhancedBarChartWidget(
                        subjectProgress: graphData,
                        animation: _animation,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EnhancedBarChartWidget extends StatelessWidget {
  final Map<String, int> subjectProgress;
  final Animation<double> animation;

  EnhancedBarChartWidget({required this.subjectProgress, required this.animation});

  @override
  Widget build(BuildContext context) {
    final List<String> subjects = subjectProgress.keys.toList();

    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxProgress() + 5,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor: Colors.blueGrey.shade800.withOpacity(0.9),
                      tooltipRoundedRadius: 10,
                      tooltipPadding: EdgeInsets.all(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${subjects[groupIndex]}\n',
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: 'videos',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, BarTouchResponse? response) {},
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < subjects.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Transform.rotate(
                                angle: 0.5,
                                child: Text(
                                  subjects[value.toInt()],
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 45,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 == 0 && value >= 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                      left: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  barGroups: _buildBarGroups(animation.value),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 2,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                ),
                swapAnimationDuration: Duration(milliseconds: 500),
              );
            },
          ),
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ondemand_video,
              color: Colors.blue.shade700,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              _getTranslatedText('Videos watched'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildLegend(),
      ],
    );
  }

  String _getTranslatedText(String text) {
    // Reusing the translation logic from the parent widget
    return text;
  }

  Widget _buildLegend() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Text(
            'Tap bars for details',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxProgress() {
    if (subjectProgress.isEmpty) return 10;
    return subjectProgress.values.reduce((a, b) => a > b ? a : b).toDouble();
  }

  List<BarChartGroupData> _buildBarGroups(double animationValue) {
    List<BarChartGroupData> groups = [];
    final List<String> subjects = subjectProgress.keys.toList();

    for (int i = 0; i < subjects.length; i++) {
      final value = subjectProgress[subjects[i]]!.toDouble() * animationValue;
      
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: LinearGradient(
                colors: _getGradientColors(i),
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 22,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxProgress() + 5,
                color: Colors.grey.shade100,
              ),
            ),
          ],
          showingTooltipIndicators: [],
        ),
      );
    }
    return groups;
  }

  List<Color> _getGradientColors(int index) {
    final gradients = [
      [Colors.blue.shade400, Colors.blue.shade700],
      [Colors.purple.shade400, Colors.purple.shade700],
      [Colors.amber.shade400, Colors.amber.shade700],
      [Colors.teal.shade400, Colors.teal.shade700],
      [Colors.pink.shade400, Colors.pink.shade700],
      [Colors.orange.shade400, Colors.orange.shade700],
      [Colors.green.shade400, Colors.green.shade700],
      [Colors.indigo.shade400, Colors.indigo.shade700],
      [Colors.red.shade400, Colors.red.shade700],
      [Colors.cyan.shade400, Colors.cyan.shade700],
    ];

    return gradients[index % gradients.length];
  }
}