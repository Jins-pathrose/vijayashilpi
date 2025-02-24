

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vijay_shilpi/View/Screens/SearchPage/teachervideoscreen.dart';

class SearchPage extends StatefulWidget {
  final String studentClass;

  const SearchPage({Key? key, required this.studentClass}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allTeachers = [];
  List<Map<String, dynamic>> filteredTeachers = [];
  List<String> subjects = [];
  String? selectedSubject;
  bool isLoading = true;
  bool hasSearched = false;
  String searchQuery = '';
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      final QuerySnapshot teacherSnapshot = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .get();

      final Set<String> uniqueSubjects = {};

      setState(() {
        allTeachers = teacherSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final subject = data['subject'] as String? ?? 'Unknown';
          uniqueSubjects.add(subject);
          
          return {
            'uuid': doc.id,
            'name': data['name'] ?? '',
            'subject': subject,
          };
        }).toList();
        
        subjects = uniqueSubjects.toList()..sort();
        filteredTeachers = List.from(allTeachers);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading teachers: $e')),
      );
    }
  }

  void _filterTeachers(String query) {
    setState(() {
      searchQuery = query;
      hasSearched = query.isNotEmpty || selectedSubject != null;
      
      filteredTeachers = allTeachers.where((teacher) {
        final matchesName = teacher['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
            
        final matchesSubject = selectedSubject == null || 
            teacher['subject'] == selectedSubject;
            
        return matchesName && matchesSubject;
      }).toList();
    });
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  String _getTranslatedText(String label) {
    if (selectedLanguage == 'ta') {
      switch (label) {
        case 'Search Teachers':
          return 'ஆசிரியர்களைத் தேடுங்கள்';
        case 'Search teachers...':
          return 'ஆசிரியர்களைத் தேடுங்கள்...';
        case 'No teacher found':
          return 'ஆசிரியர் கிடைக்கவில்லை';
        case 'Try searching with a different name':
          return 'வேறு பெயரில் தேட முயற்சிக்கவும்';
        case 'Select Subject':
          return 'பாடத்தைத் தேர்ந்தெடுக்கவும்';
        case 'All Subjects':
          return 'அனைத்து பாடங்களும்';
        default:
          return label;
      }
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTranslatedText('Search Teachers'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTeachers,
              decoration: InputDecoration(
                hintText: _getTranslatedText('Search teachers...'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.grey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  value: selectedSubject,
                  isExpanded: true,
                  hint: Text(_getTranslatedText('Select Subject')),
                  underline: Container(),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(_getTranslatedText('All Subjects')),
                    ),
                    ...subjects.map((String subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubject = newValue;
                      _filterTeachers(_searchController.text);
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasSearched && filteredTeachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getTranslatedText('No teacher found'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTranslatedText('Try searching with a different name'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = filteredTeachers[index];
                          return TeacherVideosSection(
                            teacherUuid: teacher['uuid'],
                            teacherName: teacher['name'],
                            studentClass: widget.studentClass,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}