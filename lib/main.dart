import 'package:flutter/material.dart';
import 'package:starmap/pages/apod.dart';
import 'package:starmap/pages/astral_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroGeeks',
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
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: accentcolor2,
              secondary: Colors.deepPurpleAccent,
            ),
        useMaterial3: true,
      ),
      home: const AstroGeeks(title: 'AstroF***s'),
    );
  }
}

// Colors

// yellow tint

// const accentcolor1 = Color(0xFFA58B7B);
const accentcolor1 = Color.fromARGB(151, 165, 139, 123);
const accentcolor2 = Color(0xFF010C20);

class AstroGeeks extends StatefulWidget {
  const AstroGeeks({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<AstroGeeks> createState() => _AstroGeeksState();
}

class _AstroGeeksState extends State<AstroGeeks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        centerTitle: true,
      ), */
      body: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/images/homebg.jpg'),
            fit: BoxFit.fill,
          )),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Astronomy Picture of the Day!',
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentcolor1,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GetApodToday()),
                    );
                  },
                  child: const Text('Get Today\'s APOD'),
                ),
                const Padding(padding: EdgeInsets.all(10.0)),
                const Text('Astral Data For The Day!'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentcolor1,
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AstralData()),
                    );
                  },
                  child: const Text('Get Today\'s Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
