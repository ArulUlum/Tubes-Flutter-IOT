import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isRecording = false;
  bool _isPeace = false;
  bool _isNoisy = false;
  bool _isRiot = false;

  StreamSubscription<NoiseReading> _noiseSubscription;

  NoiseMeter _noiseMeter;
  double dbNow;

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (exception) {
      print(exception);
    }
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });

    /// Do someting with the noiseReading object
    print(noiseReading.toString());
    setState(() {
      dbNow = noiseReading.meanDecibel;
      // peace = < 65
      // noisy = 65.01 - 80
      // riot =  > 80
      if (dbNow > 80) {
        _isRiot = true;
        _isNoisy = false;
        _isPeace = false;
      } else if (dbNow <= 80 && dbNow > 65) {
        _isNoisy = true;
        _isPeace = false;
        _isRiot = false;
      } else {
        _isPeace = true;
        _isNoisy = false;
        _isRiot = false;
      }
    });
  }

  void onError(e) {
    print(e.toString());
    _isRecording = false;
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
        _isPeace = false;
        _isNoisy = false;
        _isRiot = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _noiseMeter = new NoiseMeter(onError);
  }

  List<Widget> getContent() => <Widget>[
        Container(
          margin: EdgeInsets.all(25),
          child: Column(
            children: [
              Container(
                child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
                    style: TextStyle(fontSize: 25, color: Colors.blue)),
                margin: EdgeInsets.only(top: 20),
              ),
              Center(
                child: Text(dbNow.toString()),
              ),
            ],
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 95,
              color: Color(0xFFC4C4C4),
              child: Center(
                child: Text(
                  'Define Your Peace',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NoiseTile(
                    title: "Peace",
                    activeColor: Color(0xFF0085FF),
                    isActive: _isPeace,
                  ),
                  SizedBox(height: 24),
                  NoiseTile(
                    title: "Noisy",
                    activeColor: Color(0xFFFF9900),
                    isActive: _isNoisy,
                  ),
                  SizedBox(height: 24),
                  NoiseTile(
                    title: "Riot",
                    activeColor: Color(0xFFFF0000),
                    isActive: _isRiot,
                  ),
                  SizedBox(height: 48),
                  GestureDetector(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                        color: (_isRecording)
                            ? Color(0xFF585858)
                            : Color(0xFFC4C4C4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          (_isRecording) ? "STOP" : "TEST",
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    onTap: _isRecording ? stop : start,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //         child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: getContent())),
  //     floatingActionButton: FloatingActionButton(
  //         backgroundColor: _isRecording ? Colors.red : Colors.green,
  //         onPressed: _isRecording ? stop : start,
  //         child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
  //   );
  // }
}

class NoiseTile extends StatelessWidget {
  final String title;
  final Color activeColor;
  final bool isActive;

  NoiseTile({
    this.activeColor,
    this.isActive,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        color: (isActive) ? activeColor : Color(0xFFC4C4C4),
        borderRadius: BorderRadius.circular(90),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 36),
        ),
      ),
    );
  }
}
