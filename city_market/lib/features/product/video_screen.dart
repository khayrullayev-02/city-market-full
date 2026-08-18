import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_theme.dart';

/// Mahsulot videosi — MP4 havolani ijro etadi.
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key, required this.url, this.title = ''});

  final String url;
  final String title;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;
  bool _error = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = c;
      await c.initialize();
      if (!mounted) return;
      setState(() => _ready = true);
      c.play();
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: _error
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  S.t(lang, 'errorVideo'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              )
            : _ready
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : const CircularProgressIndicator(color: AppColors.green),
      ),
      floatingActionButton: _ready
          ? FloatingActionButton(
              backgroundColor: AppColors.green,
              onPressed: () {
                final v = _controller!.value;
                setState(
                  () =>
                      v.isPlaying ? _controller!.pause() : _controller!.play(),
                );
              },
              child: ValueListenableBuilder(
                valueListenable: _controller!,
                builder: (_, v, __) => Icon(
                  v.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
