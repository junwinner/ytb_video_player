import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerPage extends StatefulWidget {
  final String youtubeUrl;
  const VideoPlayerPage({Key? key, required this.youtubeUrl}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final YoutubePlayerController _controller;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: 0);
  bool _hasError = false;
  PlayerState _playerState = PlayerState.unknown;

  @override
  void initState() {
    super.initState();

    // 自动提取并校验 videoId
    final id = YoutubePlayerController.convertUrlToId(widget.youtubeUrl);
    if (id == null || id.length != 11) _hasError = true;

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    )..loadVideoById(videoId: 'jNI0fiX4q4A');


    // 监听完整播放器状态流（播放/暂停/结束/错误）
    _controller.stream.listen((value) {
      print('监听完整播放器状态流 value:$value');
      setState(() {
        _playerState = value.playerState;
        _hasError = value.hasError;
        print('duration:${value.metaData.duration}');
        _duration = value.metaData.duration;
      });
    });
    // 监听视频进度与缓冲状态的专用流
    _controller.videoStateStream.listen((state) {
      print('监听视频进度与缓冲状态的专用流 position:${state.position}');
      print('监听视频进度与缓冲状态的专用流 loadedFraction:${state.loadedFraction}');
      setState(() {
        _position = state.position;
      });
    });

  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube 播放器')),
      body: _hasError
          ? const Center(child: Text('无效的 YouTube 链接或加载失败'))
          : Column(
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          const SizedBox(height: 8),
          IconButton(
            icon: Icon(
              _playerState == PlayerState.playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
            ),
            iconSize: 48,
            onPressed: () {
              if (_playerState == PlayerState.playing) {
                _controller.pauseVideo(); // API 方法pauseVideociteturn5view0
              } else {
                _controller.playVideo(); // API 方法playVideociteturn5view0
              }
            },
          ),
          Slider(
            min: 0,
            max: _duration.inSeconds.toDouble(),
            value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
            onChanged: (v) => _controller.seekTo(
              seconds: v,
              allowSeekAhead: true, // API 方法seekTociteturn5view0
            ),
          ),
          Text('${_format(_position)} / ${_format(_duration)}'),
        ],
      ),
    );
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }
}
