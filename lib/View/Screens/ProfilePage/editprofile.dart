
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class EditProfileScreen extends StatefulWidget {
//   final Map<String, dynamic> studentData;
//   const EditProfileScreen({required this.studentData, super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _numberController = TextEditingController();
//   final _schoolController = TextEditingController();
//   File? _image;
//   bool _isLoading = false;
//   String? _selectedSirpakam;
//   final List<String> _sirpakamOptions = ['Chennai', 'Coimbatore', 'Madurai', 'Salem'];
//   String? _selectedClass;
//   final List<String> _classOptions = ['Young Minds (5th to 7th)', 'Achievers (8th to 10th)', 'Vibrant Vibes (11th to 12th)', 'Master Minds (Degree and above)'];
//   String _selectedLanguage = 'en';

//   @override
//   void initState() {
//     super.initState();
//     _loadLanguage();
//     _nameController.text = widget.studentData['name'];
//     _numberController.text = widget.studentData['number'];
//     _schoolController.text = widget.studentData['school'];
//     _selectedSirpakam = _sirpakamOptions.contains(widget.studentData['sirpakam'])
//         ? widget.studentData['sirpakam']
//         : _sirpakamOptions.first;
//     _selectedClass = _classOptions.contains(widget.studentData['class'])
//         ? widget.studentData['class']
//         : _classOptions.first;
//   }

//   Future<void> _loadLanguage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _selectedLanguage = prefs.getString('selected_language') ?? 'en';
//     });
//   }
//   Future<String?> _uploadToCloudinary() async {
//     if (_image == null) return null;
//     try {
//       final url = Uri.parse('https://api.cloudinary.com/v1_1/datygsam7/upload');
//       final request = http.MultipartRequest('POST', url);
//       request.fields['upload_preset'] = 'VijayaShilpi';
//       request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
//       final response = await request.send();
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.toBytes();
//         final responseString = String.fromCharCodes(responseData);
//         final jsonMap = jsonDecode(responseString);
//         return jsonMap['secure_url'] as String;
//       } else {
//         throw HttpException('Upload failed');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading image: $e')),
//       );
//       return null;
//     }
//   }
//   String _getTranslatedText(String label) {
//     if (_selectedLanguage == 'ta') {
//       switch (label) {
//         case 'Name':
//           return 'பெயர்';
//         case 'Phone Number':
//           return 'பேசி எண்';
//         case 'Class':
//           return 'படிப்பு வகுப்பு';
//         case 'School':
//           return 'பள்ளி';
//         case 'Sirpakam':
//           return 'சிரபாகம்';
//         case 'Edit Profile':
//           return 'சுயவிவரம் திருத்து';
//         case 'Save':
//           return 'சேமி';
//         default:
//           return label;
//       }
//     } else {
//       return label;
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _image = File(pickedFile.path));
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate() || _selectedSirpakam == null || _selectedClass == null) return;
//     setState(() => _isLoading = true);

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to update your profile')),
//       );
//       setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       String? imageUrl = widget.studentData['image'];
//       if (_image != null) {
//         imageUrl = await _uploadToCloudinary();
//       }

//       await FirebaseFirestore.instance
//           .collection('students_registration')
//           .doc(widget.studentData['studentId'])
//           .update({
//         'name': _nameController.text.trim(),
//         'number': _numberController.text.trim(),
//         'class': _selectedClass,
//         'school': _schoolController.text.trim(),
//         'sirpakam': _selectedSirpakam,
//         'image': imageUrl,
//       });

//       final updatedData = {
//         ...widget.studentData,
//         'name': _nameController.text.trim(),
//         'number': _numberController.text.trim(),
//         'class': _selectedClass,
//         'school': _schoolController.text.trim(),
//         'sirpakam': _selectedSirpakam,
//         'image': imageUrl,
//       };

//       Navigator.pop(context, updatedData);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update profile: $e')),
//       );
//     }
//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_getTranslatedText('Edit Profile'))),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: _pickImage,
//                       child: CircleAvatar(
//                         radius: 55,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: _image != null
//                             ? FileImage(_image!)
//                             : widget.studentData['image'] != null
//                                 ? NetworkImage(widget.studentData['image'])
//                                 : null,
//                         child: _image == null && widget.studentData['image'] == null
//                             ? const Icon(Icons.person, size: 50, color: Colors.grey)
//                             : null,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: InputDecoration(labelText: _getTranslatedText('Name')),
//                       validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
//                     ),
//                     const SizedBox(height: 15),
//                     TextFormField(
//                       controller: _numberController,
//                       decoration: InputDecoration(labelText: _getTranslatedText('Phone Number')),
//                       validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
//                     ),
//                     const SizedBox(height: 15),
//                     DropdownButtonFormField<String>(
//                       value: _selectedClass,
//                       decoration: InputDecoration(labelText: _getTranslatedText('Class')),
//                       items: _classOptions
//                           .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
//                           .toList(),
//                       onChanged: (newValue) => setState(() => _selectedClass = newValue),
//                     ),
//                     TextFormField(
//                       controller: _schoolController,
//                       decoration: InputDecoration(labelText: _getTranslatedText('School')),
//                       validator: (value) => value!.isEmpty ? 'Please enter your school' : null,
//                     ),
//                     const SizedBox(height: 15),
//                     DropdownButtonFormField<String>(
//                       value: _selectedSirpakam,
//                       decoration: InputDecoration(labelText: _getTranslatedText('Sirpakam')),
//                       items: _sirpakamOptions
//                           .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
//                           .toList(),
//                       onChanged: (newValue) => setState(() => _selectedSirpakam = newValue),
//                       validator: (value) => value == null ? 'Please select a Sirpakam' : null,
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.save),
//                       label: Text(_getTranslatedText('Save')),
//                       onPressed: _updateProfile,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

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
  final _schoolController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _selectedSirpakam;
  final List<String> _sirpakamOptions = ['Chennai', 'Coimbatore', 'Madurai', 'Salem'];
  String? _selectedClass;
  List<String> _classes = [];
  String _selectedLanguage = 'en';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchClasses();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = widget.studentData['name'];
    _numberController.text = widget.studentData['number'];
    _schoolController.text = widget.studentData['school'];
    _selectedSirpakam = _sirpakamOptions.contains(widget.studentData['sirpakam'])
        ? widget.studentData['sirpakam']
        : _sirpakamOptions.first;
  }

  Future<void> _fetchClasses() async {
    try {
      QuerySnapshot classSnapshot = await _firestore.collection('categories').get();
      List<String> classes = classSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toList();

      setState(() {
        _classes = classes;
        _selectedClass = _classes.contains(widget.studentData['class'])
            ? widget.studentData['class']
            : _classes.isNotEmpty ? _classes.first : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching classes: $e')),
      );
    }
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
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

  String _getTranslatedText(String label) {
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
        case 'Update Profile':
          return 'சுயவிவரத்தை புதுப்பிக்கவும்';
        default:
          return label;
      }
    } else {
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _selectedSirpakam == null || _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
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
        'class': _selectedClass,
        'school': _schoolController.text.trim(),
        'sirpakam': _selectedSirpakam,
        'image': imageUrl,
      });

      final updatedData = {
        ...widget.studentData,
        'name': _nameController.text.trim(),
        'number': _numberController.text.trim(),
        'class': _selectedClass,
        'school': _schoolController.text.trim(),
        'sirpakam': _selectedSirpakam,
        'image': imageUrl,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context, updatedData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: _getTranslatedText(label),
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
          return 'Please enter ${label.toLowerCase()}';
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
        labelText: _getTranslatedText(label),
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
          return 'Please select ${label.toLowerCase()}';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedText('Edit Profile')),
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
                padding: const EdgeInsets.all(24.0),
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
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : widget.studentData['image'] != null && widget.studentData['image'].toString().isNotEmpty
                                        ? NetworkImage(widget.studentData['image']) as ImageProvider
                                        : null,
                                child: (_image == null && (widget.studentData['image'] == null || widget.studentData['image'].toString().isEmpty))
                                    ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
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
                      _buildTextField(_nameController, 'Name'),
                      SizedBox(height: 16),
                      _buildTextField(_numberController, 'Phone Number',
                          keyboardType: TextInputType.phone),
                      SizedBox(height: 16),
                      _buildDropdownField(
                        value: _selectedClass,
                        label: 'Class',
                        items: _classes,
                        onChanged: (value) => setState(() => _selectedClass = value),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(_schoolController, 'School'),
                      SizedBox(height: 16),
                      _buildDropdownField(
                        value: _selectedSirpakam,
                        label: 'Sirpakam',
                        items: _sirpakamOptions,
                        onChanged: (value) => setState(() => _selectedSirpakam = value),
                      ),
                      SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _getTranslatedText('Update Profile'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
}