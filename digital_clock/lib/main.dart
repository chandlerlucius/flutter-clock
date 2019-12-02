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
          primarySwatch: Colors.blue,
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    final TextStyle _numberStyle = TextStyle(
      color: Colors.black,
    );

    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Positioned(
                top: MediaQuery.of(context).size.height / 4,
                left: 0,
                child: Text(
                  _time.substring(0, 1),
                  style: Theme.of(context).textTheme.display4,
                )),
            Positioned(
                top: 0,
                left: MediaQuery.of(context).size.height / 4,
                child: Text(
                  _time.substring(1, 2),
                  style: Theme.of(context).textTheme.display4,
                )),
            Positioned(
                bottom: 0,
                left: MediaQuery.of(context).size.height / 2.5,
                child: Text(
                  _time.substring(2, 3),
                  style: Theme.of(context).textTheme.display4,
                )),
            Positioned(
                top: MediaQuery.of(context).size.height / 4,
                left: MediaQuery.of(context).size.height / 1.5,
                child: Text(
                  _time.substring(3, 4),
                  style: Theme.of(context).textTheme.display4,
                )),
          ],
        ),
      ),
    );
  }
}
