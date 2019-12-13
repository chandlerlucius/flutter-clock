import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

void main() => runApp(ClockCustomizer((ClockModel model) => MyHomePage(model)));

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.model);

  final ClockModel model;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _now = DateTime.now();
  static final Random _randomGenerator = new Random();
  static final HashSet<int> _intSet = new HashSet();
  static final int _maxFiles = 8;
  static int _randomNumber = _randomGenerator.nextInt(_maxFiles);
  int _previousRandomNumber = _randomNumber;

  void _updateNow() {
    setState(() {
      _now = DateTime.now();
    });
  }

  void _changeBackground() {
    setState(() {
      _previousRandomNumber = _randomNumber;
      _intSet.add(_randomNumber);
      if (_intSet.length == _maxFiles) {
        _intSet.clear();
        _intSet.add(_randomNumber);
      }
      while (_intSet.contains(_randomNumber)) {
        _randomNumber = _randomGenerator.nextInt(_maxFiles);
      }
    });
  }

  void _startTimer() {
    _updateNow();
    _changeBackground();
    Timer.periodic(Duration(milliseconds: 60000), (Timer t) {
      _updateNow();
      _changeBackground();
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 60000 - DateTime.now().second * 1000),
        _startTimer);
  }

  @override
  Widget build(BuildContext context) {
    final String _location = widget.model.location;
    final String _format = widget.model.is24HourFormat ? 'HHmm' : 'hhmm';
    final String _time = DateFormat(_format).format(_now);
    final String _date = DateFormat('EEE, MMM dd').format(_now);
    final String _temp =
        widget.model.temperature.round().toString() + widget.model.unitString;

    final ThemeData _themeData = Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'NovaMono'));
    TextStyle _timeTextStyle = _themeData.textTheme.display4
        .copyWith(fontSize: MediaQuery.of(context).size.height / 2, height: 1);

    final Brightness _brightness = Theme.of(context).brightness;
    String _backgroundPrefix;
    if (_brightness == Brightness.light) {
      _backgroundPrefix = "light-";
      _timeTextStyle = _timeTextStyle.copyWith(color: Color(0xBB000000));
    } else {
      _backgroundPrefix = "dark-";
      _timeTextStyle = _timeTextStyle.copyWith(color: Color(0xBBFFFFFF));
    }
    final String _backgroundImage =
        _backgroundPrefix + _randomNumber.toString() + ".jpg";

    final String _backgroundImagePrevious =
        _backgroundPrefix + _previousRandomNumber.toString() + ".jpg";

    final bool _evenPass = _intSet.length % 2 == 0;
    String _firstChild = "images/background/" + _backgroundImagePrevious;
    String _secondChild = "images/background/" + _backgroundImage;
    if (_intSet.length != 0 && _evenPass && _intSet.length != _maxFiles - 1) {
      _firstChild = "images/background/" + _backgroundImage;
      _secondChild = "images/background/" + _backgroundImagePrevious;
    }

    final Stack _clockForeground = Stack(
      children: <Widget>[
        AnimatedCrossFade(
          crossFadeState:
              _evenPass ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(seconds: 3),
          firstChild: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image(
              image: AssetImage(_firstChild),
              fit: BoxFit.cover,
            ),
          ),
          secondChild: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image(
              image: AssetImage(_secondChild),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height / 6,
            left: 0,
            child: Text(
              _time.substring(0, 1),
              style: _timeTextStyle,
            )),
        Positioned(
            top: MediaQuery.of(context).size.height / 20,
            left: MediaQuery.of(context).size.width / 6,
            child: Text(
              _time.substring(1, 2),
              style: _timeTextStyle,
            )),
        Positioned(
            bottom: -MediaQuery.of(context).size.height / 20,
            left: MediaQuery.of(context).size.width / 4,
            child: Text(
              _time.substring(2, 3),
              style: _timeTextStyle,
            )),
        Positioned(
            bottom: MediaQuery.of(context).size.height / 15,
            left: MediaQuery.of(context).size.width / 4 +
                MediaQuery.of(context).size.width / 6,
            child: Text(
              _time.substring(3, 4),
              style: _timeTextStyle,
            )),
        Align(
            alignment: Alignment.topRight,
            child: Text(
              _date,
              style: _themeData.textTheme.display2,
            )),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
                width: MediaQuery.of(context).size.width / 3,
                child: Text(
                  _location,
                  maxLines: 3,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: _themeData.textTheme.display1,
                ))),
        Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _temp,
              style: _themeData.textTheme.display2,
            )),
      ],
    );

    return Scaffold(body: _clockForeground);
  }
}
