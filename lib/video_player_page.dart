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
  YoutubePlayerController? _controller;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final List<Subtitle> _subtitles = [];
  int _currentSubtitleIndex = -1; // 默认没有选中
  bool _isReady = false;
  Timer? _timer; // 定时器，实时刷新字幕

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. 读取字幕
    final jsonString = await rootBundle.loadString('assets/subtitles.json');
    final data = jsonDecode(jsonString) as List<dynamic>;
    _subtitles.addAll(data.map((e) => Subtitle.fromJson(e as Map<String, dynamic>)));

    // 2. 初始化播放器
    final videoId = YoutubePlayerController.convertUrlToId(widget.youtubeUrl)!;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    // 3. 每 300ms 检查一次当前播放时间，更新字幕高亮
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) async {
      final pos = await _controller!.currentTime; // 获取当前秒数
      _updateCurrentSubtitle(pos);
    });

    // 4. 完成
    setState(() => _isReady = true);
  }

  void _updateCurrentSubtitle(double currentSec) {
    final idx = _subtitles.indexWhere(
          (s) => currentSec >= s.beginSec && currentSec < s.endSec,
    );
    if (idx != -1 && idx != _currentSubtitleIndex) {
      setState(() {
        _currentSubtitleIndex = idx;
      });

      // 获取当前可见的项的索引
      final visibleIndices = _itemPositionsListener.itemPositions.value
          .map((position) => position.index)
          .toSet();

      // 如果当前高亮字幕不在可见范围内，或者在可见范围的底部，则滚动
      if (!visibleIndices.contains(idx) ||
          visibleIndices.last == idx) {
        _itemScrollController.scrollTo(
          index: idx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1, // 将目标项滚动到视图顶部附近
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('视频与高亮滚动字幕')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: _controller!),
          ),
          const Divider(height: 1),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: _subtitles.length,
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              itemBuilder: (context, index) {
                final s = _subtitles[index];
                final isActive = index == _currentSubtitleIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: isActive ? Colors.yellow.shade100 : Colors.transparent,
                  child: Text(
                    "[${s.beginSec.toStringAsFixed(2)}s] ${s.text}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.blueAccent : Colors.black,
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
