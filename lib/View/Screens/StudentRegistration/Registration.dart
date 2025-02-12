
// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'package:vijay_shilpi/View/Screens/Onboarding/onboarding.dart';
// import 'package:vijay_shilpi/View/Bottomnavigation/sudentss_navigation.dart';

// class LanguageScreen extends StatefulWidget {
//   @override
//   _LanguageScreenState createState() => _LanguageScreenState();
// }

// class _LanguageScreenState extends State<LanguageScreen> {
//   String _selectedLanguage = 'en';

//   Future<void> _saveLanguageAndProceed(String language) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_language', language);

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OnboardingScreen(selectedLanguage: language),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Select Language')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => _saveLanguageAndProceed('en'),
//               child: Text('English'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _saveLanguageAndProceed('ta'),
//               child: Text('தமிழ்'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FillYourProfileScreen extends StatefulWidget {
//   final String selectedLanguage;
//   const FillYourProfileScreen({Key? key, required this.selectedLanguage})
//       : super(key: key);
//   @override
//   State<FillYourProfileScreen> createState() => _FillYourProfileScreenState();
// }

// class _FillYourProfileScreenState extends State<FillYourProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _name = TextEditingController();
//   final _number = TextEditingController();
//   String? _selectedClass;
//   final _school = TextEditingController();
//   File? _image;
//   bool _isLoading = false;
//   final ImagePicker _picker = ImagePicker();
//   String? _selectedSirpakam;
//   String? _selectedSubject;
//   List<String> _classes = [];
//   List<String> _subjects = [];
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final Map<String, List<String>> _sirpakamOptions = {
//     'en': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
//     'ta': ['சென்னை', 'கோயம்புத்தூர்', 'மதுரை', 'சேலம்']
//   };

//   Map<String, Map<String, String>> translations = {
//     'en': {
//       'title': 'Fill Your Profile',
//       'name': 'Full Name',
//       'number': 'Phone Number',
//       'class': 'Class',
//       'school': 'School',
//       'sirpakam': 'Sirpakam',
//       'subject': 'Subject',
//       'next': 'NEXT',
//       'pick_image': 'Pick Image'
//     },
//     'ta': {
//       'title': 'உங்கள் சுயவிவரத்தை நிரப்பவும்',
//       'name': 'முழு பெயர்',
//       'number': 'தொலைபேசி எண்',
//       'class': 'வகுப்பு',
//       'school': 'பள்ளி',
//       'sirpakam': 'சிற்பகம்',
//       'subject': 'பாடம்',
//       'next': 'அடுத்தது',
//       'pick_image': 'படத்தை தேர்வுசெய்க'
//     }
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchClassesAndSubjects();
//   }

//   Future<void> _fetchClassesAndSubjects() async {
//     try {
//       // Fetch classes
//       QuerySnapshot classSnapshot = await _firestore.collection('categories').get();
//       List<String> classes = classSnapshot.docs
//           .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
//           .toList();

//       // Fetch subjects
//       QuerySnapshot subjectSnapshot = await _firestore.collection('subject').get();
//       List<String> subjects = subjectSnapshot.docs
//           .map((doc) => (doc.data() as Map<String, dynamic>)['subject'] as String)
//           .toList();

//       setState(() {
//         _classes = classes;
//         _subjects = subjects;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching data: $e')),
//       );
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: $e')),
//       );
//     }
//   }

//   Future<String?> _uploadToCloudinary() async {
//     if (_image == null) return null;
//     try {
//       final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
//       final request = http.MultipartRequest('POST', url)
//         ..fields['upload_preset'] = 'VijayaShilpi'
//         ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
//       final response = await request.send();
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.toBytes();
//         final responseString = String.fromCharCodes(responseData);
//         final jsonMap = jsonDecode(responseString);
//         return jsonMap['secure_url'] as String;
//       } else {
//         throw HttpException('Upload failed with status ${response.statusCode}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
//       return null;
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedClass == null || _selectedSirpakam == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill all required fields')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please log in to save your profile')),
//       );
//       setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       String? imageUrl;
//       if (_image != null) {
//         imageUrl = await _uploadToCloudinary();
//         if (imageUrl == null) {
//           setState(() => _isLoading = false);
//           return;
//         }
//       }

//       await _firestore.collection('students_registration').doc(user.uid).set({
//         'studentId': user.uid,
//         'userId': user.uid,
//         'name': _name.text.trim(),
//         'number': _number.text.trim(),
//         'class': _selectedClass,
//         'subject': _selectedSubject,
//         'school': _school.text.trim(),
//         'sirpakam': _selectedSirpakam,
//         'image': imageUrl ?? '',
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Profile saved successfully!')),
//       );

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => Bottomnav()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save profile: $e')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     String lang = widget.selectedLanguage;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(translations[lang]!['title']!),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: _pickImage,
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: _image != null ? FileImage(_image!) : null,
//                         child: _image == null
//                             ? Icon(Icons.person,
//                                 size: 50, color: Colors.grey.shade600)
//                             : null,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     _buildTextField(_name, translations[lang]!['name']!),
//                     SizedBox(height: 10),
//                     _buildTextField(_number, translations[lang]!['number']!,
//                         keyboardType: TextInputType.phone),
//                     SizedBox(height: 10),
//                     DropdownButtonFormField<String>(
//                       value: _selectedClass,
//                       decoration: InputDecoration(
//                         labelText: translations[lang]!['class']!,
//                         border: OutlineInputBorder(),
//                       ),
//                       items: _classes.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedClass = newValue;
//                         });
//                       },
//                     ),
//                     // SizedBox(height: 10),
//                     // DropdownButtonFormField<String>(
//                     //   value: _selectedSubject,
//                     //   decoration: InputDecoration(
//                     //     labelText: translations[lang]!['subject']!,
//                     //     border: OutlineInputBorder(),
//                     //   ),
//                     //   items: _subjects.map((String value) {
//                     //     return DropdownMenuItem<String>(
//                     //       value: value,
//                     //       child: Text(value),
//                     //     );
//                     //   }).toList(),
//                     //   onChanged: (String? newValue) {
//                     //     setState(() {
//                     //       _selectedSubject = newValue;
//                     //     });
//                     //   },
//                     // ),
//                     SizedBox(height: 10),
//                     _buildTextField(_school, translations[lang]!['school']!),
//                     SizedBox(height: 10),
//                     // DropdownButtonFormField<String>(
//                     //   value: _selectedSirpakam,
//                     //   decoration: InputDecoration(
//                     //     labelText: translations[lang]!['sirpakam']!,
//                     //     border: OutlineInputBorder(),
//                     //   ),
//                     //   items: _sirpakamOptions[lang]!.map((String value) {
//                     //     return DropdownMenuItem<String>(
//                     //       value: value,
//                     //       child: Text(value),
//                     //     );
//                     //   }).toList(),
//                     //   onChanged: (String? newValue) {
//                     //     setState(() {
//                     //       _selectedSirpakam = newValue;
//                     //     });
//                     //   },
//                     // ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _saveProfile,
//                       child: _isLoading
//                           ? CircularProgressIndicator()
//                           : Text(translations[lang]!['next']!),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter $label';
//         }
//         return null;
//       },
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vijay_shilpi/View/Screens/Onboarding/onboarding.dart';
import 'package:vijay_shilpi/View/Bottomnavigation/sudentss_navigation.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en';

  Future<void> _saveLanguageAndProceed(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(selectedLanguage: language),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _saveLanguageAndProceed('en'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('English', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _saveLanguageAndProceed('ta'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('தமிழ்', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FillYourProfileScreen extends StatefulWidget {
  final String selectedLanguage;
  const FillYourProfileScreen({Key? key, required this.selectedLanguage})
      : super(key: key);
  @override
  State<FillYourProfileScreen> createState() => _FillYourProfileScreenState();
}

class _FillYourProfileScreenState extends State<FillYourProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  String? _selectedClass;
  final _school = TextEditingController();
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _selectedSirpakam;
  List<String> _classes = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, List<String>> _sirpakamOptions = {
    'en': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
    'ta': ['சென்னை', 'கோயம்புத்தூர்', 'மதுரை', 'சேலம்']
  };

  Map<String, Map<String, String>> translations = {
    'en': {
      'title': 'Fill Your Profile',
      'name': 'Full Name',
      'number': 'Phone Number',
      'class': 'Class',
      'school': 'School',
      'sirpakam': 'Sirpakam',
      'next': 'NEXT',
      'pick_image': 'Pick Image'
    },
    'ta': {
      'title': 'உங்கள் சுயவிவரத்தை நிரப்பவும்',
      'name': 'முழு பெயர்',
      'number': 'தொலைபேசி எண்',
      'class': 'வகுப்பு',
      'school': 'பள்ளி',
      'sirpakam': 'சிற்பகம்',
      'next': 'அடுத்தது',
      'pick_image': 'படத்தை தேர்வுசெய்க'
    }
  };

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      QuerySnapshot classSnapshot = await _firestore.collection('categories').get();
      List<String> classes = classSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toList();

      setState(() {
        _classes = classes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_image == null) return null;
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'VijayaShilpi'
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] as String;
      } else {
        throw HttpException('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClass == null || _selectedSirpakam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to save your profile')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadToCloudinary();
        if (imageUrl == null) {
          setState(() => _isLoading = false);
          return;
        }
      }

      await _firestore.collection('students_registration').doc(user.uid).set({
        'studentId': user.uid,
        'userId': user.uid,
        'name': _name.text.trim(),
        'number': _number.text.trim(),
        'class': _selectedClass,
        'school': _school.text.trim(),
        'sirpakam': _selectedSirpakam,
        'image': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Bottomnav()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.selectedLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[lang]!['title']!),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    _image != null ? FileImage(_image!) : null,
                                child: _image == null
                                    ? Icon(Icons.person,
                                        size: 60, color: Colors.grey.shade600)
                                    : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      _buildTextField(_name, translations[lang]!['name']!),
                      SizedBox(height: 16),
                      _buildTextField(_number, translations[lang]!['number']!,
                          keyboardType: TextInputType.phone),
                      SizedBox(height: 16),
                      _buildDropdownField(
                        value: _selectedClass,
                        label: translations[lang]!['class']!,
                        items: _classes,
                        onChanged: (value) =>
                            setState(() => _selectedClass = value),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(_school, translations[lang]!['school']!),
                      SizedBox(height: 16),
                      _buildDropdownField(
                        value: _selectedSirpakam,
                        label: translations[lang]!['sirpakam']!,
                        items: _sirpakamOptions[lang]!,
                        onChanged: (value) =>
                            setState(() => _selectedSirpakam = value),
                      ),
                      SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  translations[lang]!['next']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

 Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      style: TextStyle(color: Colors.black87),
      icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
      dropdownColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _school.dispose();
    super.dispose();
  }
}