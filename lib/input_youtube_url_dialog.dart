import 'package:flutter/material.dart';
import 'package:ytb_iframe2/video_player_page.dart';

class AddYoutubeUrlDialog extends StatelessWidget {
  const AddYoutubeUrlDialog({super.key});

  bool isYouTubeUrl(String url) {
    final RegExp youtubeRegex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/(watch\?v=|embed/|v/|shorts/)?([a-zA-Z0-9_-]{11})$',
      caseSensitive: false,
    );
    return youtubeRegex.hasMatch(url);
  }

  void handleSubmitUrl(BuildContext context, String url) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的 YouTube URL')),
      );
      return;
    }
    if (!isYouTubeUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('输入的不是有效的 YouTube URL')),
      );
      return;
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(youtubeUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    urlController.text = 'https://www.youtube.com/watch?v=jNI0fiX4q4A';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Center(
        child: Text(
          '添加URL',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '需要网络环境支持访问',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5463),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: '粘贴 Youtube 视频网址',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFA8AEBA),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF5858F5),
                  width: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F5F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    color: Color(0xFF5858F5),
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  handleSubmitUrl(context, urlController.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5858F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '确定',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}