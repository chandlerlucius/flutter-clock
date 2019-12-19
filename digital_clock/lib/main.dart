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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Animation<double> _horizontalPainterAnimation;
  AnimationController _horizontalPainterController;
  Animation<double> _verticalPainterAnimation;
  AnimationController _verticalPainterController;
  double _yValue = 0.0;
  double _xValue = 0.0;
  static const double _strokeWidth = 15;
  final Paint _paint = new Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..isAntiAlias = true;

  static final Random _randomGenerator = new Random();
  static final HashSet<int> _intSet = new HashSet();
  static final int _maxFiles = 8;
  static int _randomNumber = _randomGenerator.nextInt(_maxFiles);
  int _previousRandomNumber = _randomNumber;
  DateTime _now = DateTime.now();

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

  void _startAnimation() {
    _horizontalPainterController = AnimationController(
        duration: Duration(milliseconds: 7500), vsync: this);
    _verticalPainterController = AnimationController(
        duration: Duration(milliseconds: 15000), vsync: this);

    _horizontalPainterController.forward();
    Timer(Duration(milliseconds: 7500), () {
      _verticalPainterController.forward();
    });

    _horizontalPainterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _horizontalPainterController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _horizontalPainterController.forward();
      }
    });

    _verticalPainterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _verticalPainterController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _verticalPainterController.forward();
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
    _startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    //Handle paint animations first
    final Size size = MediaQuery.of(context).size;
    final double _strokeWidth = 15;
    final double _horizontalPainterXStart =
        (size.width / 2.25 - size.width / 6) / 2 -
            _strokeWidth / 2 +
            size.width / 6;
    final double _horizontalPainterXEnd =
        size.width / 2.25 - (_strokeWidth / 2);
    final double _verticalPainterYStart = size.height / 2 - _strokeWidth;
    final double _verticalPainterYEnd = size.height - (1.5 * _strokeWidth);

    _horizontalPainterAnimation =
        Tween(begin: _horizontalPainterXStart, end: _horizontalPainterXEnd)
            .animate(_horizontalPainterController)
              ..addListener(() {
                setState(() {
                  _paint.color = Color(0xDD000000);
                  _xValue = _horizontalPainterAnimation.value;
                });
              });
    _verticalPainterAnimation =
        Tween(begin: _verticalPainterYStart, end: _verticalPainterYEnd)
            .animate(_verticalPainterController)
              ..addListener(() {
                setState(() {
                  _paint.color = Color(0xDD000000);
                  _yValue = _verticalPainterAnimation.value;
                });
              });

    final String _location = widget.model.location;
    final String _format = widget.model.is24HourFormat ? 'HHmm' : 'hhmm';
    final String _time = DateFormat(_format).format(_now);
    final String _date = DateFormat('EEE, MMM dd').format(_now);
    final String _temp =
        widget.model.temperature.round().toString() + widget.model.unitString;

    final ThemeData _themeData = Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'NovaMono'));
    TextStyle _timeTextStyle = _themeData.textTheme.display4
        .copyWith(fontSize: size.height / 2, height: 1);

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
            width: size.width,
            height: size.height,
            child: Image(
              image: AssetImage(_firstChild),
              fit: BoxFit.cover,
            ),
          ),
          secondChild: Container(
            width: size.width,
            height: size.height,
            child: Image(
              image: AssetImage(_secondChild),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            top: size.height / 6,
            left: 0,
            child: Text(
              _time.substring(0, 1),
              style: _timeTextStyle,
            )),
        Positioned(
            top: size.height / 20,
            left: size.width / 6,
            child: Text(
              _time.substring(1, 2),
              style: _timeTextStyle,
            )),
        Positioned(
            bottom: -size.height / 20,
            left: size.width / 4,
            child: Text(
              _time.substring(2, 3),
              style: _timeTextStyle,
            )),
        Positioned(
            bottom: size.height / 15,
            left: size.width / 4 + size.width / 6,
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
                width: size.width / 3,
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
        CustomPaint(
          size: Size(size.width, size.height),
          painter: VerticalPainter(_paint, _verticalPainterYStart, _yValue),
        ),
        CustomPaint(
          size: Size(size.width, size.height),
          painter: HorizontalPainter(_paint, _horizontalPainterXStart, _xValue),
        ),
      ],
    );

    return Scaffold(body: _clockForeground);
  }

  @override
  void dispose() {
    _verticalPainterController.dispose();
    super.dispose();
  }
}

class VerticalPainter extends CustomPainter {
  final double _yValue;
  final double _yStart;
  final Paint _paint;

  VerticalPainter(this._paint, this._yStart, this._yValue);

  @override
  void paint(Canvas canvas, Size size) {
    double _xValue = size.width / 2.25;

    canvas.drawLine(Offset(_xValue, _yStart + 7.5), Offset(_xValue, _yValue), _paint);
    // canvas.drawLine(Offset(_xValue, _yStart),
    //     Offset(_xValue, 2 * _yStart - _yValue), _paint);

    _xValue = size.width / 6 + 7.5;

    // canvas.drawLine(Offset(_xValue, _yStart), Offset(_xValue, _yValue), _paint);
    canvas.drawLine(Offset(_xValue, _yStart),
        Offset(_xValue, 2 * _yStart - _yValue), _paint);
  }

  @override
  bool shouldRepaint(VerticalPainter oldDelegate) {
    return true;
  }
}

class HorizontalPainter extends CustomPainter {
  final double _xValue;
  final double _xStart;
  final Paint _paint;

  HorizontalPainter(this._paint, this._xStart, this._xValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double _yValue = size.height / 2;

    canvas.drawLine(Offset(_xStart, _yValue), Offset(_xValue, _yValue), _paint);
    canvas.drawLine(Offset(_xStart, _yValue),
        Offset(2 * _xStart - _xValue, _yValue), _paint);
  }

  @override
  bool shouldRepaint(HorizontalPainter oldDelegate) {
    return true;
  }
}
