
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vijay_shilpi/Model/Authentication/auth_service.dart';
import 'package:vijay_shilpi/View/Screens/GeminiAi/gemini_ai.dart';
import 'package:vijay_shilpi/View/Screens/ProfilePage/editprofile.dart';
import 'package:vijay_shilpi/View/Screens/ProfilePage/historypage.dart';
import 'package:vijay_shilpi/View/Screens/ProfilePage/subjectprogress.dart';
import 'package:vijay_shilpi/View/authenticatioin/Login/students_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchStudentData();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en'; 
    });
  }

  Future<void> _fetchStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('students_registration')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _studentData = querySnapshot.docs.first.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching student data: $e')),
      );
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(studentData: _studentData!),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _studentData = updatedData;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  Future<void> _changeLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);

    setState(() {
      selectedLanguage = language;
    });
  }

  String _getTranslatedText(String label) {
    // Add translations for Tamil and English
    if (selectedLanguage == 'ta') {
      switch (label) {
        case 'Name':
          return 'பெயர்';
        case 'Phone Number':
          return 'பேசி எண்';
        case 'Class':
          return 'படிப்பு வகுப்பு';
        case 'School':
          return 'பள்ளி';
        case 'Sirpakam':
          return 'சிரபாகம்';
        case 'Profile Screen':
          return 'சுயவிவர திரை';
        case 'Edit Profile':
          return 'சுயவிவரம் திருத்து';
        case 'Logout':
          return 'உள்நுழைவிற்கு \n வெளியேறு';
          case 'My progressive':
          return 'என் முற்போக்கு';
           case 'Change Language':
          return 'மொழியை மாற்று';
          case 'Settings':
          return 'அமைப்புகள்';
          case 'Learning History':
          return 'வரலாறு கற்றல்';
          case 'Artificial Intelligence':
          return 'செயற்கை நுண்ணறிவு';
        default:
          return label;
      }
    } else {
      // Default to English
      return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _getTranslatedText('Profile Screen'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.settings),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child:  Center(
                child: Text(
                  _getTranslatedText('Settings'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: Text(_getTranslatedText('Edit Profile')),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _navigateToEditProfile(); // Navigate to edit profile
              },
            ),
            const Divider(),
            // Language Change Option
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.black),
              title: Text(_getTranslatedText("My progressive")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentProgressPage()));
              },
            ),

            const Divider(),
            // Language Change Option
            ListTile(
              leading: const Icon(Icons.language, color: Colors.black),
              title: Text(_getTranslatedText('Change Language')),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(_getTranslatedText('Select Language')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('English'),
                            onTap: () {
                              _changeLanguage('en');
                              Navigator.pop(context); // Close dialog
                            },
                          ),
                          ListTile(
                            title: Text('தமிழ்'),
                            onTap: () {
                              _changeLanguage('ta');
                              Navigator.pop(context); // Close dialog
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.black),
              title: Text(_getTranslatedText("Learning History")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>HistoryPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.smart_toy_sharp, color: Colors.black),
              title: Text(_getTranslatedText("Artificial Intelligence")),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GeminiChatScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: null,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTranslatedText("Logout"),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              onTap: () async {
                final shouldLogout = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(selectedLanguage: selectedLanguage),
                              ),
                            );
                          },
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
                if (shouldLogout == true) {
                  await _auth.signOut();
                }
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _studentData == null
              ? const Center(child: Text('No student data found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _studentData!['image'] != null
                            ? NetworkImage(_studentData!['image'])
                            : null,
                        child: _studentData!['image'] == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _studentData!['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _studentData!['class'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildProfileItem(_getTranslatedText('Phone Number'), _studentData!['number']),
                      const SizedBox(height: 15),
                      _buildProfileItem(_getTranslatedText('School'), _studentData!['school']),
                      const SizedBox(height: 15),
                      _buildProfileItem(_getTranslatedText('Sirpakam'), _studentData!['sirpakam']),
                    ],
                  ),
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

