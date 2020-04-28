import 'package:flutter/material.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';  
import 'videoPlayer.dart';
import 'after_layout.dart';
void main() async {
//  final Directory saveDir = await getExternalStorageDirectory();
  WidgetsFlutterBinding.ensureInitialized(); 
  await TorrentStreamer.init();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/video':(BuildContext context) => VideoApp(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text('Torrent Streamer'),
        ),
        body: TorrentStreamerView()
      ),
      theme: ThemeData(primaryColor: Colors.blue)
    );
  }
}

class MySpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 8, width: 8);
  }
}

class TorrentStreamerView extends StatefulWidget {
  @override
  _TorrentStreamerViewState createState() => _TorrentStreamerViewState();
}

class _TorrentStreamerViewState extends State<TorrentStreamerView> {
  TextEditingController _controller;
  String torrentLink;

  bool isDownloading = false;
  bool isStreamReady = false;
  bool isFetchingMeta = false;
  bool hasError = false;
  Map<dynamic, dynamic> status;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _addTorrentListeners();
  }

  @override
  void dispose() {
    TorrentStreamer.stop();
    TorrentStreamer.removeEventListeners();

    super.dispose();
  }

  void resetState() {
    setState(() {
      isDownloading = false;
      isStreamReady = false;
      isFetchingMeta = false;
      hasError = false;
      status = null;
    });
  }

  void _addTorrentListeners() {
    TorrentStreamer.addEventListener('started', (_) {
      resetState();
      setState(() {
        isDownloading = true;
        isFetchingMeta = true;
      });
    });

    TorrentStreamer.addEventListener('prepared', (_) {
      setState(() {
        isDownloading = true;
        isFetchingMeta = false;
      });
    });

    TorrentStreamer.addEventListener('progress', (data) {
      setState(() => status = data);
    });

    TorrentStreamer.addEventListener('ready', (_) {
      setState(() => isStreamReady = true);
    });

    TorrentStreamer.addEventListener('stopped', (_) {
      resetState();
    });
    
    TorrentStreamer.addEventListener('error', (_) {
      setState(() => hasError = true);
    });
  }

  int _toKBPS(double bps) {
    return (bps / (8 * 1024)).floor();
  }

  Future<void> _cleanDownloads(BuildContext context) async {
    await TorrentStreamer.clean();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Cleared torrent cache!')
      )
    );
  }
  Future<void> _showList(BuildContext context) async {
    Navigator.of(context).pushNamed('/video');
  }

  Future<void> _startDownload() async {
    await TorrentStreamer.stop();
    await TorrentStreamer.start(torrentLink);
  }

  Future<void> _openVideo(BuildContext context) async {
    if (isCompleted) {
      await TorrentStreamer.launchVideo();
    } else {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('你確定嗎？'),
            content: new Text(
              '仍在下載時播放影片是實驗性的'  +
              'and only works on limited set of apps.'
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("是的，繼續"),
                onPressed: () async {
                  await TorrentStreamer.getVideoPath();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
        context: context
      );
    }
  }

  Widget _buildInput(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: new InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(8),
            hintText: '輸入 torrent/magnet link'
          ),
          onChanged: (String value) {
            setState(() {
              torrentLink = value;
            });
          },
        ),
        MySpacer(),
        Row(
          children: <Widget>[
            RaisedButton(
              child: Text('Download'),
              color: Colors.blue,
              onPressed: _startDownload,
              textColor: Colors.white,
            ),
            MySpacer(),
            OutlineButton(
              child: Text('Clear Cache'),
              onPressed: () => _cleanDownloads(context),
            ),
            MySpacer(),
            RaisedButton(
              child: Text('List'),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () => _showList(context),
            ),
            
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ],
    );
  }

  Widget _buildTorrentStatus(BuildContext context) {
    if (hasError) {
      return Text('無法下載種子！');
    } else if (isDownloading) {
      String statusText = '';
      if (isFetchingMeta) {
        statusText = '獲取資訊中';
      } else {
        statusText = 'Progress: ${progress.floor().toString()}% - ' +
          'Speed: ${_toKBPS(speed)} KB/s';
      }

      return Column(
        children: <Widget>[
          Text(statusText),
          MySpacer(),
          LinearProgressIndicator(
            value: !isFetchingMeta ? progress / 100 : null
          ),
          MySpacer(),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('Play Video'),
                color: Colors.blue,
                onPressed: isStreamReady ? () => _openVideo(context) : null
              ),
              MySpacer(),
              OutlineButton(
                child: Text('Stop Download'),
                onPressed: TorrentStreamer.stop,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            // children: _VideoPlayer(_controller)
          )
        ],
      );
    } else {
      return Container(height: 0, width: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildInput(context),
          MySpacer(),
          MySpacer(),
          _buildTorrentStatus(context)
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
      ),
      padding: EdgeInsets.all(16),
    );
  }

  bool get isCompleted => progress == 100;

  double get progress => status != null ? status['progress'] : 0;

  double get speed => status != null ? status['downloadSpeed'] : 0;
}
