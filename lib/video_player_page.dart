import 'dart:async';
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
  late YoutubePlayerController _controller;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final List<Subtitle> _subtitles = [];
  int _currentSubtitleIndex = 0;
  bool _isReady = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 加载字幕 JSON
    final jsonString = await rootBundle.loadString('assets/subtitles.json');
    final data = jsonDecode(jsonString) as List<dynamic>;
    _subtitles.addAll(data.map((e) => Subtitle.fromJson(e as Map<String, dynamic>)));

    // 初始化 YouTube 播放器
    final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
    );

    // _controller = YoutubePlayerController(
    //   params: const YoutubePlayerParams(
    //     showControls: true,
    //     showFullscreenButton: true,
    //   ),
    // )..loadVideoById(videoId: videoId);

    // 监听播放进度，同步滚动并高亮
    _controller.videoStateStream.listen((state) {
      final pos = state.position.inMilliseconds / 1000.0;
      final idx = _subtitles.indexWhere((s) => pos >= s.beginSec && pos < s.endSec);
      if (idx != -1 && idx != _currentSubtitleIndex) {
        // **关键**：调用 setState 触发重建以应用高亮样式
        setState(() {
          _currentSubtitleIndex = idx;
        });
        _scheduleScroll(idx);
      }
    });

    setState(() => _isReady = true);
  }

  /// 防抖：200ms 内只执行最后一次滚动
  void _scheduleScroll(int index) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      final scrollToIndex = index == 0 ? 0 : index - 1;
      _itemScrollController.scrollTo(
        index: scrollToIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0, // 前一条置顶，当前条在第2行
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('youtube视频播放')),
      body: Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: YoutubePlayer(controller: _controller)),
          const Divider(height: 1),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: _subtitles.length,
              itemScrollController: _itemScrollController,
              itemBuilder: (context, index) {
                final s = _subtitles[index];
                final active = index == _currentSubtitleIndex;
                return GestureDetector(
                  onTap: () {
                    _controller.seekTo(seconds: s.beginSec); // 点击跳转
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    color: active ? Theme.of(context).highlightColor : Colors.transparent,
                    child: Text(
                      s.text,
                      style: TextStyle(
                        fontSize: active ? 18 : 16,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.start,
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
