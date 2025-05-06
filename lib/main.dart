import 'package:flutter/material.dart';
import 'package:ytb_iframe2/video_player_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String videoUrl = 'https://www.youtube.com/watch?v=jNI0fiX4q4A';

  void _incrementCounter() {
    _showBottomSheet();
    return setState(() {
      _counter++;
    });
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

  void _showBottomSheet() {
    Color titleColor = const Color(0xFF323C50);
    Color subTitleColor = const Color(0xFF8E95A3);
    TextStyle titleStyle = TextStyle(color: titleColor, fontSize: 18);
    TextStyle subTitleStyle = TextStyle(color: subTitleColor, fontSize: 13);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: const Color(0xFFF6F8F9),
      builder: (context) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 10, right: 20, bottom: 60),
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
                          Navigator.pop(context);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(youtubeUrl: videoUrl),
                  ),
                )
              },
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
