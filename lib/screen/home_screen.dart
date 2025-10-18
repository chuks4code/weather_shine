import 'package:flutter/material.dart';
import 'package:weather_shine/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController enteredPlace = TextEditingController();
  String _weatherInfo = ''; // to display fetched data
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: enteredPlace,
              decoration: InputDecoration(
                labelText: 'Enter only letters',
                hintText: 'e.g., London',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Pls enter a place";
                }
                if (value.length < 2) {
                  return 'Pls enter valid name of a place';
                }
                return null;
              },
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      final entredPlace2 = enteredPlace.text.trim();
                      if (entredPlace2.isEmpty) return;

                      setState(() {
                        _loading = true;
                        _weatherInfo = '';
                      });

                      //Exception and error handling
                      try {
                        // fetchCurrentWeather has the url and api and all from weather_service
                        final data = await _weatherService.fetchCurrentWeather(
                          entredPlace2,
                        );
                        final temp = data['main']?['temp'];
                        final desc = data['weather']?[0]?['description'];
                        setState(() {
                          // the ?? is for a default value in the case temp malfunction or something wrong
                          _weatherInfo =
                              'Temperature: ${temp ?? 'N/A'}°C\nCondition: ${desc ?? 'N/A'}';
                        });
                      } catch (e) {
                        setState(() {
                          _weatherInfo = 'Error: ${e.toString()}';
                        });
                      } finally {
                        setState(() {
                          _loading = false;
                        });
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Get Weather'),
            ),
            SizedBox(height: 10.0),
            Text(_weatherInfo, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10.0),
            Text('it 23 degrees '),
            SizedBox(height: 10.0),
            Text('description of place '),
          ],
        ),
      ),
    );
  }
}
