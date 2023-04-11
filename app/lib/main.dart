import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://example@sentry.io/add-your-dsn-here';

      // Should not be set to a much lower value in production
      options.tracesSampleRate = 1;
      options.debug = true;
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distributed Tracing Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
      navigatorObservers: [SentryNavigatorObserver()],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WeatherApi _api = WeatherApi();
  late final Future<Weather> _weather = _api.getWeather('New York');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Center(
        child: FutureBuilder<Weather>(
          future: _weather,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Oops, something went wrong');
            }
            if (snapshot.hasData) {
              return Text(
                'The current temperature '
                'is ${snapshot.data!.degrees}',
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Weather {
  Weather({required this.degrees});

  final double degrees;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(degrees: json['degrees'] as double);
  }
}

class WeatherApi {
  final Client _client = SentryHttpClient(client: Client());

  Future<Weather> getWeather(String location) async {
    final response = await _client.get(Uri.parse('http://localhost:8080'));
    final json = jsonDecode(response.body);

    return Weather.fromJson(json);
  }
}
