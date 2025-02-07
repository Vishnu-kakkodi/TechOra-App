import 'package:flutter/material.dart';
import 'package:project/models/course_detail_model.dart';
import 'package:video_player/video_player.dart';

class ModulePlayerScreen extends StatefulWidget {
  final CourseModule module;
  final String courseTitle;

  const ModulePlayerScreen({
    super.key, 
    required this.module, 
    required this.courseTitle
  });

  @override
  _ModulePlayerScreenState createState() => _ModulePlayerScreenState();
}

class _ModulePlayerScreenState extends State<ModulePlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    // Debug print to verify the URL
    print('Video URL: ${widget.module.videoUrl}');

    if (widget.module.videoUrl.isEmpty) {
      setState(() {
        _errorMessage = 'No video URL provided';
      });
      return;
    }

    try {
      // Parse the URL and use networkUrl constructor
      final videoUri = Uri.parse(widget.module.videoUrl);
      
      _controller = VideoPlayerController.networkUrl(
        videoUri,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow playing with other sounds
        ),
      );
      
      _controller!.addListener(_videoPlayerListener);

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      }
    } catch (e) {
      print('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load video: $e';
        });
      }
    }
  }

  void _videoPlayerListener() {
    if (!_controller!.value.isInitialized) {
      print('Video controller not initialized');
    }
    if (_controller!.value.hasError) {
      print('Video player error: ${_controller!.value.errorDescription}');
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoPlayerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseTitle} - ${widget.module.title}'),
        backgroundColor: Colors.teal[100],
      ),
      body: Center(
        child: _errorMessage != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline, 
                  color: Colors.red, 
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Video URL: ${widget.module.videoUrl}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          : _isInitialized && _controller != null
            ? Column(
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  VideoProgressIndicator(
                    _controller!, 
                    allowScrubbing: true,
                    padding: const EdgeInsets.all(16),
                  ),
                  
                  // Module Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.module.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text('Duration: ${widget.module.duration} minutes'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _isInitialized && _controller != null
        ? FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller!.value.isPlaying 
                  ? _controller!.pause() 
                  : _controller!.play();
              });
            },
            child: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          )
        : null,
    );
  }
}