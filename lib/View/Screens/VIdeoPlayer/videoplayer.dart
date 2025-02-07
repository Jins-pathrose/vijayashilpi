import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Initialize the video player
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video['video_url']),
      );

      // Wait for the video to initialize
      await _videoPlayerController.initialize();

      // Check if the video is initialized and has a valid duration
      if (_videoPlayerController.value.isInitialized) {
        setState(() {
          _isLoading = false;
        });

        // Initialize ChewieController
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Error loading video: $errorMessage',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors during initialization
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video['chapter'] ?? 'Video Player',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_hasError)
              Expanded(
                child: Center(
                  child: Text(
                    'Failed to load video. Please check the URL or network connection.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video['chapter'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video['description'] ?? 'No Description',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Teacher ID: ${widget.video['teacher_uuid'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}