import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

void main() => runApp(ClockCustomizer((ClockModel model) => MyApp(model)));

class MyApp extends StatelessWidget {
  const MyApp(this.model);

  final ClockModel model;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Digital Clock',
      theme: ThemeData(
          fontFamily: 'NovaMono',
          textTheme: TextTheme(
              display4: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 2,
                  height: 1))),
      home: MyHomePage(model: model),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.model}) : super(key: key);

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

    final Brightness _brightness = Theme.of(context).brightness;
    String _background;
    if(_brightness == Brightness.light) {
      _background = "background_light_1.jpg";
    } else {
      _background = "background_dark_1.jpg";
    }

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
                  style: Theme.of(context).textTheme.display4,
                )),
            Positioned(
                top: MediaQuery.of(context).size.height / 20,
                left: MediaQuery.of(context).size.width / 6,
                child: Text(
                  _time.substring(1, 2),
                  style: Theme.of(context).textTheme.display4,
                )),
            Positioned(
                bottom: -MediaQuery.of(context).size.height / 20,
                left: MediaQuery.of(context).size.width / 4,
                child: Text(
                  _time.substring(2, 3),
                  style: Theme.of(context).textTheme.display4,
                )),
            Positioned(
                bottom: MediaQuery.of(context).size.height / 15,
                left: MediaQuery.of(context).size.width / 4 +
                    MediaQuery.of(context).size.width / 6,
                child: Text(
                  _time.substring(3, 4),
                  style: Theme.of(context).textTheme.display4,
                )),
            Align(
                alignment: Alignment.topRight,
                child: Text(
                  _date,
                  style: Theme.of(context).textTheme.display2,
                )),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Good \nAfternoon",
                  style: Theme.of(context).textTheme.display1,
                )),
            Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _temp,
                  style: Theme.of(context).textTheme.display2,
                )),
          ],
        ),
      ),
    );
  }
}
