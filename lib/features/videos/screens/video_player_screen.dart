import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Detects YouTube URLs and extracts the video ID.
String? _extractYoutubeId(String url) {
  return YoutubePlayer.convertUrlToId(url);
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // For direct videos (mp4, etc.)
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // For YouTube
  YoutubePlayerController? _ytController;

  bool _isYoutube = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Immersive: hide status bar, force landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final ytId = _extractYoutubeId(widget.videoUrl);

    if (ytId != null) {
      _isYoutube = true;
      _ytController = YoutubePlayerController(
        initialVideoId: ytId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
      setState(() => _loading = false);
    } else {
      // Direct URL (mp4, uploaded file, etc.)
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFFC62828),
            handleColor: const Color(0xFFC62828),
            bufferedColor: Colors.white38,
            backgroundColor: Colors.white24,
          ),
        );
        setState(() => _loading = false);
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'تعذر تشغيل الفيديو';
        });
      }
    }
  }

  @override
  void dispose() {
    // Restore UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _chewieController?.dispose();
    _videoController?.dispose();
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Player
          Center(
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : _error != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white54, size: 64),
                          const SizedBox(height: 16),
                          Text(_error!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        ],
                      )
                    : _isYoutube
                        ? YoutubePlayerBuilder(
                            player: YoutubePlayer(
                              controller: _ytController!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: const Color(0xFFC62828),
                            ),
                            builder: (context, player) => player,
                          )
                        : _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const SizedBox.shrink(),
          ),

          // Top gradient scrim — keeps the title & back button readable
          // over any video (bright frames, YouTube controls, etc.).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).padding.top + 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xB3000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 24),
              ),
            ),
          ),

          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 56,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
              ),
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
