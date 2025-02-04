
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const EditProfileScreen({required this.studentData, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _selectedSirpakam;
  final List<String> _sirpakamOptions = ['Chennai', 'Coimbatore', 'Madurai', 'Salem'];
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _nameController.text = widget.studentData['name'];
    _numberController.text = widget.studentData['number'];
    _classController.text = widget.studentData['class'];
    _schoolController.text = widget.studentData['school'];
    _selectedSirpakam = _sirpakamOptions.contains(widget.studentData['sirpakam'])
        ? widget.studentData['sirpakam']
        : _sirpakamOptions.first;
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en'; // Load saved language
    });
  }

  String _getTranslatedText(String label) {
    // Add translations for Tamil and English
    if (_selectedLanguage == 'ta') {
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
        case 'Edit Profile':
          return 'சுயவிவரம் திருத்து';
        case 'Save':
          return 'சேமி';
        default:
          return label;
      }
    } else {
      // Default to English
      return label;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_image == null) return null;
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = 'VijayaShilpi';
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] as String;
      } else {
        throw HttpException('Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _selectedSirpakam == null) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to update your profile')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? imageUrl = widget.studentData['image'];
      if (_image != null) {
        imageUrl = await _uploadToCloudinary();
      }

      await FirebaseFirestore.instance
          .collection('students_registration')
          .doc(widget.studentData['studentId'])
          .update({
        'name': _nameController.text.trim(),
        'number': _numberController.text.trim(),
        'class': _classController.text.trim(),
        'school': _schoolController.text.trim(),
        'sirpakam': _selectedSirpakam,
        'image': imageUrl,
      });

      // Return updated data to the previous screen
      final updatedData = {
        ...widget.studentData,
        'name': _nameController.text.trim(),
        'number': _numberController.text.trim(),
        'class': _classController.text.trim(),
        'school': _schoolController.text.trim(),
        'sirpakam': _selectedSirpakam,
        'image': imageUrl,
      };

      Navigator.pop(context, updatedData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedText('Edit Profile')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : widget.studentData['image'] != null
                                ? NetworkImage(widget.studentData['image'])
                                : null,
                        child: _image == null && widget.studentData['image'] == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: _getTranslatedText('Name')),
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _numberController,
                      decoration: InputDecoration(labelText: _getTranslatedText('Phone Number')),
                      validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _classController,
                      decoration: InputDecoration(labelText: _getTranslatedText('Class')),
                      validator: (value) => value!.isEmpty ? 'Please enter your class' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _schoolController,
                      decoration: InputDecoration(labelText: _getTranslatedText('School')),
                      validator: (value) => value!.isEmpty ? 'Please enter your school' : null,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _selectedSirpakam,
                      decoration: InputDecoration(labelText: _getTranslatedText('Sirpakam')),
                      items: _sirpakamOptions
                          .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (newValue) => setState(() => _selectedSirpakam = newValue),
                      validator: (value) => value == null ? 'Please select a Sirpakam' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(_getTranslatedText('Save')),
                      onPressed: _updateProfile,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}