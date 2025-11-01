import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// API call from OpenWeather
class WeatherService {
  final String? _apiKey = dotenv.env['OPENWEATHER_API_KEY'];
  final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'https://api.openweathermap.org';

  // final CityInfoService _cityInfoService = CityInfoService();

  // open weather app search by city
  Future<Map<String, dynamic>> fetchCurrentWeather(
    String cityOrcountryentered,
  ) async {
    // Handle null API key safely
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENWEATHER_API_KEY not set. Check your .env file.');
    }
    ///////////////////////////////////////////////////////////////////////////
    /*String query = cityOrcountryentered.trim();

   */ /* // Try to fetch country info (capital + ISO code) if input is a country
    try {
      final countryData = await _cityInfoService.fetchCountryInfoByName(
        cityOrcountryentered,
      );
      final capital = countryData['capital'];
      final iso = countryData['cca2'] ?? ''; // ISO 2-letter code

      if (capital.isNotEmpty && iso.isNotEmpty) {
        query = '$capital,$iso'; // e.g., "Paris,FR"
      }
    } catch (_) {
      // If country lookup fails, treat input as city directly
    }*/
    //////////////////////////////////////////////////////////////////////////////////
    final uri = Uri.parse('$_baseUrl/data/2.5/weather').replace(
      queryParameters: {
        'q': cityOrcountryentered,
        /*the city name you want the weather for.*/
        'appid': apiKey,
        'units': 'metric',
      },
    );

    final response = await http.get(uri);

    // checks if all is ok 200
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to fetch weather. HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }
}
