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
    final b = (json['BeginTime'] as num? ?? 0).toDouble();
    final e = (json['EndTime'] as num? ?? 0).toDouble();
    return Subtitle(
        beginSec: b / 1000, endSec: e / 1000, text: json['Text'] ?? '');
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String youtubeUrl;

  const VideoPlayerPage({super.key, required this.youtubeUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final YoutubePlayerController _controller;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final List<Subtitle> _subtitles = [];
  int _currentSubtitleIndex = 0;
  bool _isReady = false;
  bool _isSeeking = false; // 用户主动跳转标志
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. 加载字幕 JSON
    final jsonString = await rootBundle.loadString('assets/subtitles.json');
    final data = jsonDecode(jsonString) as List<dynamic>;
    _subtitles
        .addAll(data.map((e) => Subtitle.fromJson(e as Map<String, dynamic>)));

    // 2. 初始化 YouTube 播放器
    final vid = YoutubePlayerController.convertUrlToId(widget.youtubeUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: vid,
      autoPlay: true,
      params: const YoutubePlayerParams(
          showControls: true, showFullscreenButton: true),
    );

    // 3. 监听播放进度，自动滚动并高亮
    _controller.videoStateStream.listen((state) {
      if (_isSeeking) {
        // 跳转期间忽略防抖
        return;
      }
      final pos = state.position.inMilliseconds / 1000.0; // 单位秒
      final idx =
          _subtitles.indexWhere((s) => pos >= s.beginSec && pos < s.endSec);
      if (idx != -1 && idx != _currentSubtitleIndex) {
        setState(() => _currentSubtitleIndex = idx); // 更新高亮
        _scheduleScroll(idx);
      }
    });

    setState(() => _isReady = true);
  }

  /// 防抖：200ms 内只执行最后一次滚动
  void _scheduleScroll(int index) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      final target = index == 0 ? 0 : index - 1;
      _itemScrollController.scrollTo(
        index: target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: 0.0, // 前一条置顶，使当前条在第2行
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
      appBar: AppBar(title: const Text('Youtube视频播放')),
      body: Column(
        children: [
          // 视频播放器
          AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: _controller)),
          const Divider(height: 1),
          // 字幕列表
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: _subtitles.length,
              itemScrollController: _itemScrollController,
              itemBuilder: (context, i) {
                final s = _subtitles[i];
                final active = i == _currentSubtitleIndex;
                return GestureDetector(
                  onTap: () async {
                    // 点击跳转：设置标志，更新高亮，并调用 seekTo/playVideo
                    setState(() {
                      _currentSubtitleIndex = i;
                      _isSeeking = true;
                    });
                    await _controller.seekTo(
                        seconds: s.beginSec, allowSeekAhead: true);
                    await _controller.playVideo();
                    // 延时后解除跳转标志，恢复自动滚动
                    Future.delayed(const Duration(milliseconds: 500),
                        () => setState(() => _isSeeking = false));
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    color: active
                        ? Theme.of(context).highlightColor
                        : Colors.transparent,
                    child: Text(
                      s.text,
                      style: TextStyle(
                        fontSize: active ? 18 : 16,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
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
