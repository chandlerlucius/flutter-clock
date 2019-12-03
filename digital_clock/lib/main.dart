import 'dart:async';

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

  void updateNow() {
    setState(() {
      _now = DateTime.now();
    });
  }

  void startTimer() {
    updateNow();
    Timer.periodic(Duration(seconds: 60), (Timer t) {
      updateNow();
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 60 - DateTime.now().second), startTimer);
  }

  @override
  Widget build(BuildContext context) {
    final String _format = widget.model.is24HourFormat ? 'HHmm' : 'hhmm';
    final String _time = DateFormat(_format).format(_now);
    final String _date = DateFormat('EEE, MMM dd').format(_now);
    final String _temp =
        widget.model.temperature.round().toString() + widget.model.unitString;
    final String _location = widget.model.location;

    final Brightness _brightness = Theme.of(context).brightness;
    String _background;
    if (_brightness == Brightness.light) {
      _background = "background_light_1.jpg";
    } else {
      _background = "background_dark_1.jpg";
    }

    final ThemeData _themeData = Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'NovaMono'));
    final TextStyle _timeTextStyle = _themeData.textTheme.display4
        .copyWith(fontSize: MediaQuery.of(context).size.height / 2, height: 1);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/" + _background),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
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
        ),
      ),
    );
  }
}
