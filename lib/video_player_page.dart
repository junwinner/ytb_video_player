import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// 字幕模型：JSON 的 BeginTime/EndTime 单位为毫秒
class Subtitle {
  final double beginSec, endSec;
  final String text;

  Subtitle({required this.beginSec, required this.endSec, required this.text});

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    // JSON 时间是毫秒，/1000 转为秒
    final beginMs = (json['BeginTime'] as num? ?? 0).toDouble();
    final endMs = (json['EndTime'] as num? ?? 0).toDouble();
    return Subtitle(
      beginSec: beginMs / 1000.0,
      endSec: endMs / 1000.0,
      text: json['Text'] as String? ?? '',
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String youtubeUrl;

  const VideoPlayerPage({super.key, required this.youtubeUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  YoutubePlayerController? _controller; // 可空，避免未初始化访问
  final ItemScrollController _itemScrollController = ItemScrollController(); //
  final List<Subtitle> _subtitles = [];
  int _currentSubtitleIndex = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initialize(); // 异步加载字幕并初始化播放器
  }

  Future<void> _initialize() async {
    // 1. 从 assets 读取 JSON 文本
    final jsonString = await rootBundle.loadString('assets/subtitles.json');
    final data = jsonDecode(jsonString) as List<dynamic>; //
    _subtitles
        .addAll(data.map((e) => Subtitle.fromJson(e as Map<String, dynamic>)));

    // 2. 提取 videoId 并创建播放器控制器
    final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    // 3. 监听播放进度，按秒同步滚动字幕
    _controller!.videoStateStream.listen((state) {
      final posSec = state.position.inSeconds.toDouble() ?? 0.0;
      final idx = _subtitles
          .indexWhere((s) => posSec >= s.beginSec && posSec < s.endSec);
      if (idx != -1 && idx != _currentSubtitleIndex) {
        _currentSubtitleIndex = idx;
        _itemScrollController.scrollTo(
          index: idx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        ); //
      }
    });

    // 4. 标记准备完成并刷新 UI
    setState(() => _isReady = true);
  }

  @override
  void dispose() {
    _controller?.close(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('视频与自动滚动字幕')),
      body: Column(
        children: [
          // 上部：16:9 播放器
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: _controller!), //
          ),
          const Divider(height: 1),
          // 下部：可滚动字幕列表
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: _subtitles.length,
              itemScrollController: _itemScrollController,
              itemBuilder: (context, index) {
                final s = _subtitles[index];
                final isActive = index == _currentSubtitleIndex;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: isActive ? Colors.grey.shade200 : null,
                  child: Text(
                    "[${s.beginSec.toStringAsFixed(2)}s] ${s.text}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
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
