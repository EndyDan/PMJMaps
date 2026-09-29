import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final Widget destination;

  const SplashScreen({super.key, required this.destination});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  Timer? _fallbackTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/splash_video.mp4')
      ..addListener(_handleVideoUpdate)
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        _controller.play();
      });
    _fallbackTimer = Timer(const Duration(seconds: 5), _navigateToApp);
  }

  void _handleVideoUpdate() {
    if (!_controller.value.isInitialized ||
        !_controller.value.isCompleted &&
            _controller.value.position < _controller.value.duration) {
      return;
    }
    _navigateToApp();
  }

  void _navigateToApp() {
    if (_hasNavigated || !mounted) {
      return;
    }
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => widget.destination),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller
      ..removeListener(_handleVideoUpdate)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(backgroundColor: Color(0xFF030A24));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
