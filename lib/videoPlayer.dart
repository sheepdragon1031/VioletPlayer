import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

GlobalKey _aspectRatioKey = GlobalKey();
GlobalKey _playerKey = GlobalKey();

GlobalKey _playing = GlobalKey();
GlobalKey _rewind = GlobalKey();
GlobalKey _forward = GlobalKey();
class VideoApp extends StatefulWidget {
    @override
    _VideoAppState createState() => _VideoAppState();
}


class _VideoAppState extends State<VideoApp> {
    // Timer _timer;
    bool _hidePlayControl = true;
    bool _videoInit = false;
    int _seconds = 10;
    int _fastSec = 0;
    int _backSec = 0;
    VideoPlayerController _controller;
    // bool isPlaying = false;
    @override
        void initState() {
            super.initState();
            // _controller = VideoPlayerController.network(
            // //    'https://router.sheepdragon.ga/download/%5bNekomoe%20kissaten%5d%5bAzur%20Lane%5d%5b11%5d%5b1080p%5d%5bCHT%5d.mp4'
            // 'https://i.imgur.com/I6Xdraq.mp4'
            // )
            var file = new File('/storage/emulated/0/Download/[Nekomoe kissaten][Azur Lane][11][1080p][CHT].mp4');
            
         
            _controller = VideoPlayerController.file(file)
            ..initialize().then((_) {
                setState((){
                    _videoInit = false;
                });
                // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              
                _urlLoading();
            });
    }
   
    double timeTosec(time){
            var strTime = time.toString().split(':');
            int hrSec =  int.parse(strTime[0]);
            int minSec = int.parse(strTime[1]);
            double sec = double.parse(strTime[2]);
            double total = hrSec * 3600 + minSec * 60 + sec;
            return total;
    }
    String timeTomin(time){
            var strTime = time.toString().split(':');
            int hrSec =  int.parse(strTime[0]);
            int minSec = int.parse(strTime[1]);
            int sec = double.parse(strTime[2]).toInt();
            int total = hrSec * 60 + minSec ;
            return total.toString().padLeft(2,'0') +':' + sec.toString().padLeft(2,'0');
    }
    
    void _urlLoading() async {
            await _controller.initialize();
            setState(() {
                _videoInit = true;
                //   _videoError = false;`
                _controller.play();
            });
    }
     _getAspectRatioHeight(){
        if(_videoInit){
            RenderBox renderBoxRed;
            renderBoxRed = _aspectRatioKey.currentContext.findRenderObject();
            return renderBoxRed.size.height;
        }
        else{
            return 200;
        }
       
      
    }
    Widget fasttext (context , iconName){
        bool isReind = iconName.toString() == 'IconData(U+0E020)';
        double rewind = MediaQuery.of(context).size.width * 0.25;
        double forward = MediaQuery.of(context).size.width * 0.72;
        
        return Positioned(
                left: (isReind)?  rewind: forward,
                // width: MediaQuery.of(context).size.width * 0.65,
                height: _videoInit? _getAspectRatioHeight() * -.2 : 100, 
                child:  Offstage(
                    offstage: _hidePlayControl,
                    child: Text((isReind)?'$_backSec 秒':'$_fastSec 秒',
                    style: TextStyle(
                        fontSize: 16.0,
                        ),
                    ),
                )
        );
    }
    Widget fastIcon (context , iconName){
        bool isReind = iconName.toString() == 'IconData(U+0E020)';
        double rewind = MediaQuery.of(context).size.width * 0.0;
        double forward = MediaQuery.of(context).size.width * 0.6;
      
        speedControl(){
            setState(() {
                _hidePlayControl = false; 
            });
            
            if(isReind){
                
                    setState(() {
                        _backSec += _seconds;
                    });
                //後退
                _controller.seekTo(Duration(seconds: timeTosec(_controller.value.position).toInt() - _backSec));
            }
            else{
                double jumpTo = timeTosec(_controller.value.position) + _fastSec.toDouble() ;
                if(jumpTo < timeTosec(_controller.value.duration) ){
                  
                    setState(() {
                        _fastSec += _seconds;
                    });
                }
               
                //快進
                _controller.seekTo(Duration(seconds: timeTosec(_controller.value.position).toInt() + _fastSec));
            }
            print(_backSec);
            
        }
        
        return Positioned(
            left: (isReind)?  rewind: forward,
            // right: (iconName.toString() == 'IconData(U+0E01F)')? MediaQuery.of(context).size.width * 0.1 : 0,
            // width: MediaQuery.of(context).size.width * 0.4,
            // height: _videoInit? _getAspectRatioHeight() * 0.9 : 100, 
            child:  Offstage(
                offstage: _hidePlayControl,
                child:
                    Container(
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: _videoInit? _getAspectRatioHeight() * 0.8 : 100, 
                        child:  
                        ClipRRect(
                        // borderRadius: BorderRadius.circular(5.0),
                        child: 
                            Material(
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                            color: Colors.transparent,
                            child: 
                            InkWell(
                                onTap: (){
                                   speedControl();
                                },
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                                // ClipRRect(
                                                // borderRadius: BorderRadius.circular(100.0),
                                                //     child: Material(
                                                //     color: Colors.blue, //透明
                                                //     borderRadius: BorderRadius.all(Radius.circular(100.0)),
                                                //     child:
                                                        Column(
                                                            children: <Widget>[
                                                                Icon(
                                                                    (isReind)?Icons.fast_rewind:Icons.fast_forward,
                                                                    size: 30,
                                                                ),
                                                                // IconButton(      
                                                                //     key: (isReind)? _rewind: _forward,
                                                                //     onPressed: () {
                                                                //         speedControl();
                                                                //     },
                                                                //     icon: Icon(
                                                                //         iconName 
                                                                //     ),
                                                                // ),
                                                                Text((isReind)?  '${_backSec+10} 秒': '${_fastSec+10} 秒',
                                                                style: TextStyle(
                                                                    fontSize: 10.0,
                                                                    color: Colors.grey[0],
                                                                    ))
                                                            ]
                                                        )
                                                //     )
                                                // ),
                                    ],
                                ),
                            ),
                        ),
                    ), 
                    )
                   
            ),
        );
    }
    Widget silderBar(){
        if(_videoInit)
        return Positioned(
                top: _getAspectRatioHeight() * 0.85 ,
                height:_getAspectRatioHeight() * 0.15 ,
                width: MediaQuery.of(context).size.width ,
                    child: Offstage(
                        offstage: _hidePlayControl,
                        child: Container(
                            color: Colors.transparent,
                            child: Row(
                                children: <Widget>[
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            '${timeTomin(_controller.value.position)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                    fontSize: 12
                                                ),
                                            ),
                                    ),
                                    Expanded(
                                        flex: 8,  
                                        child:
                                            SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                    thumbShape: RoundSliderThumbShape(
                                                        enabledThumbRadius: 8), //圓點
                                                    overlayShape: RoundSliderOverlayShape(
                                                        overlayRadius: 14),//hover圓點
                                                ),
                                                child: Slider(
                                                    value: timeTosec(_controller.value.position),
                                                    min: 0.0,
                                                    max: timeTosec(_controller.value.duration),
                                                    // divisions: 0,
                                                    activeColor: Colors.grey,
                                                    onChanged: (e) {
                                                        setState(() {
                                                            _controller.seekTo(Duration(seconds: e.roundToDouble().toInt()));
                                                        });
                                                },
                                                
                                            ),
                                            
                                            ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            '${timeTomin(_controller.value.duration)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                    fontSize: 12
                                                ),
                                            ),
                                    ),
                                   
                                ],
                            ),
                        )
                    )
                );
        else
            return Container();
    }
  @override
  Widget build(BuildContext context) {
        
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark) // Or Brightness.dark
        );
         
        return MaterialApp(
            darkTheme: ThemeData(
                
                brightness: Brightness.dark,
            ),
            title: 'Video Demo',
            home: Scaffold(
            // appBar: AppBar(),
            body: Column(
                children: <Widget>[
                    Container(height: 24),
                    Container(
                        child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                            Container(
                                key: _playerKey,
                                child:
                                _controller.value.initialized?
                                GestureDetector( //GestureDetector
                                    onTap: () {
                                        // print(_controller.value);
                                        // print(_controller.value.isBuffering);    
                                      
                                       setState(() {
                                             Timer(Duration(seconds: 2), () {
                                               
                                                    _fastSec = 0;
                                                    _backSec = 0;
                                               
                                            });
                                       
                                            _hidePlayControl = false;
                                        });
                                            if(_controller.value.isPlaying){
                                                 Timer(Duration(seconds: 2), () {
                                                    setState(() {
                                                        _hidePlayControl = true; 
                                                    });
                                                 });    
                                            }
                                          
                                       
                                        
                                        //  _controller.seekTo(Duration(seconds: 0/*any second you want*/ ));
                                    },
                                    child: 
                                        AspectRatio(
                                            key: _aspectRatioKey,
                                            aspectRatio: _controller.value.aspectRatio,
                                            child: VideoPlayer(_controller),
                                        ),
                                        ): Container(
                                            child: Text("看來出了一些錯誤"),
                                        ),
                            ),
                            
                            fastIcon(context, Icons.fast_forward),
                            fastIcon(context, Icons.fast_rewind),
                            silderBar(),
                           
                            Align(
                                alignment: FractionalOffset(0.5, 1.5),
                                child:
                                Offstage(
                                    offstage: _hidePlayControl,
                                    child: 
                                    ClipRRect( //容器圓形
                                        borderRadius: BorderRadius.circular(100.0),
                                        child: Material( //動畫效果
                                            color: Color.fromRGBO( 0, 0, 0, .15), //透明
                                            borderRadius: BorderRadius.all(Radius.circular(100.0)),
                                            // shape: CircleBorder(),
                                                child:IconButton(
                                                key: _playing,
                                                onPressed: () {
                                                    setState(() {
                                                        if(_controller.value.isPlaying){
                                                            _controller.pause();
                                                            _hidePlayControl = false;
                                                        }
                                                        else{
                                                            _controller.play();
                                                            _hidePlayControl = true; 
                                                        }
                                                    
                                                    });
                                                },
                                                icon: Icon(
                                                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                                ),
                                            ),
                                            
                                        ),
                                    )
                                )
                            ),
                        ],
                        ),
                    ),
                    
                ],
            )
        ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

