import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:screen/screen.dart';
import 'package:volume_control/volume_control.dart';



// import 'package:path_provider/path_provider.dart';

void main() => runApp(VideoApp());

GlobalKey _aspectRatioKey = GlobalKey();
GlobalKey _playerKey = GlobalKey();

GlobalKey _playing = GlobalKey();
// GlobalKey _rewind = GlobalKey();
// GlobalKey _forward = GlobalKey();
class VideoApp extends StatefulWidget {
    static const routeName = '/VideoApp';
    const VideoApp({Key key, this.srcURL, this.typeOf}) : super(key: key);
    final String srcURL;
    final String typeOf;
 
    @override
    _VideoAppState createState() => _VideoAppState();
}


class _VideoAppState extends State<VideoApp> {
    // Timer _timer;
    //  _VideoAppState({
    //   this.videoInit,
    // });
  

    // String srcURL = '';
    bool _hidePlayControl = true , _hidefastControl = true , _hideLastControl = true;
    bool _videoInit= false;
    bool _hideVolume = true;
    bool _hideBrightness =true;
    bool _isDarkMode = false;
    bool _isPortrait = true;
    int _seconds = 10;
    int _fastSec = 0;
    int _backSec = 0;
    int _playSec = 0;
    double _volume = 0;
    double _onVolume = 0;
    double _brightness = 0;
    double _onBrightness =  0;

    VideoPlayerController _controller;
    Offset dragStart;
    Offset dragDown;
    bool dragHorizontal = false;

    int maxVol;
    Future<void> _initializeVideo;
   
    // bool isPlaying = false;
     
    @override
    void initState() {
        super.initState();
        initVolumeState();
        print(widget.typeOf);
        print(widget.srcURL);
        if(widget.typeOf == 'network'){
            //TEST https://i.imgur.com/I6Xdraq.mp4
            _controller=  VideoPlayerController.network('${widget.srcURL}');
        }
        else if(widget.typeOf == 'file'){
            _controller = VideoPlayerController.file(File(widget.srcURL));
        }
        
        _initializeVideo = _controller.initialize().then((_) {
            setState((){
                _videoInit = false;
                
            });
             _controller.setVolume(1.0);
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            
            _urlLoading();
        });
        
        
       
       
        updateVal();
    }
    
    Future<void> initVolumeState() async {
    if (!mounted) return;
        //read the current volume
        _volume = await VolumeControl.volume;
        setState(() {
        });
     }

    Future<void> updateVal() async {
        
        _onBrightness = await Screen.brightness;
       
        setState(() {
            _brightness = _onBrightness;
            _volume = _controller.value.volume * 100;
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
                // _controller.play();
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
        double rewind , forward;
        double playWidth = MediaQuery.of(context).size.width;
            rewind = playWidth * -0.25;
            forward = playWidth * 0.65;
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
                offstage: (isReind)?_hideLastControl:_hidefastControl,
                    child:ClipRRect(
                    borderRadius: BorderRadius.circular(_getAspectRatioHeight()),
                        child: Material(
                        color: Colors.transparent, //透明
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        child:
                            InkWell(
                                splashColor: Colors.black54,
                                onTap: (){
                                    speedControl();
                                },
                                child:Container(

                                    width: _isPortrait? playWidth * 0.6 :playWidth * 0.6,
                                    height: _videoInit? _getAspectRatioHeight() : 100, 
                                    child:  
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                                    Container(
                                                        margin: isReind?EdgeInsets.only(left: playWidth * .2):EdgeInsets.only(right: playWidth * .2),
                                                        height: 58,
                                                        width: 58,
                                                        child:Column(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                            
                                                            Stack(
                                                                alignment: Alignment(0, 102),
                                                                children: <Widget>[
                                                                    Positioned(
                                                                        top: -1,
                                                                        left: (isReind)?-2:0,
                                                                        child:  Icon(
                                                                            (isReind)?Icons.fast_rewind:Icons.fast_forward,
                                                                            size:  32,
                                                                            color: Colors.black54,
                                                                        ),),
                                                                    Icon(
                                                                        (isReind)?Icons.fast_rewind:Icons.fast_forward,
                                                                        size: 30,
                                                                    ),
                                                                ],
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
                                                                shadows:  <Shadow>[
                                                                    Shadow(
                                                                    offset: Offset(0.0, 0.0),
                                                                    blurRadius: 20.0,
                                                                    color: Colors.grey[50]),
                                                                    Shadow(
                                                                    offset: Offset(0.0, 0.0),
                                                                    blurRadius: 10.0,
                                                                    color: Colors.grey[500]),
                                                                ],
                                                                fontSize: 10.0,
                                                                color: Colors.white,
                                                                ))
                                                    ]
                                                ))
                                            ],
                                        ),
                                )
                        )
                    )
                ),
            ),
        );
    }
    Widget silderBar(){
        if(_videoInit)
        return Positioned(
                top: _isPortrait?_getAspectRatioHeight() * 0.85: _getAspectRatioHeight() * 0.875 ,
                height:_getAspectRatioHeight() * 0.15 ,
                width: MediaQuery.of(context).size.width ,
                    child: Offstage(
                        offstage: _hidePlayControl,
                        child: Container(
                            height: 45,
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
                                        flex: _isPortrait?8:16,  
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
    
    Widget brightness(){
       
        return 
                Align(
                    alignment: Alignment.center,
                    child:
                    Offstage(
                        offstage: _hideBrightness,
                        child: SleekCircularSlider(
                            min: 0,
                            max: 100,
                            initialValue: _brightness,
                            
                            onChange: (double value){
                                // print(value);
                            },
                            innerWidget: (double value) {
                                final roundedValue = value.ceil().toInt().toString();
                                return 
                                Container(
                                    margin: EdgeInsets.all(9),
                                    child:ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0),
                                        child:Container(
                                                // color: _isDarkMode ? Colors.black38: Colors.white70,
                                                color: _brightness < 20?
                                                    Colors.black54:
                                                    _brightness < 40?
                                                    Colors.black38:
                                                    _brightness < 70?
                                                    Colors.black26:
                                                    Colors.black12,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                        Icon(
                                                            Icons.settings_brightness,
                                                            size: 40,
                                                        ),
                                                        Text('$roundedValue%',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w800,
                                                                fontSize: 20,
                                                            )
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                );
                            },
                            appearance: CircularSliderAppearance(
                                // counterClockwise: true,
                                spinnerDuration: 100,
                                customColors: CustomSliderColors(
                                    trackColor: Color(0xffffecd2),
                                    progressBarColors: [
                                        Color(0xfff6d365),
                                        Color(0xfffda085),
                                    ],
                                    // shadowColor: Colors.black38,
                                ),
                                customWidths: CustomSliderWidths(
                                    trackWidth: 2,
                                    progressBarWidth: 8,
                                    shadowWidth: 10),
                                size: 100,
                                startAngle: 150,
                                angleRange: 360,
                                
                            ),
                        )
                        
                       
                    ) 
                );
                
        
    }
    Widget volume(){
      
        return 
                Align(
                    alignment: Alignment.center,
                    child:
                    Offstage(
                        offstage: _hideVolume,
                        child: SleekCircularSlider(
                            min: 0,
                            max: 100,
                            initialValue: _volume,
                            
                            onChange: (double value){
                                // print(value);
                            },
                            innerWidget: (double value) {
                                final roundedValue = value.ceil().toInt().toString();
                                return 
                                Container(
                                    margin: EdgeInsets.all(9),
                                    child:ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0),
                                        child:Container(
                                                color: _isDarkMode ? Colors.black38: Colors.white70,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                        Icon(
                                                            _volume == 0?
                                                            Icons.volume_off:
                                                            _volume < 20?
                                                            Icons.volume_mute:
                                                            _volume < 70?
                                                            Icons.volume_down:
                                                            Icons.volume_up,
                                                            size: 40,
                                                        ),
                                                        Text('$roundedValue%',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w800,
                                                                fontSize: 20,
                                                            )
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                );
                            },
                            appearance: CircularSliderAppearance(
                                counterClockwise: true,
                                spinnerDuration: 100,
                                customColors: CustomSliderColors(
                                    trackColor: Color(0xffc7dffa),
                                    // gradientStartAngle : 0,
                                    // gradientEndAngle : 180,
                                    progressBarColors: [
                                        Color(0xffe0c3fc),
                                        Color(0xff8ec5fc),
                                        Color(0xff38f9d7),
                                    ],
                                    // shadowColor: Colors.black38,
                                ),
                                customWidths: CustomSliderWidths(
                                    trackWidth: 2,
                                    progressBarWidth: 8,
                                    shadowWidth: 10),
                                size: 100,
                                startAngle: 50,
                                angleRange: 360,
                                
                            ),
                        )
                        
                       
                    ) 
                );
                
        
    }
  @override
  Widget build(BuildContext context) {
       
       
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark) // Or Brightness.dark
        );
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        setState(() {
            _isDarkMode = isDarkMode;
            _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        });
        if(!_isPortrait){
            SystemChrome.setEnabledSystemUIOverlays([]);
        }
        else{
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        }

        return MaterialApp(
            darkTheme: ThemeData(
                brightness: Brightness.dark,
            ),
            title: 'Video Demo',
            home: Scaffold(
            resizeToAvoidBottomPadding: false,
            // appBar: AppBar(),
            body: Column(
                children: <Widget>[
                    _isPortrait?Container(height: 24):Container(),
                    Container(
                        child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                            Container(
                                key: _playerKey,
                                child:
                                _controller.value.initialized?
                                GestureDetector(
                                    
                                    onHorizontalDragStart: (details) {
                                        double unitWidth = MediaQuery.of(context).size.width * 0.10;
                                        dragStart = details.globalPosition;
                                        double dy = (dragDown.dy - dragStart.dy);
                                        double dx = dragStart.dx;
                                       
                                        
                                        if(dy.abs() > 5 && dx > unitWidth * 2.0 && dx < unitWidth * 4.0){
                                            setState(() {
                                                _onBrightness = _brightness;
                                                _hideBrightness = false;
                                                _hideVolume = true;
                                            });
                                        }
                                        if(dy.abs() > 5 && dx > unitWidth * 6.0 && dx < unitWidth * 8.0){
                                             setState(() {
                                                _onVolume = _volume;
                                                _hideVolume = false;
                                                _hideBrightness = true;
                                            });
                                        }
                                        _playSec = timeTosec(_controller.value.position).toInt();
                                        
                        
                                    },
                                    onHorizontalDragDown: (details){
                                         dragDown = details.globalPosition;
                                        // print(details);
                                    },
                                    onHorizontalDragUpdate: (details) {
                                        double maxLimit = 100;
                                        double minLimit = 0;
                                        Offset dragUpdate = details.globalPosition;
                                        double offsetY = dragStart.dy - dragUpdate.dy;
                                        double dy = (dragDown.dy - dragStart.dy);
                                        double brightness, volume ;
                                        double dx = (dragStart.dx - dragDown.dx);
                                        double offsetX = (dragUpdate.dx - dragStart.dx);

                                        if(dragStart != null){
                                            final directionUp = offsetY > 0 ? true : false;
                                            
                                            if(dy.abs() > 5 ){
                                               
                                                offsetY = offsetY.abs();

                                                if(directionUp){
                                                    brightness = _onBrightness + offsetY;
                                                    volume = _onVolume + offsetY;
                                                    if(_onBrightness + offsetY > maxLimit)
                                                        brightness = maxLimit;
                                                    if(_onVolume + offsetY > maxLimit)
                                                        volume = maxLimit;
                                                }
                                                else{
                                                    brightness = _onBrightness - offsetY ;
                                                    volume = _onVolume - offsetY;
                                                    if(_onBrightness - offsetY < minLimit)
                                                        brightness = minLimit;  
                                                    if(_onVolume - offsetY < minLimit)
                                                        volume = minLimit;
                                                }

                                                setState(() {
                                                    if(!_hideBrightness )
                                                        _brightness = brightness;
                                                   
                                                    if(!_hideVolume)
                                                        _volume = volume;
                                                });
                                                if(!_hideBrightness)
                                                     Screen.setBrightness(brightness * 0.01);
                                                if(!_hideVolume)
                                                    VolumeControl.setVolume(volume * 0.01);
                                                    //  _controller.setVolume(volume * 0.01);
                                                    
                                            }
                                            if(dx.abs()>10){
                                               
                                                if(offsetX > 0)
                                                    setState(() {
                                                        _hidefastControl = false;
                                                        _fastSec = offsetX.toInt().abs();
                                                        _hideLastControl = true;
                                                    });
                                                else if(offsetX < 0)
                                                    setState(() {
                                                      _hideLastControl = false;
                                                      _backSec = offsetX.toInt().abs();
                                                      _hidefastControl = true;
                                                    });
                                                     print(offsetX.toInt());
                                                _controller.seekTo(Duration(seconds: _playSec + offsetX.toInt()));
                                            }
                                        }
                                    },
                                    onHorizontalDragEnd: (details){
                                        
                                        Timer(Duration(microseconds: 500), () {
                                            setState(() {
                                                _hideVolume = true;
                                                _hideBrightness = true;
                                                dragHorizontal = false;
                                                _hideLastControl = true;
                                                _hidefastControl = true;
                                            });
                                        });
                                    }, //Gestu
                                    //GestureDetector
                                    onDoubleTap:(){
                                        setState(() {
                                            _hidePlayControl = !_hidePlayControl;
                                            _hideLastControl = _hidePlayControl;
                                            _hidefastControl = _hidePlayControl; 
                                        });
                                    },
                                    onTap: () {
                                        // print(_controller.value);
                                        // print(_controller.value.isBuffering);    
                                      
                                       setState(() {
                                            Timer(Duration(seconds: 2), () {
                                               
                                                    _fastSec = 0;
                                                    _backSec = 0;
                                               
                                            });
                                       
                                            _hidePlayControl = false;
                                            _hideLastControl = false;
                                            _hidefastControl = false; 
                                        });
                                            if(_controller.value.isPlaying){
                                                 Timer(Duration(seconds: 2), () {
                                                    setState(() {
                                                        _hidePlayControl = true; 
                                                        _hideLastControl = true;
                                                        _hidefastControl = true; 
                                                    });
                                                 });    
                                            }
                                          
                                       
                                        
                                        //  _controller.seekTo(Duration(seconds: 0/*any second you want*/ ));
                                    },
                                    child:
                                        FutureBuilder(
                                            future: _initializeVideo,
                                            builder: (context, snapshot){
                                                // print(_controller);
                                                // print( _controller.value.aspectRatio );
                                                return 
                                                 Container(
                                                    height: _isPortrait ? MediaQuery.of(context).size.width / _controller.value.aspectRatio : MediaQuery.of(context).size.height  ,
                                                    child:AspectRatio(    
                                                        key: _aspectRatioKey,
                                                        aspectRatio:  _controller.value.aspectRatio  ,
                                                            child: VideoPlayer(_controller),
                                                    ),
                                                );
                                            }
                                        ),
                                        ): Container(
                                            child: Text("看來出了一些錯誤"),
                                        ),
                            ),
                            
                           
                            fastIcon(context, Icons.fast_forward),
                            fastIcon(context, Icons.fast_rewind),
                            silderBar(),
                           
                            Align(
                                // alignment: FractionalOffset(0.5, 0),
                                child:
                                Offstage(
                                    offstage: _hidePlayControl,
                                    child: 
                                    ClipRRect( //容器圓形
                                        borderRadius: BorderRadius.circular(100.0),
                                        child: Material( //動畫效果
                                            color:  _isDarkMode ? Colors.black38: Colors.white70, //透明
                                            borderRadius: BorderRadius.all(Radius.circular(100.0)),
                                            // shape: CircleBorder(),
                                            child:IconButton(
                                                iconSize: 55,
                                                key: _playing,
                                                onPressed: () {
                                                    setState(() {
                                                        if(_controller.value.isPlaying){
                                                            _controller.pause();
                                                            _hidePlayControl = false;
                                                            _hideLastControl = false;
                                                            _hidefastControl = false; 
                                                        }
                                                        else{
                                                            _controller.play();
                                                            _hidePlayControl = true;
                                                            _hideLastControl = true;
                                                            _hidefastControl = true;  
                                                        }
                                                    
                                                    });
                                                },
                                                icon: Icon(
                                                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                                    size: 40,
                                                ),
                                            ),
                                            
                                        ),
                                    )
                                )
                            ),
                            brightness(),
                            volume(),
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

