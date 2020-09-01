import 'dart:async';
import 'dart:convert';
import 'package:flutter_image/network.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class Home extends StatelessWidget {
  final FirebaseUser user;

  const Home({Key key, @required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
      ),
      body: Results(),
    );
  }
}

class Results extends StatefulWidget {
  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  LocationData currentLocation;
  StreamSubscription<LocationData> locationSubscription;
  Location location = new Location();
  String longtitude, latitude;
  var currentData;
  Map dailyData = new Map();
  List dataWeekly = [];

  snackbar(txt) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline),
          Text(txt),
          SizedBox(width: 30),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    locationSubscription = location.onLocationChanged.listen((result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  void initPlatformState() async {
    LocationData newLocation;
    try {
      newLocation = await location.getLocation();
    } on PlatformException catch (e) {
      Scaffold.of(context).showSnackBar((snackbar(e.message)));
    }
    setState(() {
      if (newLocation != null) {
        currentLocation = newLocation;
        locationSubscription.cancel();
      } else {
        initPlatformState();
        /* DateTime now = new DateTime.now();
        var date = new DateTime(now.month, now.day);
        String day = date.day.toString();
        String month = date.month.toString(); */
      }
    });
  }

/*   Future<Map> getDailyData(http.Client client) async {
    latitude = currentLocation.latitude.toString();
    longtitude = currentLocation.longitude.toString();
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longtitude&appid=3553bf2bbbd9d1f3c4fa66d28e79846b';
    http.Response response = await client.get(url);
    return parseDailyData(response.body);
  }

  Map parseDailyData(responseBody) {
    Map gotData = json.decode(responseBody);
    dailyData['weather'] = gotData['weather'][0]['description'];
    dailyData['temp'] = gotData['main']['temp'] - 273.15;
    dailyData['main_weather'] = gotData['weather'][0]['main'];
    return dailyData;
  } */

  Future<List> getWeeklyData(http.Client client) async {
    latitude = currentLocation.latitude.toString();
    longtitude = currentLocation.longitude.toString();
    String url =
        'https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longtitude&appid=3553bf2bbbd9d1f3c4fa66d28e79846b';
    http.Response response = await client.get(url);
    return parseWeeklyData(response.body);
  }

  List parseWeeklyData(responseBody) {
    Map gotData = json.decode(responseBody);
    gotData['daily'].forEach((harita) => {
          dataWeekly.add({
            'weather': harita['weather'][0]['description'],
            'temp': harita['temp']['day'] - 273.15,
            'main_weather': harita['weather'][0]['main']
          })
        });
    return dataWeekly;
  }

  Widget result(AsyncSnapshot snapshot) {
    return ListView(children: [
      Card(
        child: Image(
          image: NetworkImageWithRetry(
              'https://tile.openweathermap.org/map/precipitation_new/1/1/0.png?APPID=3553bf2bbbd9d1f3c4fa66d28e79846b'),
        ),
      ),
/*       Card(
        child: ListTile(
          leading: Icon(Icons.cloud),
          title: Text(snapshot.data['main_weather']),
          subtitle: Text(
              '${snapshot.data['weather']} \n${snapshot.data['temp'].toStringAsFixed(2)} Degrees'),
        ),
      ), */
      for (var data in dataWeekly)
        Card(
          child: ListTile(
            leading: Icon(Icons.cloud),
            title: Text(data['main_weather']),
            subtitle: Text(
                '${data['weather']} \n${data['temp'].toStringAsFixed(2)} Degrees'),
          ),
        ),
    ]);
  }

  Widget loading() {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Center(
        child: SpinKitFadingCube(
          color: Theme.of(context).primaryColor,
          size: 100.0,
        ),
      ),
    );
  }

  Widget weeklyData() {
    //var weekly = getWeeklyData(http.Client());
    return FutureBuilder(
      future: getWeeklyData(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return result(snapshot);
        } else {
          return loading();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: weeklyData(),
    );
  }
}
