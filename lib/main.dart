import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';  
import 'videoPlayer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';


// import 'after_layout.dart';
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
      onGenerateRoute: (settings) {
        
       if (settings.name == VideoApp.routeName) {
        // Cast the arguments to the correct type: ScreenArguments.
        final VideoArguments args = settings.arguments;

        // Then, extract the required data from the arguments and
        // pass the data to the correct screen.
        return MaterialPageRoute(
            builder: (context) {
            return VideoApp(
                srcURL: args.srcURL,
                typeOf: args.typeOf,
            );
            },
        );
        }
      },
      routes: {
        VideoApp.routeName:(BuildContext context) => VideoApp(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text('Video Streamer'),
        ),
        body: TorrentStreamerView()
      ),
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
    );
  }
}

class VideoArguments {
    final String srcURL;
    final String typeOf;
    VideoArguments(this.srcURL, this.typeOf);
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

  String directory;
  List file = new List();

  bool isDownloading = false;
  bool isStreamReady = false;
  bool isFetchingMeta = false;
  bool hasError = false;
  String httpsURL = '';
  Map<dynamic, dynamic> status;

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
//   bool _multiPick = false;
//   FileType _pickingType = FileType.any;
//   TextEditingController _controller = new TextEditingController();    
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

//   Future<void> _cleanDownloads(BuildContext context) async {
//     await TorrentStreamer.clean();
//     Scaffold.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Cleared torrent cache!')
//       )
//     );
//   }
  Future<void> _showList(BuildContext context) async {
      RegExp regExp = new RegExp(
        r"^(http|https):*",
        caseSensitive: false,
        multiLine: false,
        );
    if(regExp.hasMatch(httpsURL)){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoApp(
                    srcURL: httpsURL,
                    typeOf: 'network'),
            ),
        );
    }
    else{
        Fluttertoast.showToast(
            msg: '不正確的網址:$httpsURL',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 12.0
        );
    }
    
  }

//   Future<void> _startDownload() async {
//     await TorrentStreamer.stop();
//     await TorrentStreamer.start(torrentLink);
//   }

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
  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    
    try {
    // 多個檔案
    //   if (_multiPick) {
    //     _path = null;
    //     _paths = await FilePicker.getMultiFilePath(
    //         type: FileType.video,
    //         allowedExtensions: (_extension?.isNotEmpty ?? false)
    //             ? _extension?.replaceAll(' ', '')?.split(',')
    //             : null);
    //   } else {
        // String _path = null;
        _path = await FilePicker.getFilePath(
            type: FileType.video,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
    //   }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
    //   _fileName = _path != null
    //       ? _path.split('/').last
    //       : _paths != null ? _paths.keys.toString() : '...';
    });
    
    // _path = _path.toString();
    
    if( _path != ""){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoApp(
                    srcURL: _path,
                    typeOf: 'file'),
            ),
        );
    }
    
   
  }
  Widget _buildInput(BuildContext context) {
    return Column(
      children: <Widget>[
        // TextField(
        //   controller: _controller,
        //   decoration: new InputDecoration(
        //     border: OutlineInputBorder(),
        //     contentPadding: EdgeInsets.all(8),
        //     hintText: '輸入 torrent/magnet link'
        //   ),
        //   onChanged: (String value) {
        //     setState(() {
        //       torrentLink = value;
        //     });
        //   },
        // ),
         TextField(
          controller: _controller,
          decoration: new InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(8),
            hintText: '輸入 URL'
          ),
          onChanged: (String value) {
            setState(() {
              httpsURL = value;
            });
          },
        ),
        MySpacer(),
        Row(
          children: <Widget>[
            // RaisedButton(
            //   child: Text('Download'),
            //   color: Colors.blue,
            //   onPressed: _startDownload,
            //   textColor: Colors.white,
            // ),
            // MySpacer(),
            // OutlineButton(
            //   child: Text('Clear Cache'),
            //   onPressed: () => _cleanDownloads(context),
            // ),
            // MySpacer(),
            RaisedButton(
              onPressed: () => _openFileExplorer(),
              child: Text("Open file picker"),
            ),
            MySpacer(),
            RaisedButton(
              child: Text('Play'),
            //   color: Colors.blue,
            //   textColor: Colors.white,
              onPressed: () => _showList(context),
            ),
            MySpacer(),
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
              children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        itemCount: file.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(file[index].toString());
                        }),
                    )
              ],
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
