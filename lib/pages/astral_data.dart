import 'dart:convert';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:starmap/api_token.dart';
import 'package:geolocator/geolocator.dart';

class AstralData extends StatefulWidget {
  const AstralData({Key? key}) : super(key: key);

  @override
  State<AstralData> createState() => _AstralDataState();
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

final TextEditingController _dateController = TextEditingController();
final TextEditingController _longitudeController = TextEditingController();
final TextEditingController _latitudeController = TextEditingController();

class _AstralDataState extends State<AstralData> {
  late Future<AstralData> futureAstralData;
  DateTime? selectedDate;
  bool? deviceLocationUsed = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = '${picked.year}-${picked.month}-${picked.day}';
      });
    } else {
      setState(() {
        selectedDate = DateTime.now();
        _dateController.text =
            '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astral Data'),
      ),
      body: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              readOnly: true,
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Date (YYYY-MM-DD) *',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Longitude'),
              controller: _longitudeController,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Latitude'),
              controller: _latitudeController,
            ),
            Row(children: <Widget>[
              Checkbox(
                value: deviceLocationUsed,
                onChanged: (bool? value) {
                  if (value == true) {
                    setState(() {
                      _determinePosition().then((value) {
                        _latitudeController.text = value.latitude.toString();
                        _longitudeController.text = value.longitude.toString();
                        setState(() {
                          deviceLocationUsed = true;
                        });
                      });
                    });
                  }
                },
              ),
              const Text('Use Current Location'),
            ]),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GetAstralData()));
              },
              child: const Text('Get Data'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<AstralJson> fetchAstralData() async {
  final response = await http.get(
    Uri.parse(
        'https://api.sunrisesunset.io/json?lat=${_latitudeController.text}&lng=${_longitudeController.text}&timezone=IST&date=${_dateController.text}'),
  );

  if (response.statusCode == 200) {
    return AstralJson.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data :|');
  }
}

class Results {
  final String sunrise;
  final String sunset;

  Results({
    required this.sunrise,
    required this.sunset,
  });

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      sunrise: json['sunrise'] ?? '',
      sunset: json['sunset'] ?? '',
    );
  }
}

class AstralJson {
  final String status;
  final Results results;

  AstralJson({
    required this.status,
    required this.results,
  });

  factory AstralJson.fromJson(Map<String, dynamic> json) {
    return AstralJson(
      // results: json['results'] ?? '',
      results: Results.fromJson(json['results']),
      status: json['status'] ?? '',
    );
  }
}

class GetAstralData extends StatelessWidget {
  const GetAstralData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astral Data For The Day!'),
      ),
      body: FutureBuilder<AstralJson>(
        future: fetchAstralData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: DecoratedBox(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/astraldatabg.png'),
                        fit: BoxFit.contain,
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
                                width: 2,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                'Sunrise Time: ${snapshot.data!.results.sunrise} \nSunset Time: ${snapshot.data!.results.sunset} \nDate: ${_dateController.text}',
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                            ),
                          ),
                          //Text(snapshot.data!.results),
                        ],
                      ),
                    )));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}, error :|');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
