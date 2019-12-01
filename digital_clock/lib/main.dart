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
        fontFamily: 'NovaMono'
      ),
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
    final String _format = widget.model.is24HourFormat ? 'kk mm' : 'hh mm';
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              DateFormat(_format).format(_now),
              style: Theme.of(context).textTheme.display4,
            ),
          ],
        ),
      ),
    );
  }
}
