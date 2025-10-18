import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(
        title: const Text('Weather Shine'),
        backgroundColor: Colors.transparent, // Makes the AppBar transparent
        elevation: 0, // Removes shadow
        centerTitle: true,
      ),
      extendBodyBehindAppBar:
          true, // Body background image goes behind the AppBar
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundIma.jpg'),
                fit: BoxFit.cover, // fills the screen
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: enteredPlace,
                      style: TextStyle(
                        color: Colors.white, // Text color when typing
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter only letters',
                        hintText: 'e.g., London',
                        labelStyle: TextStyle(
                          color: Colors.white, // Change label color
                          fontWeight: FontWeight.bold, // Optional: make it bold
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[300], // Change hint color
                          fontStyle: FontStyle.italic, // Optional
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
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
                                final data = await _weatherService
                                    .fetchCurrentWeather(entredPlace2);
                                final temp = data['main']?['temp'];
                                final desc =
                                    data['weather']?[0]?['description'];
                                setState(() {
                                  // the ?? is for a default value in the case temp malfunction or something wrong
                                  _weatherInfo =
                                      'Temperature: ${temp ?? 'N/A'}°C\nCondition: ${desc ?? 'N/A'}';
                                });
                              } catch (e) {
                                setState(() {
                                  _weatherInfo =
                                      'City not found or error: ${e.toString()}';
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
            ),
          ),
        ],
      ),
    );
  }
}
