import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:starmap/api_token.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astronomy Picture of the Day',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ApodHome(title: 'Astronomy Picture of the Day'),
    );
  }
}

class ApodHome extends StatefulWidget {
  const ApodHome({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<ApodHome> createState() => _ApodHomeState();
}

class _ApodHomeState extends State<ApodHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Astronomy Picture of the Day!',
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GetApodToday()),
                );
              },
              child: const Text('Get Today\'s APOD'),
            ),
          ],
        ),
      ),
    );
  }
}

class Apod {
  final String title;
  final String explanation;
  final String url;

  Apod({required this.title, required this.explanation, required this.url});

  factory Apod.fromJson(Map<String, dynamic> json) {
    return Apod(
      title: json['title'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

Future<Apod> fetchApodToday() async {
  final response = await http.get(
    Uri.parse('https://api.nasa.gov/planetary/apod?api_key=${nasaApiKey}'),
  );

  if (response.statusCode == 200) {
    return Apod.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load APOD');
  }
}

class GetApodToday extends StatelessWidget {
  const GetApodToday({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astronomy Picture of the Day'),
      ),
      body: FutureBuilder<Apod>(
        future: fetchApodToday(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Image.network(snapshot.data!.url),
                Text(snapshot.data!.title),
                Text(snapshot.data!.explanation),
              ],
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
