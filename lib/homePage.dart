import 'package:audio_manager/audio_manager.dart';
import 'package:demomediaplayer/httpRest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clsList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<playList> _playList = <playList>[];
  List<Widget> _widgetPlayList = <Widget>[];
  List<bool> _indicatorVisibility = <bool>[];
  bool _playerVisibility = false;
  //player
  String _platformVersion = 'Unknown';
  bool isPlaying = false;
  Duration _duration = Duration(days: 0, hours: 0, minutes: 0, seconds: 0);
  Duration _position = Duration(days: 0, hours: 0, minutes: 0, seconds: 0);
  double _slider = 0;
  double _sliderVolume = 0;
  String _error = "";
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;


  @override
  void dispose(){
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    initPlatformState();
    setupAudio();
  }
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
  void setupAudio() {
    List<AudioInfo> _list = [];
    if(_playList.length == 0) {
      return;
    }

    _playList.forEach((item) => _list.add(AudioInfo(item.previewUrl,
        title: item.trackName, desc: item.collectionName, coverUrl: item.artworkUrl60)));

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print(
              "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          setState(() {});
          AudioManager.instance.updateLrc("audio resource loading....");
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = "";
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          setState(() {});
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          _error = args;
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          //AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body:
          Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    padding: const EdgeInsets.all(20),
                    color: const Color(0xFFCCCCCC),
                    child: TextField(
                        onSubmitted: (textVal) async {
                          if(textVal.length < 3) {
                            return;
                          }

                          var httpRest = HttpRest();
                          _playList = await httpRest.searchTerm(textVal);
                          if(_playList.isEmpty){
                            return;
                          }
                          _widgetPlayList = <Widget>[];
                          _indicatorVisibility.clear();
                          _playerVisibility = false;
                          for(int i = 0; i < _playList.length; i++){
                            _indicatorVisibility.add(false);
                            Widget _widgetTemp =
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _playerVisibility = true;
                                  _indicatorVisibility[i] = true;
                                  AudioManager.instance.play(index: i,auto: true);

                                });
                              },
                              child: Card(
                                  child:
                                  Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 50,
                                            child:Image.network(_playList[i].artworkUrl60),
                                          ),
                                          Container(
                                            width: 300,
                                            alignment: Alignment.centerLeft,
                                            child:Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  Text(_playList[i].trackName, textAlign: TextAlign.left, style: TextStyle(fontSize: 12),),
                                                  Text(_playList[i].collectionName,textAlign: TextAlign.left, style: TextStyle(fontSize: 10)),
                                                  Text(_playList[i].artistName,textAlign: TextAlign.left, style: TextStyle(fontSize: 10)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            key: Key("indicator" + i.toString()),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 50,
                                              child:Image.network('https://e7.pngegg.com/pngimages/224/706/png-clipart-music-equalization-music-sound-waves-miscellaneous-text-thumbnail.png'),
                                            ),
                                            maintainSize: true,
                                            maintainAnimation: true,
                                            maintainState: true,
                                            maintainInteractivity: true,
                                            maintainSemantics: true,
                                            visible: _indicatorVisibility[i],//
                                          )


                                        ],
                                      )
                                  )


                              )
                            );
                            _widgetPlayList.add(_widgetTemp);
                          }
                          setState(() {
                            setupAudio();
                            _widgetPlayList = _widgetPlayList;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a search term',
                        ),
                    ),
                  ),
                Container(
                  height: _playerVisibility ? MediaQuery.of(context).size.height * 0.65 : MediaQuery.of(context).size.height * 0.75,
                  child: Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _widgetPlayList,
                      ),
                    ),
                  )
                ),
                Visibility(
                  visible: _playerVisibility,
                    child:
                      Container(
      //                    height: MediaQuery.of(context).size.height * 0.4,
                          child: bottomPanel()
                      )
                )
              ],
            )

    );
  }
  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(playMode),
                onPressed: () {
                  playMode = AudioManager.instance.nextMode();
                  setState(() {});
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.black,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.stop()),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.black,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.black,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.black,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                          (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget volumeFrame() {
    return Row(children: <Widget>[
      IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.audiotrack,
            color: Colors.black,
          ),
          onPressed: () {
            AudioManager.instance.setVolume(0);
          }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Slider(
                value: _sliderVolume,
                onChanged: (value) {
                  setState(() {
                    _sliderVolume = value;
                    AudioManager.instance.setVolume(value, showVolume: true);
                  });
                },
              )))
    ]);
  }
}
