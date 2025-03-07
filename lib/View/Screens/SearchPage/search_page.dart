

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_bloc.dart';
// import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_event.dart';
// import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_state.dart';
// import 'package:vijay_shilpi/View/Screens/SearchPage/teachervideoscreen.dart';

// class SearchPage extends StatefulWidget {
//   final String studentClass;

//   const SearchPage({Key? key, required this.studentClass}) : super(key: key);

//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();
  
//   @override
//   void initState() {
//     super.initState();
//     // Load teachers when the page is initialized
//     context.read<SearchBloc>().add(LoadTeachersEvent());
//   }

//   String _getTranslatedText(String label, String language) {
//     if (language == 'ta') {
//       switch (label) {
//         case 'Search Teachers':
//           return 'ஆசிரியர்களைத் தேடுங்கள்';
//         case 'Search teachers...':
//           return 'ஆசிரியர்களைத் தேடுங்கள்...';
//         case 'No teacher found':
//           return 'ஆசிரியர் கிடைக்கவில்லை';
//         case 'Try searching with a different name':
//           return 'வேறு பெயரில் தேட முயற்சிக்கவும்';
//         case 'Select Subject':
//           return 'பாடத்தைத் தேர்ந்தெடுக்கவும்';
//         case 'All Subjects':
//           return 'அனைத்து பாடங்களும்';
//         default:
//           return label;
//       }
//     }
//     return label;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => SearchBloc()..add(LoadTeachersEvent()),
//       child: Scaffold(
//         appBar: AppBar(
//           title: BlocBuilder<SearchBloc, SearchState>(
//             builder: (context, state) {
//               String language = 'en';
//               if (state is SearchLoaded) {
//                 language = state.selectedLanguage;
//               }
//               return Text(
//                 _getTranslatedText('Search Teachers', language),
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               );
//             },
//           ),
//           backgroundColor: Colors.black,
//         ),
//         body: BlocBuilder<SearchBloc, SearchState>(
//           builder: (context, state) {
//             if (state is SearchLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (state is SearchError) {
//               return Center(child: Text(state.message));
//             }
//             if (state is SearchLoaded) {
//               final language = state.selectedLanguage;
//               final hasSearched = state.searchQuery.isNotEmpty || state.selectedSubject != null;
//               return Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (query) {
//                         context.read<SearchBloc>().add(FilterTeachersEvent(query: query, subject: state.selectedSubject));
//                       },
//                       decoration: InputDecoration(
//                         hintText: _getTranslatedText('Search teachers...', language),
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25),
//                         color: Colors.grey[200],
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: DropdownButton<String>(
//                           value: state.selectedSubject,
//                           isExpanded: true,
//                           hint: Text(_getTranslatedText('Select Subject', language)),
//                           underline: Container(),
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: null,
//                               child: Text(_getTranslatedText('All Subjects', language)),
//                             ),
//                             ...state.subjects.map((String subject) {
//                               return DropdownMenuItem<String>(
//                                 value: subject,
//                                 child: Text(subject),
//                               );
//                             }).toList(),
//                           ],
//                           onChanged: (String? newValue) {
//                             context.read<SearchBloc>().add(
//                                   FilterTeachersEvent(
//                                     query: _searchController.text,
//                                     subject: newValue,
//                                   ),
//                                 );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: state.allTeachers.isEmpty
//                         ? const Center(child: CircularProgressIndicator())
//                         : hasSearched && state.filteredTeachers.isEmpty
//                             ? Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.person_off,
//                                       size: 64,
//                                       color: Colors.grey[400],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       _getTranslatedText('No teacher found', language),
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 18,
//                                         color: Colors.grey[600],
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       _getTranslatedText('Try searching with a different name', language),
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         color: Colors.grey[500],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : ListView.builder(
//                                 itemCount: state.filteredTeachers.length,
//                                 itemBuilder: (context, index) {
//                                   final teacher = state.filteredTeachers[index];
//                                   return TeacherVideosSection(
//                                     teacherUuid: teacher['uuid'],
//                                     teacherName: teacher['name'],
//                                     studentClass: widget.studentClass,
//                                   );
//                                 },
//                               ),
//                   ),
//                 ],
//               );
//             }
//             return Container();
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_bloc.dart';
import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_event.dart';
import 'package:vijay_shilpi/Controller/SearchPage/bloc/search_state.dart';
import 'package:vijay_shilpi/Model/Homeservice/home_service.dart';
import 'package:vijay_shilpi/View/Screens/SearchPage/teachervideoscreen.dart';
import 'package:vijay_shilpi/View/Screens/VIdeoPlayer/videoplayer.dart';
import 'package:vijay_shilpi/View/Widgets/HomePage/videolist_items.dart';

class SearchPage extends StatefulWidget {
  final String studentClass;
  final HomeService homeService;

  const SearchPage({
    Key? key,
    required this.studentClass,
    required this.homeService,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load teachers when the page is initialized
    context.read<SearchBloc>().add(LoadTeachersEvent());
  }

  String _getTranslatedText(String label, String language) {
    if (language == 'ta') {
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc()..add(LoadTeachersEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              String language = 'en';
              if (state is SearchLoaded) {
                language = state.selectedLanguage;
              }
              return Text(
                _getTranslatedText('Search Teachers', language),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          backgroundColor: Colors.black,
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SearchError) {
              return Center(child: Text(state.message));
            }
            if (state is SearchLoaded) {
              final language = state.selectedLanguage;
              final hasSearched = state.searchQuery.isNotEmpty || state.selectedSubject != null;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<SearchBloc>().add(
                          FilterTeachersEvent(
                            query: query,
                            subject: state.selectedSubject,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: _getTranslatedText('Search teachers...', language),
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
                          value: state.selectedSubject,
                          isExpanded: true,
                          hint: Text(_getTranslatedText('Select Subject', language)),
                          underline: Container(),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(_getTranslatedText('All Subjects', language)),
                            ),
                            ...state.subjects.map((String subject) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(subject),
                              );
                            }).toList(),
                          ],
                          onChanged: (String? newValue) {
                            context.read<SearchBloc>().add(
                              FilterTeachersEvent(
                                query: _searchController.text,
                                subject: newValue,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.allTeachers.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : hasSearched && state.filteredTeachers.isEmpty
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
                                      _getTranslatedText('No teacher found', language),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getTranslatedText('Try searching with a different name', language),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.filteredTeachers.length,
                                itemBuilder: (context, index) {
                                  final teacher = state.filteredTeachers[index];
                                  return TeacherVideosSection(
                                    teacherUuid: teacher['uuid'],
                                    teacherName: teacher['name'],
                                    studentClass: widget.studentClass,
                                    homeService: widget.homeService,
                                    getTranslatedText: (label) => _getTranslatedText(label, language),
                                    showMessage: _showMessage,
                                  );
                                },
                              ),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// class TeacherVideosSection extends StatelessWidget {
//   final String teacherUuid;
//   final String teacherName;
//   final String studentClass;
//   final HomeService homeService;
//   final String Function(String) getTranslatedText;
//   final void Function(String) showMessage;

//   const TeacherVideosSection({
//     Key? key,
//     required this.teacherUuid,
//     required this.teacherName,
//     required this.studentClass,
//     required this.homeService,
//     required this.getTranslatedText,
//     required this.showMessage,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('videos')
//           .where('teacher_uuid', isEqualTo: teacherUuid)
//           .where('classCategory', isEqualTo: studentClass)
//           .where('isapproved', isEqualTo: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text(getTranslatedText('Error fetching videos')));
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Container(); // No videos found for this teacher
//         }

//         final videos = snapshot.data!.docs;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Text(
//                 teacherName,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: videos.length,
//               itemBuilder: (context, index) {
//                 var video = videos[index].data() as Map<String, dynamic>;
//                 return VideoListItem(
//                   video: video,
//                   homeService: homeService,
//                   getTranslatedText: getTranslatedText,
//                   showMessage: showMessage,
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }