import 'package:flutter/material.dart';
import 'package:ytb_iframe2/video_player_page.dart';

class MediaImportView extends StatelessWidget {
  const MediaImportView({super.key});

  @override
  Widget build(BuildContext context) {
    Color titleColor = const Color(0xFF323C50);
    Color subTitleColor = const Color(0xFF8E95A3);
    TextStyle titleStyle = TextStyle(color: titleColor, fontSize: 18);
    TextStyle subTitleStyle = TextStyle(color: subTitleColor, fontSize: 13);
    String videoUrl = 'https://www.youtube.com/watch?v=jNI0fiX4q4A';
    return Stack(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部标题
              const Padding(
                padding: EdgeInsets.only(top: 15, bottom: 5),
                child: Center(
                  child: Text(
                    '导入视频或音频',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF05142F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // 说明文字
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '请选择视频来源',
                  style: TextStyle(color: subTitleColor, fontSize: 15),
                ),
              ),
              // 选项部分
              Column(
                children: [
                  optionCell(
                    title: 'Youtube 网址',
                    subtitle: '在应用中播放Youtube视频，无需下载',
                    titleStyle: titleStyle,
                    subTitleStyle: subTitleStyle,
                    onTap: () {
                      print('点击youtube网址');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerPage(youtubeUrl: videoUrl),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  optionCell(
                    title: '本地媒体',
                    subtitle: '从您本地存储导入媒体文件',
                    titleStyle: titleStyle,
                    subTitleStyle: subTitleStyle,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  optionCell(
                    title: '相册',
                    subtitle: '从您的相册导入媒体文件',
                    titleStyle: titleStyle,
                    subTitleStyle: subTitleStyle,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 关闭按钮，使用 Positioned 进行绝对定位
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

// 选项单元格
Widget optionCell({
  required String title,
  required String subtitle,
  TextStyle? titleStyle,
  TextStyle? subTitleStyle,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ListTile(
      title: Text(title, style: titleStyle ?? const TextStyle(fontSize: 18)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(subtitle,
            style: subTitleStyle ?? const TextStyle(fontSize: 16)),
      ),
      onTap: onTap,
    ),
  );
}
