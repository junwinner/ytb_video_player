import 'package:flutter/material.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerPage extends StatefulWidget {
  final String youtubeUrl;

  const VideoPlayerPage({Key? key, required this.youtubeUrl}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = YoutubePlayerController.fromVideoId(
    //   videoId: 'jNI0fiX4q4A', // 替换为您想播放的视频ID
    //   autoPlay: false,
    //   params: const YoutubePlayerParams(
    //       showControls: true,
    //       showFullscreenButton: true,
    //       interfaceLanguage: 'zh-CN'
    //   ),
    // );
  }

  @override
  void dispose() {
    // _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("播放YouTube视频")),
      body: Center(child: Text('text'),),
    );
  }
}
