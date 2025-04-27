import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerPage extends StatefulWidget {
  /// 输入完整 YouTube URL
  final String youtubeUrl;

  const VideoPlayerPage({
    super.key,
    required this.youtubeUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final YoutubePlayerController _controller;

  /// 字幕列表
  final List<Map<String, dynamic>> _subtitles = [
    {"start": 0.0,  "end": 2.5,  "text": "欢迎观看 Flutter 视频示例"},
    {"start": 2.5,  "end": 5.0,  "text": "本视频演示如何播放 YouTube 视频"},
    {"start": 5.0,  "end": 8.0,  "text": "以及在下方显示滚动字幕"},
    {"start": 8.0,  "end": 12.0, "text": "字幕数据以 JSON 形式内置组件中"},
  ];


  // 正则提取 videoId
  static final _idRegex = RegExp(r'(?<=v=|\/)([0-9A-Za-z_-]{11}).*');

  String _extractId(String url) {
    final m = _idRegex.firstMatch(url);
    if (m != null) return m.group(1)!;
    throw ArgumentError('无法从 URL 提取 videoId');
  }

  @override
  void initState() {
    super.initState();
    final id = _extractId(widget.youtubeUrl);
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    )..loadVideoById(videoId: id);  // 加载并自动播放视频
  }

  @override
  void dispose() {
    _controller.close();  // 释放底层 WebView 资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube 播放与字幕')),
      body: Column(
        children: [
          // 上部播放器：16:9 固定比例
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: _controller),
          ),
          const Divider(height: 1),
          // 下部字幕：Expanded + ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _subtitles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _subtitles[index]['text'],
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
