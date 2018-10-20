import 'package:flutter/material.dart';
import 'pages/main_page.dart';

import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'globals.dart' as globals;

import 'dart:math';


void main() async{

  DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();

  if (Platform.isIOS) {
    globals.osInfo = await deviceInfo.iosInfo;
    globals.osModel = globals.osInfo.utsname.machine;
    print('Running on me ${globals.osInfo.utsname.machine}');  // e.g. "iPod7,1"
  } else if (Platform.isAndroid) {
    globals.osInfo = await deviceInfo.androidInfo;
    globals.osModel = globals.osInfo.model;
    print('Running on me ${globals.osInfo.model}');  // e.g. "Moto G (4)"
  } else {
  }

  runApp(MyApp());

}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp
    (
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primarySwatch: Colors.purple),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double _miles = 0.0;

  @override initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = _controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return new Scaffold(
      body: new Material(
        color: const Color.fromRGBO(246, 251, 8, 1.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget child) {
                  return new Text(
                    _animation.value.toStringAsFixed(1),
                    style: textTheme.display4.copyWith(fontStyle: FontStyle.italic),
                  );
                },
              ),
              new Text(
                "MILES",
                style: textTheme.display1.copyWith(fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.directions_run),
          onPressed: () {
            Random rng = new Random();
            setState(() {
              _miles += rng.nextInt(20) + 0.3;
              _animation = new Tween<double>(
                begin: _animation.value,
                end: _miles,
              ).animate(new CurvedAnimation(
                curve: Curves.fastOutSlowIn,
                parent: _controller,
              ));
            });
            _controller.forward(from: 0.0);
          }
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}