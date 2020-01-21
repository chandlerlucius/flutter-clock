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
  Animation<double> _horizontalPainterXAnimation;
  AnimationController _horizontalPainterController;
  Animation<double> _verticalPainterAnimation;
  AnimationController _verticalPainterController;
  double _xValue = 0;
  double _yValue = 0;
  final Paint _paint = new Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 15
    ..isAntiAlias = true;

  static final Random _randomGenerator = new Random();
  static final HashSet<int> _intSet = new HashSet();
  static final int _maxFiles = 10;
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
        duration: Duration(milliseconds: 15000), vsync: this);
    _verticalPainterController = AnimationController(
        duration: Duration(milliseconds: 15000), vsync: this);

    _horizontalPainterController.forward();
    _verticalPainterController.forward();

    _horizontalPainterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer(Duration(milliseconds: 15000), () {
          _horizontalPainterController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Timer(Duration(milliseconds: 15000), () {
          _horizontalPainterController.forward();
        });
      }
    });

    _verticalPainterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer(Duration(milliseconds: 15000), () {
          _verticalPainterController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        Timer(Duration(milliseconds: 15000), () {
          _verticalPainterController.forward();
        });
      }
    });
  }

  void _startTimer() {
    _updateNow();
    _changeBackground();
    _startAnimation();
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
    //Handle paint animations first
    final Size size = MediaQuery.of(context).size;
    final double _horizontalPainterXStart = 0;
    final double _horizontalPainterXEnd = size.width - 30;
    final double _verticalPainterYStart = 0;
    final double _verticalPainterYEnd = size.height - 30;

    if (_horizontalPainterController != null) {
      _horizontalPainterXAnimation =
          Tween(begin: _horizontalPainterXStart, end: _horizontalPainterXEnd)
              .animate(_horizontalPainterController)
                ..addListener(() {
                  setState(() {
                    _xValue = _horizontalPainterXAnimation.value;
                  });
                });
    }

    if (_verticalPainterController != null) {
      _verticalPainterAnimation =
          Tween(begin: _verticalPainterYStart, end: _verticalPainterYEnd)
              .animate(_verticalPainterController)
                ..addListener(() {
                  setState(() {
                    _yValue = _verticalPainterAnimation.value;
                  });
                });
    }

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
      _paint.color = Color(0xDD000000);
    } else {
      _backgroundPrefix = "dark-";
      _timeTextStyle = _timeTextStyle.copyWith(color: Color(0xBBFFFFFF));
      _paint.color = Color(0xDDFFFFFF);
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
          left: 5,
          child: Text(
            _time.substring(0, 1),
            style: _timeTextStyle,
          ),
        ),
        Positioned(
          top: size.height / 20,
          left: size.width / 6,
          child: Text(
            _time.substring(1, 2),
            style: _timeTextStyle,
          ),
        ),
        Positioned(
          bottom: -size.height / 20,
          left: size.width / 4,
          child: Text(
            _time.substring(2, 3),
            style: _timeTextStyle,
          ),
        ),
        Positioned(
          bottom: size.height / 15,
          left: size.width / 4 + size.width / 6,
          child: Text(
            _time.substring(3, 4),
            style: _timeTextStyle,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Text(
              _date,
              style: _themeData.textTheme.display2,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            width: size.width / 3,
            child: Text(
              _location,
              maxLines: 3,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: _themeData.textTheme.display1,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 5),
            child: Text(
              _temp,
              style: _themeData.textTheme.display2,
            ),
          ),
        ),
        CustomPaint(
          size: Size(size.width, size.height),
          painter: HorizontalPainter(_paint, _horizontalPainterXStart, _xValue),
        ),
        CustomPaint(
          size: Size(size.width, size.height),
          painter: VerticalPainter(_paint, _verticalPainterYStart, _yValue),
        ),
      ],
    );

    return Scaffold(body: _clockForeground);
  }

  @override
  void dispose() {
    _horizontalPainterController.dispose();
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
    canvas.drawLine(
        Offset(7.5, size.height), Offset(7.5, size.height - _yValue), _paint);
    canvas.drawLine(Offset(size.width - 7.5, _yStart),
        Offset(size.width - 7.5, _yValue), _paint);
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
    canvas.drawLine(Offset(_xStart, 7.5), Offset(_xValue, 7.5), _paint);
    canvas.drawLine(Offset(size.width, size.height - 7.5),
        Offset(size.width - _xValue, size.height - 7.5), _paint);
  }

  @override
  bool shouldRepaint(HorizontalPainter oldDelegate) {
    return true;
  }
}
