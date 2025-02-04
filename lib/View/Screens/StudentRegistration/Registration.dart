
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
  String _selectedLanguage = 'en'; // Default language is English

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
      appBar: AppBar(title: Text('Select Language')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _saveLanguageAndProceed('en'),
              child: Text('English'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveLanguageAndProceed('ta'),
              child: Text('தமிழ்'),
            ),
          ],
        ),
      ),
    );
  }
}

class FillYourProfileScreen extends StatefulWidget {
  final String selectedLanguage;
  const FillYourProfileScreen({Key? key, required this.selectedLanguage}) : super(key: key);
  @override
  State<FillYourProfileScreen> createState() => _FillYourProfileScreenState();
}

class _FillYourProfileScreenState extends State<FillYourProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _class = TextEditingController();
  final _school = TextEditingController();
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _selectedSirpakam;
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

 Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      print(e);
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
    if (_selectedSirpakam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a Sirpakam')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please log in to save your profile')));
      setState(() => _isLoading = false);
      return;
    }
    String? imageUrl = await _uploadToCloudinary();
    if (imageUrl == null) {
      setState(() => _isLoading = false);
      return;
    }
    final studentId = Uuid().v4();
    try {
      await FirebaseFirestore.instance.collection('students_registration').doc(studentId).set({
        'studentId': studentId,
        'name': _name.text.trim(),
        'number': _number.text.trim(),
        'class': _class.text.trim(),
        'school': _school.text.trim(),
        'sirpakam': _selectedSirpakam, // Save selected Sirpakam
        'image': imageUrl,
        'userId': user.uid,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile saved successfully!')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Bottomnav()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    String lang = widget.selectedLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(translations[lang]!['title']!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_name, translations[lang]!['name']!),
                SizedBox(height: 10),
                _buildTextField(_number, translations[lang]!['number']!, keyboardType: TextInputType.phone),
                SizedBox(height: 10),
                _buildTextField(_class, translations[lang]!['class']!),
                SizedBox(height: 10),
                _buildTextField(_school, translations[lang]!['school']!),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedSirpakam,
                  decoration: InputDecoration(
                    labelText: translations[lang]!['sirpakam']!,
                    border: OutlineInputBorder(),
                  ),
                  items: _sirpakamOptions[lang]!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSirpakam = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text(translations[lang]!['next']!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
