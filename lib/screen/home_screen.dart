import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_shine/services/weather_service.dart';

import '../services/city_info_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final CityInfoService _cityInfoService = CityInfoService();
  final TextEditingController enteredPlace = TextEditingController();

  bool _loading = false;
  String _weatherInfo = '';
  String _cityDescription = '';
  Map<String, dynamic>? _countryInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather Shine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundIma.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Input field
                    TextFormField(
                      controller: enteredPlace,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enter city name',
                        hintText: 'e.g., London',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.grey[300]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Get weather button
                    ElevatedButton(
                      onPressed: _loading ? null : _fetchData,
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
                    const SizedBox(height: 20),

                    // Weather info
                    if (_weatherInfo.isNotEmpty)
                      Card(
                        elevation: 6,
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _weatherInfo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // City description
                    if (_cityDescription.isNotEmpty)
                      Card(
                        elevation: 6,
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _cityDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Country info
                    if (_countryInfo != null)
                      Card(
                        elevation: 6,
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Flag
                              if (_countryInfo!['flag'] != null &&
                                  _countryInfo!['flag'].isNotEmpty)
                                Image.network(
                                  _countryInfo!['flag'],
                                  height: 60,
                                ),

                              const SizedBox(height: 10),

                              // Country name
                              Text(
                                _countryInfo!['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Other details
                              _buildInfoRow(
                                'Currency',
                                '${_countryInfo!['currency']} (${_countryInfo!['currencySymbol']})',
                              ),
                              _buildInfoRow(
                                'Capital',
                                _countryInfo!['capital'],
                              ),
                              _buildInfoRow(
                                'Continent',
                                _countryInfo!['continent'],
                              ),
                              _buildInfoRow(
                                'Population',
                                _countryInfo!['population'].toString(),
                              ),
                              _buildInfoRow(
                                'Languages',
                                _countryInfo!['language'],
                              ),
                              _buildInfoRow(
                                'Area',
                                '${_countryInfo!['area']} km²',
                              ),
                              _buildInfoRow(
                                'Timezone',
                                _countryInfo!['timezone'],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Future<void> _fetchData() async {
    String input2 = '';
    final input = enteredPlace.text.trim().toLowerCase();
    if (input.isEmpty) {
      setState(() {
        _weatherInfo = 'Please enter a place';
        _cityDescription = '';
        _countryInfo = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _weatherInfo = '';
      _cityDescription = '';
      _countryInfo = null;
    });

    try {
      Map<String, dynamic>? weatherData;
      String? countryCode;
      Map<String, dynamic>? countryInfo;
      String cityDesc = '';

      // Try fetching weather from OpenWeatherMap api— if it fails, we’ll assume it’s a country
      try {
        weatherData = await _weatherService.fetchCurrentWeather(input);

        if (input == 'china') {
          countryCode = 'CN';
        } else if (input == 'france') {
          countryCode = 'FR';
        } else if (input == 'mexico') {
          countryCode = 'MX';
        } else if (input == 'jamaica') {
          countryCode = 'JM';
        } else if (input == 'korea') {
          countryCode = 'KR';
        } else if (input == 'koria') {
          countryCode = 'FI';
        } else {
          // gets iso code from OpenWeatherApp into countryCode,
          // to pass to contries api _cityInfoService.fetchCountryInfo(countryCode);
          countryCode = weatherData['sys']?['country'];
          // print('api sys? country: $countryCode');
        }
      } catch (_) {
        weatherData = null;
      }
      print('Fetched info: $weatherData');
      print('user entred : $input');
      // Always fetch Wikipedia description
      cityDesc = await _cityInfoService.fetchCityDescription(input);

      // Country info logic
      if (countryCode != null && countryCode.isNotEmpty) {
        // We have ISO code → it's a city
        countryInfo = await _cityInfoService.fetchCountryInfo(countryCode);
      } else {
        // No weather ISO code → maybe country name
        countryInfo = await _cityInfoService.fetchCountryInfoByName(input);
      }

      setState(() {
        if (weatherData != null) {
          final tempraturee = weatherData['main']?['temp'];
          final desc = weatherData['weather']?[0]?['description'];
          _weatherInfo =
              'Temperature: \n${tempraturee ?? 'N/A'}°C\n\nCondition: \n${desc ?? 'N/A'}';
        } else {
          _weatherInfo =
              'No weather data available for "$input" (likely a country).';
        }

        _cityDescription = cityDesc;
        _countryInfo = countryInfo;
      });
    } catch (e) {
      setState(() {
        _weatherInfo =
            'Place not found.\nTry entering a valid city or country name.';
        _cityDescription = '';
        _countryInfo = null;
      });
      print('Error fetching data: $e');
    } finally {
      setState(() => _loading = false);
      enteredPlace.clear();
    }
  }
}
