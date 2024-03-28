import 'package:flutter/material.dart';
import 'package:starmap/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

final TextEditingController _cityController = TextEditingController();

class _WeatherState extends State<Weather> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather For The Day!'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Enter City Name',
                      ),
                    ),
                  ],
                ),
              )),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentcolor1,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GetWeatherData()),
                  );
                },
                child: const Text('Get Today\'s Weather'),
              ),
            ],
          ),
        ));
  }
}

class GetWeatherData extends StatefulWidget {
  const GetWeatherData({Key? key}) : super(key: key);

  @override
  State<GetWeatherData> createState() => _GetWeatherDataState();
}

class _GetWeatherDataState extends State<GetWeatherData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather For The Day!'),
      ),
      body: FutureBuilder<WeatherJson>(
        future: fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/homebg.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Text(snapshot.data!.status),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                                'Temperature: ${snapshot.data!.current_condition.temp_C}'),
                            Text(
                                'Feels Like: ${snapshot.data!.current_condition.feelsLikeC}'),
                            Text(
                                'Temp in F: ${snapshot.data!.current_condition.temp_F}'),
                            Text(
                                'Pressure: ${snapshot.data!.current_condition.Pressure}'),
                            Text(
                                'Wind Speed (kmph): ${snapshot.data!.current_condition.windSpeedKmph}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class CurrentCondition {
  final String temp_C;
  final String feelsLikeC;
  final String temp_F;
  final String Pressure;
  final String windSpeedKmph;
  CurrentCondition(
      {required this.temp_C,
      required this.temp_F,
      required this.feelsLikeC,
      required this.Pressure,
      required this.windSpeedKmph});
  factory CurrentCondition.fromJson(List<dynamic> json) {
    return CurrentCondition(
      temp_C: json[0]['temp_C'],
      temp_F: json[0]['temp_F'],
      feelsLikeC: json[0]['FeelsLikeC'],
      Pressure: json[0]['pressure'],
      windSpeedKmph: json[0]['windspeedKmph'],
    );
  }
}

class WeatherJson {
  final CurrentCondition current_condition;
  WeatherJson({
    required this.current_condition,
  });
  factory WeatherJson.fromJson(Map<String, dynamic> json) {
    return WeatherJson(
      current_condition: CurrentCondition.fromJson(json['current_condition']),
    );
  }
}

Future<WeatherJson> fetchWeatherData() async {
  final response = await http.get(
    Uri.parse('https://wttr.in/${_cityController.text}?format=j1'),
  );
  if (response.statusCode == 200) {
    return WeatherJson.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load Weather Data');
  }
}
