import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:battery/battery.dart';

import 'shop_items_page.dart';
import '../globals.dart' as globals;
import 'package:charts_flutter/flutter.dart' as charts;

import 'dart:async';

import 'dart:math';
import 'package:sensors/sensors.dart';

class MainPage extends StatefulWidget
{
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
{
  AnimationController _controller;
  Animation<double> _animation;
  double _miles = 0.0;

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  final Battery _battery = Battery();

  BatteryState _batteryState;
  int _batteryLevel;

  final List<List<double>> charts =
  [
    [0.0, 0.3, 0.7, 0.6, 0.55, 0.8, 1.2, 1.3, 1.35, 0.9, 1.5, 1.7, 1.8, 1.7, 1.2, 0.8, 1.9, 2.0, 2.2, 1.9, 2.2, 2.1, 2.0, 2.3, 2.4, 2.45, 2.6, 3.6, 2.6, 2.7, 2.9, 2.8, 3.4],
    [0.0, 0.3, 0.7, 0.6, 0.55, 0.8, 1.2, 1.3, 1.35, 0.9, 1.5, 1.7, 1.8, 1.7, 1.2, 0.8, 1.9, 2.0, 2.2, 1.9, 2.2, 2.1, 2.0, 2.3, 2.4, 2.45, 2.6, 3.6, 2.6, 2.7, 2.9, 2.8, 3.4, 0.0, 0.3, 0.7, 0.6, 0.55, 0.8, 1.2, 1.3, 1.35, 0.9, 1.5, 1.7, 1.8, 1.7, 1.2, 0.8, 1.9, 2.0, 2.2, 1.9, 2.2, 2.1, 2.0, 2.3, 2.4, 2.45, 2.6, 3.6, 2.6, 2.7, 2.9, 2.8, 3.4,],
    [0.0, 0.3, 0.7, 0.6, 0.55, 0.8, 1.2, 1.3, 1.35, 0.9, 1.5, 1.7, 1.8, 1.7, 1.2, 0.8, 1.9, 2.0, 2.2, 1.9, 2.2, 2.1, 2.0, 2.3, 2.4, 2.45, 2.6, 3.6, 2.6, 2.7, 2.9, 2.8, 3.4, 0.0, 0.3, 0.7, 0.6, 0.55, 0.8, 1.2, 1.3, 1.35, 0.9, 1.5, 1.7, 1.8, 1.7, 1.2, 0.8, 1.9, 2.0, 2.2, 1.9, 2.2, 2.1, 2.0, 2.3, 2.4, 2.45, 2.6, 3.6, 2.6, 2.7, 2.9, 2.8, 3.4, 0.0, 0.3, 0.7, 0.6, 0.55, 0.8, 1.2, 1.3, 1.35, 0.9, 1.5, 1.7, 1.8, 1.7, 1.2, 0.8, 1.9, 2.0, 2.2, 1.9, 2.2, 2.1, 2.0, 2.3, 2.4, 2.45, 2.6, 3.6, 2.6, 2.7, 2.9, 2.8, 3.4]
  ];

  static final List<String> chartDropdownItems = [ 'Last 7 days', 'Last month', 'Last year' ];
  String actualDropdown = chartDropdownItems[0];
  int actualChart = 0;

  static const timeout = const Duration(seconds: 1);
  static const ms = const Duration(milliseconds: 1);
  double co2counter = 0.00014;

  startTimeout([int milliseconds]) {
    var duration = Duration(milliseconds: 1);//milliseconds == null ? timeout : ms * milliseconds;
    return new Timer(duration, handleTimeout);
  }

  void handleTimeout() {  // callback function
    this.co2counter = co2counter + 0.00014;
    startTimeout();
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    _battery.batteryLevel.then((level) {
      this.setState(() {
        _batteryLevel = level;
      });
    });

    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _battery.batteryLevel.then((level) {
        this.setState(() {
          _batteryLevel = level;
          _batteryState = state;
        });
      });
    });

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));

    startTimeout();

  }

  @override
  Widget build(BuildContext context)
  {
    final List<String> accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold
    (
      appBar: AppBar
      (
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text('My Footprint', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0)),
        actions: <Widget>
        [
          Container
          (
            margin: EdgeInsets.only(right: 8.0),
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>
//              [
//                Text('beclothed.com', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 14.0)),
//                Icon(Icons.arrow_drop_down, color: Colors.black54)
//              ],
            ),
          )
        ],
      ),
      body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          _buildTile( // Header summary
            Padding
            (
              padding: const EdgeInsets.all(0.0),
              child:
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                                Center(child:Text(co2counter.toStringAsFixed(5) + '', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 34.0))),
                                Center(child:Text('Your estimated CO2 pollution contribution', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 11.0))),
                                Center(child:Text('to worldwide average in grams', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 11.0))),
                    ]
                        ,
              ),
            ),
          ),
          _buildTile( // Power Consumption
            Padding
              (
              padding: const EdgeInsets.all(24.0),
              child: Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>
                  [
                    Column
                      (
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>
                      [
                        //CustomPaint(
                        //  painter: _BatteryLevelPainter(_batteryLevel, _batteryState),
                        //  child: _batteryState == BatteryState.charging ? Icon(Icons.flash_on) : Container(),
                        //),
                        Text('Electricity Consumption', style: TextStyle(color: Colors.blueAccent)),
                        Text(_batteryState == BatteryState.charging ? 'Charging' : 'On Battery', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 34.0)),
                        Text('Charge with renewable energy sources', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 11.0)),
                      ],
                    ),
                    Material
                      (
                        color: _batteryState == BatteryState.charging ? Colors.redAccent : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(24.0),
                        child: Center
                          (
                            child: Padding
                              (
                              padding: const EdgeInsets.all(16.0),
                              child: _batteryState == BatteryState.charging ? Icon(Icons.flash_on, color: Colors.white, size: 30.0) : Icon(Icons.battery_alert, color: Colors.white, size: 30.0)
                            )
                        )
                    )
                  ]
              ),
            ),
          ),
          _buildTile( //Fuel Consumption
            Padding
              (
              padding: const EdgeInsets.all(24.0),
              child: Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>
                  [
                    Column
                      (
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>
                      [
                        Text('Transportation', style: TextStyle(color: Colors.blueAccent)),
                        Text('In a vehicle', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 34.0)),
                        Text('Please consider more effecient', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 11.0)),
                        Text('transportation', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 11.0)),
                      ],
                    ),
                    Material
                      (
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(24.0),
                        child: Center
                          (
                            child: Padding
                              (
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.local_gas_station, color: Colors.white, size: 30.0),
                            )
                        )
                    )
                  ]
              ),
            ),
          ),
          _buildTile(
            Padding
                (
                  padding: const EdgeInsets.all(24.0),
                  child: Column
                  (
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                    [
                      Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>
                        [
                          Column
                          (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('History', style: TextStyle(color: Colors.blue)),
                              //Text('\$16K', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 34.0)),
                            ],
                          ),
                          DropdownButton
                          (
                            isDense: true,
                            value: actualDropdown,
                            onChanged: (String value) => setState(()
                            {
                              actualDropdown = value;
                              actualChart = chartDropdownItems.indexOf(value); // Refresh the chart
                            }),
                            items: chartDropdownItems.map((String title)
                            {
                              return DropdownMenuItem
                              (
                                value: title,
                                child: Text(title, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 14.0)),
                              );
                            }).toList()
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 4.0)),
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: MediaQuery.of(context).size.width * 0.5,
                        child: StackedBarChart.withSampleData(),
                      ),
                      //Sparkline
                      //(
                        //data: charts[actualChart],
                        //lineWidth: 5.0,
                        //lineColor: Colors.greenAccent,
                      //)
                    ],
                  )
                ),
          ),
        ],
        staggeredTiles: [
          StaggeredTile.extent(2, 150.0),
          StaggeredTile.extent(2, 140.0),
          StaggeredTile.extent(2, 140.0),
          StaggeredTile.extent(2, 292.0),
        ],
      )
    );
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
      elevation: 14.0,
      borderRadius: BorderRadius.circular(12.0),
      shadowColor: Color(0x802196F3),
      child: InkWell
      (
        // Do onTap() if it isn't null, otherwise do print()
        onTap: onTap != null ? () => onTap() : () { print('Not set yet'); },
        child: child
      )
    );
  }
}

class _BatteryLevelPainter extends CustomPainter {
  final int _batteryLevel;
  final BatteryState _batteryState;

  _BatteryLevelPainter(this._batteryLevel, this._batteryState);

  @override
  void paint(Canvas canvas, Size size) {
    Paint getPaint({Color color = Colors.black, PaintingStyle style = PaintingStyle.stroke}) {
      return Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = style;
    }

    final double batteryRight = size.width - 4.0;

    final RRect batteryOutline = RRect.fromLTRBR(0.0, 0.0, batteryRight, size.height, Radius.circular(3.0));

    // Battery body
    canvas.drawRRect(
      batteryOutline,
      getPaint(),
    );

    // Battery nub
    canvas.drawRect(
      Rect.fromLTWH(batteryRight, (size.height / 2.0) - 5.0, 4.0, 10.0),
      getPaint(style: PaintingStyle.fill),
    );

    // Fill rect
    canvas.clipRect(Rect.fromLTWH(0.0, 0.0, batteryRight * _batteryLevel / 100.0, size.height));

    Color indicatorColor;
    if (_batteryLevel < 15) {
      indicatorColor = Colors.red;
    } else if (_batteryLevel < 30) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    canvas.drawRRect(
        RRect.fromLTRBR(0.5, 0.5, batteryRight - 0.5, size.height - 0.5, Radius.circular(3.0)),
        getPaint(style: PaintingStyle.fill, color: indicatorColor)
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final _BatteryLevelPainter old = oldDelegate as _BatteryLevelPainter;
    return old._batteryLevel != _batteryLevel || old._batteryState != _batteryState;
  }
}

class DonutAutoLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutAutoLabelChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutAutoLabelChart.withSampleData() {
    return new DonutAutoLabelChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 25,
        arcRendererDecorators: [
          new charts.ArcLabelDecorator(),
        ],
      ),
      animationDuration: Duration(seconds: 1),
    );
  }

  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      new LinearSales(
          0,
          double.parse('15.0'),
          Color.fromRGBO(238, 56, 58, 1.0)),
      new LinearSales(
          1,
          double.parse('15.0'),
          Color.fromRGBO(248, 152, 56, 1.0)),
      new LinearSales(
          2,
          double.parse('15.0'),
          Color.fromRGBO(76, 175, 80, 1.0)),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.home,
        measureFn: (LinearSales sales, _) => sales.away,
        colorFn: (LinearSales sales, _) => sales.color,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearSales row, _) => '${row.away}' + '%',
      )
    ];
  }
}

class LinearSales {
  final int home;
  final double away;
  final charts.Color color;

  LinearSales(this.home, this.away, Color color)
      : this.color = new charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class StackedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedBarChart(this.seriesList, {this.animate});

  /// Creates a stacked [BarChart] with sample data and no transition.
  factory StackedBarChart.withSampleData() {
    return new StackedBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.stacked,
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [

      new OrdinalSales('Sun', 5),
      new OrdinalSales('Mon', 25),
      new OrdinalSales('Tue', 100),
      new OrdinalSales('Wed', 75),
      new OrdinalSales('Thu', 25),
      new OrdinalSales('Fri', 100),
      new OrdinalSales('Sat', 75),
    ];
    final mobileSalesData = [
      new OrdinalSales('Sun', 10),
      new OrdinalSales('Mon', 15),
      new OrdinalSales('Tue', 50),
      new OrdinalSales('Wed', 45),
      new OrdinalSales('Thu', 25),
      new OrdinalSales('Fri', 100),
      new OrdinalSales('Sat', 75),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Mobile',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: mobileSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}