import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:starmap/api_token.dart';

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
    Uri.parse('https://api.nasa.gov/planetary/apod?api_key=$nasaApiKey'),
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
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.network(snapshot.data!.url),
                    Text(snapshot.data!.title),
                    Text(snapshot.data!.explanation),
                  ],
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
