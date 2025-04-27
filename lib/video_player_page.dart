import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
class VideoPlayerPage extends StatefulWidget {
  final String youtubeUrl;

  const VideoPlayerPage({Key? key, required this.youtubeUrl}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 1);
  PlayerState _playerState = PlayerState.unknown;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'jNI0fiX4q4A', // 替换为您想播放的视频ID
      autoPlay: false,
      params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          interfaceLanguage: 'zh-CN'
      ),
    );

    // 监听播放器状态（播放/暂停/结束/错误）
    _controller.stream.listen((value) {
      print('监听播放器状态: $value');
      setState(() {
        _playerState = value.playerState;
        _hasError    = value.hasError;
      });
    });
    // 监听进度/缓冲信息
    _controller.videoStateStream.listen((value) {
      print('监听进度/缓冲信息: position ${value.position}  loadedFraction ${value.loadedFraction}');
      setState(() {
        _position    = value.position;  // 当前时长
      });
    });

    // // 获取视频总时长（元数据加载后）
    // _controller.duration.then((seconds) {
    //   print("获取视频总时长seconds: $seconds");
    //   setState(() {
    //     _duration = Duration(seconds: seconds.toInt());
    //   });
    // });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("播放YouTube视频")),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          )
        ],
      ),
    );
  }
}
