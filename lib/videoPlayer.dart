import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
    @override
    _VideoAppState createState() => _VideoAppState();
}


class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  bool isPlaying = false;
  @override
    void initState() {
        super.initState();
        _controller = VideoPlayerController.network(
        'https://i.imgur.com/I6Xdraq.mp4')
        ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Stack(
            children: <Widget>[
                Center(
                    child:
                    _controller.value.initialized?
                    GestureDetector( //GestureDetector
                        onTap: () {
                            if(_controller.value.isPlaying){

                            }
                           _controller.seekTo(Duration(seconds: 10/*any second you want*/ ));


                            print( _controller.value.duration);
                        },
                        child: 
                            AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                            ),
                            ): Container(
                                child: Text("看來出了一些錯誤"),
                            ),
                ),
                Align(
                    alignment: FractionalOffset(0.5, 0.5),
                    child:
                    ClipRRect( //容器圓形
                        borderRadius: BorderRadius.circular(100.0),
                        child: Material( //動畫效果
                        color: Colors.transparent, //透明
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        // shape: CircleBorder(),
                            child:IconButton(
                            onPressed: () {
                                setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                                });
                            },
                            icon: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                        ),
                        
                    )  
                    ,
                    )
                ),
                Align(
                    alignment: Alignment(0, 0.3),
                    child:LinearProgressIndicator(
                        value:  timeTosec(_controller.value.position) / timeTosec( _controller.value.duration)
                    )
                ),
            ],
        ),

        
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}