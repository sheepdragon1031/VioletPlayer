import 'dart:async';

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

    VideoPlayerController _controller;
    bool isPlaying = false;
    @override
        void initState() {
            super.initState();
            _controller = VideoPlayerController.network(
            //    'https://router.sheepdragon.ga/download/%5bNekomoe%20kissaten%5d%5bAzur%20Lane%5d%5b11%5d%5b1080p%5d%5bCHT%5d.mp4'
            'https://i.imgur.com/I6Xdraq.mp4'
            )
            ..initialize().then((_) {
               
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                setState((){

                });
                _urlLoading();
            });
    }
   
    double timeTosec(time){
            var strTime = time.toString().split(':');
            int hrSec =  int.parse(strTime[0]);
            int minSec = int.parse(strTime[1]);
            double sec = double.parse(strTime[2]);
            double total = hrSec * 3600 + minSec * 60 + sec;
            print(total);
            return total;
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
        RenderBox renderBoxRed;
        renderBoxRed = _aspectRatioKey.currentContext.findRenderObject();
        return renderBoxRed.size.height;
      
    }
    Widget fastIcon (context , iconName){
        bool isReind = iconName.toString() == 'IconData(U+0E020)';
        double rewind = MediaQuery.of(context).size.width * 0.1;
        double forward = MediaQuery.of(context).size.width * 0.6;

            return Positioned(
                left: (isReind)?  rewind: forward,
                // right: (iconName.toString() == 'IconData(U+0E01F)')? MediaQuery.of(context).size.width * 0.1 : 0,
                width: MediaQuery.of(context).size.width * 0.3,
                height: _videoInit? _getAspectRatioHeight() * 0.9 : 100, 
                child:  Offstage(
                    offstage: _hidePlayControl,
                    child:ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                            color: Colors.transparent, //透明
                            borderRadius: BorderRadius.all(Radius.circular(100.0)),
                            child:IconButton(
                                    key: (isReind)? _rewind: _forward,
                                    onPressed: () {

                                    },
                                    icon: Icon(
                                        iconName 
                                    ),
                                )
                            )
                        ),
                ),
            );
        
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
                                            _hidePlayControl = false;
                                            if(_controller.value.isPlaying){
                                                //  print('object1');
                                                 Timer(Duration(milliseconds: 800), () {
                                                    setState(() {
                                                        _hidePlayControl = true; 
                                                    });
                                                 });
                                                 
                                            }
                                          
                                        });
                                       
                                  
                                         print(_hidePlayControl);
                                        //  _controller.seekTo(Duration(seconds: 0/*any second you want*/ ));
                                        // print( _controller.value.duration);
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

